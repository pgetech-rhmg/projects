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
# KMS Key for Artifact Encryption
#
# Encrypts the epic-compliance CLI binaries at rest. Mirrors the state-bucket
# key pattern: rotation enabled, root has full control, and org-scoped
# Decrypt/DescribeKey so EPIC deployment/agent roles across the org can read.
###############################################################################

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Org Roles to Decrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.org_id]
    }
  }

  statement {
    sid    = "Allow Deployment Role to Encrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.org_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/${var.deployment_role_name}"]
    }
  }
}

resource "aws_kms_key" "compliance_artifacts" {
  description             = "KMS key for EPIC Compliance Reviewer artifact encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(module.tags.tags, {
    Name = "pge-epic-compliance-key"
  })
}

resource "aws_kms_alias" "compliance_artifacts" {
  name          = "alias/pge-epic-compliance"
  target_key_id = aws_kms_key.compliance_artifacts.key_id
}


###############################################################################
# S3 Artifact Bucket
#
# Hosts the version-pinned epic-compliance CLI binary that the EPIC compliance
# stage pulls (aws s3 cp) into the run workspace between download and build.
# Versioned + KMS-encrypted + public access blocked, matching the state bucket.
###############################################################################

module "s3_compliance_artifacts" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "compliance-reviewer"
  environment                = var.environment
  custom_bucket_name         = var.custom_bucket_name
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = "compliance/"
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = true
  enable_versioning          = true
  force_destroy              = false
  kms_key_arn                = aws_kms_key.compliance_artifacts.arn
  object_ownership           = "BucketOwnerEnforced"
  sse_algorithm              = "aws:kms"

  lifecycle_rules = [
    {
      id     = "expire-old-versions"
      status = "Enabled"
      # Empty filter applies the rule to the whole bucket. Required by the AWS
      # provider (exactly one of filter/prefix must be set) — omitting both is
      # deprecated and will error in a future provider version.
      filter = {}
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  ]
}


###############################################################################
# S3 Bucket Policy
#
# Read access (List/Get) for EPIC deployment roles across the org and any extra
# reader roles (e.g. the scan agent). Publish (Put/Delete) limited to the
# deployment role. TLS enforced; everything else denied.
###############################################################################

data "aws_iam_policy_document" "artifact_bucket_policy" {
  statement {
    sid    = "AllowOrgRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      module.s3_compliance_artifacts.bucket_arn,
      "${module.s3_compliance_artifacts.bucket_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.org_id]
    }
  }

  statement {
    sid    = "AllowDeploymentRolePublish"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${module.s3_compliance_artifacts.bucket_arn}/*"]
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/${var.deployment_role_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.org_id]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      module.s3_compliance_artifacts.bucket_arn,
      "${module.s3_compliance_artifacts.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "compliance_artifacts" {
  bucket = module.s3_compliance_artifacts.bucket_name
  policy = data.aws_iam_policy_document.artifact_bucket_policy.json
}


###############################################################################
# Reader Role Policies (optional)
#
# Attaches inline read policy to any extra local-account roles (e.g. the scan
# agent's instance role) that must pull the binary but are not the deployment
# role. Org-wide read is already granted in the bucket policy; this covers the
# object-level permission on the reading principal's side.
###############################################################################

data "aws_iam_policy_document" "artifact_read" {
  count = length(var.reader_role_arns) > 0 ? 1 : 0

  statement {
    sid    = "ReadComplianceArtifacts"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [module.s3_compliance_artifacts.bucket_arn]
  }

  statement {
    sid    = "GetComplianceArtifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${module.s3_compliance_artifacts.bucket_arn}/*"]
  }

  statement {
    sid    = "DecryptComplianceArtifacts"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.compliance_artifacts.arn]
  }
}

resource "aws_iam_policy" "artifact_read" {
  count = length(var.reader_role_arns) > 0 ? 1 : 0

  name   = "pge-epic-compliance-artifact-read-${var.environment}"
  policy = data.aws_iam_policy_document.artifact_read[0].json
  tags   = module.tags.tags
}

resource "aws_iam_role_policy_attachment" "artifact_read" {
  count = length(var.reader_role_arns)

  role       = element(split("/", var.reader_role_arns[count.index]), length(split("/", var.reader_role_arns[count.index])) - 1)
  policy_arn = aws_iam_policy.artifact_read[0].arn
}


###############################################################################
# Artifact Upload (optional)
#
# When var.artifact_source is set, uploads the compiled linux/amd64 binary to
# the version-pinned key. Leave empty to publish out-of-band (e.g. CI s3 cp).
###############################################################################

resource "aws_s3_object" "artifact" {
  count = var.artifact_source != "" && var.artifact_key != "" ? 1 : 0

  bucket      = module.s3_compliance_artifacts.bucket_name
  key         = var.artifact_key
  source      = var.artifact_source
  source_hash = filemd5(var.artifact_source)
  kms_key_id  = aws_kms_key.compliance_artifacts.arn

  tags = merge(module.tags.tags, {
    Name = "epic-compliance-binary"
  })
}
