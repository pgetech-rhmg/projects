###############################################################################
# Tags
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id     = var.aws_account_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}


###############################################################################
# KMS Key for State Encryption
###############################################################################

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(module.tags.tags, {
    Name = "epic-terraform-state-key"
  })
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/epic-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}


###############################################################################
# S3 Backend Bucket
###############################################################################

module "s3_terraform_state" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "epic-terraform-state"
  environment                = var.environment
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = "terraform-state/"
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = true
  enable_versioning          = true
  force_destroy              = false
  kms_key_arn                = aws_kms_key.terraform_state.arn
  object_ownership           = "BucketOwnerEnforced"
  sse_algorithm              = "aws:kms"

  lifecycle_rules = [
    {
      id     = "expire-old-versions"
      status = "Enabled"
      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
}


###############################################################################
# DynamoDB Lock Table
###############################################################################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "epic-terraform-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(module.tags.tags, {
    Name = "epic-terraform-locks-${var.environment}"
  })
}


###############################################################################
# EPIC Service Role (ADO assumes this)
###############################################################################

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "epic_service_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }

  # If using OIDC federation from Azure/ADO, add this statement
  dynamic "statement" {
    for_each = var.oidc_provider_arn != "" ? [1] : []
    content {
      effect = "Allow"
      principals {
        type        = "Federated"
        identifiers = [var.oidc_provider_arn]
      }
      actions = ["sts:AssumeRoleWithWebIdentity"]
      condition {
        test     = "StringEquals"
        variable = "${replace(var.oidc_provider_arn, "/^.*provider//", "")}:aud"
        values   = var.oidc_audience
      }
    }
  }
}

resource "aws_iam_role" "epic_service" {
  name                 = "epic-service-role"
  assume_role_policy   = data.aws_iam_policy_document.epic_service_assume_role.json
  max_session_duration = 3600

  tags = merge(module.tags.tags, {
    Name = "epic-service-role"
  })
}


###############################################################################
# EPIC Service Role - State Access Policy
###############################################################################

data "aws_iam_policy_document" "epic_state_access" {
  statement {
    sid    = "S3StateAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [module.s3_terraform_state.bucket_arn]
  }

  statement {
    sid    = "S3ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${module.s3_terraform_state.bucket_arn}/*"]
  }

  statement {
    sid    = "DynamoDBLockAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }

  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.terraform_state.arn]
  }
}

resource "aws_iam_role_policy" "epic_state_access" {
  name   = "epic-state-access"
  role   = aws_iam_role.epic_service.id
  policy = data.aws_iam_policy_document.epic_state_access.json
}


###############################################################################
# EPIC Service Role - Cross-Account Assume Policy
###############################################################################

data "aws_iam_policy_document" "epic_cross_account_assume" {
  statement {
    sid    = "AssumeTargetAccountRoles"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/epic-deployment-role"
    ]
  }
}

resource "aws_iam_role_policy" "epic_cross_account_assume" {
  name   = "epic-cross-account-assume"
  role   = aws_iam_role.epic_service.id
  policy = data.aws_iam_policy_document.epic_cross_account_assume.json
}


###############################################################################
# EPIC Service Role - Local Account Deployment (optional)
###############################################################################

data "aws_iam_policy_document" "epic_local_deployment" {
  # Allow EPIC to deploy to its own account if needed
  statement {
    sid    = "LocalAccountDeployment"
    effect = "Allow"
    actions = [
      "ec2:*",
      "s3:*",
      "iam:*",
      "cloudfront:*",
      "route53:*",
      "acm:*",
      "secretsmanager:*",
      "kms:*",
      "ssm:*",
      "logs:*",
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "epic_local_deployment" {
  count  = var.allow_epic_local_deployment ? 1 : 0
  name   = "epic-local-deployment"
  role   = aws_iam_role.epic_service.id
  policy = data.aws_iam_policy_document.epic_local_deployment.json
}
