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
		sid    = "Allow Deployment Roles"
		effect = "Allow"
		principals {
			type        = "AWS"
			identifiers = ["*"]
		}
		actions = [
			"kms:Decrypt",
			"kms:Encrypt",
			"kms:GenerateDataKey",
			"kms:DescribeKey"
		]
		resources = ["*"]
		condition {
			test     = "StringLike"
			variable = "aws:PrincipalArn"
			values   = ["arn:aws:iam::*:role/pge-epic-deployment-role"]
		}
	}
}

resource "aws_kms_key" "terraform_state" {
	description             = "KMS key for Terraform state encryption"
	deletion_window_in_days = 30
	enable_key_rotation     = true
	policy                  = data.aws_iam_policy_document.kms_key_policy.json

	tags = merge(module.tags.tags, {
		Name = "pge-epic-terraform-state-key"
	})
}

resource "aws_kms_alias" "terraform_state" {
	name          = "alias/pge-epic-terraform-state"
	target_key_id = aws_kms_key.terraform_state.key_id
}


###############################################################################
# S3 Backend Bucket
###############################################################################

module "s3_terraform_state" {
	source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

	app_name                   = "terraform-state"
	environment                = var.environment
	custom_bucket_name				 = "pge-epic-terraform-state"
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
			prefix = "logs/"
			noncurrent_version_expiration = {
				noncurrent_days = 90
			}
		}
	]
}


###############################################################################
# S3 Bucket Policy for Cross-Account Access
###############################################################################

data "aws_iam_policy_document" "s3_state_bucket_policy" {
	statement {
		sid    = "AllowDeploymentRoles"
		effect = "Allow"
		principals {
			type        = "AWS"
			identifiers = ["*"]
		}
		actions = [
			"s3:ListBucket",
			"s3:GetBucketVersioning"
		]
		resources = [module.s3_terraform_state.bucket_arn]
		condition {
			test     = "StringLike"
			variable = "aws:PrincipalArn"
			values   = ["arn:aws:iam::*:role/pge-epic-deployment-role"]
		}
	}

	statement {
		sid    = "AllowDeploymentRoleObjects"
		effect = "Allow"
		principals {
			type        = "AWS"
			identifiers = ["*"]
		}
		actions = [
			"s3:GetObject",
			"s3:PutObject",
			"s3:DeleteObject"
		]
		resources = ["${module.s3_terraform_state.bucket_arn}/*"]
		condition {
			test     = "StringLike"
			variable = "aws:PrincipalArn"
			values   = ["arn:aws:iam::*:role/pge-epic-deployment-role"]
		}
	}
}

resource "aws_s3_bucket_policy" "terraform_state" {
	bucket = module.s3_terraform_state.bucket_name
	policy = data.aws_iam_policy_document.s3_state_bucket_policy.json
}


###############################################################################
# DynamoDB Lock Table
###############################################################################

resource "aws_dynamodb_table" "terraform_locks" {
	name         = "pge-epic-terraform-locks"
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
		Name = "pge-epic-terraform-locks"
	})
}


###############################################################################
# OIDC Provider for Azure DevOps
###############################################################################

resource "aws_iam_openid_connect_provider" "ado" {
	count = var.create_oidc_provider ? 1 : 0

	# the issuer URL uses the org's GUID, not the human-readable name
	url = "https://vstoken.dev.azure.com/${var.ado_organization_id}"

	client_id_list = [
		"api://AzureADTokenExchange"
	]

	thumbprint_list = [
		"6938fd4d98bab03faadb97b34396831e3780aea1"
	]

	tags = module.tags.tags
}


###############################################################################
# EPIC Service Role (ADO assumes this)
###############################################################################

data "aws_iam_policy_document" "epic_service_assume_role" {
	statement {
		effect = "Allow"
		principals {
			type        = "AWS"
			identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
		}
		actions = ["sts:AssumeRole"]
	}

	# OIDC federation from Azure/ADO
	dynamic "statement" {
		for_each = var.create_oidc_provider ? [1] : []
		content {
			effect = "Allow"
			principals {
				type        = "Federated"
				identifiers = [aws_iam_openid_connect_provider.ado[0].arn]
			}
			actions = ["sts:AssumeRoleWithWebIdentity"]
			condition {
				test     = "StringEquals"
				# issuer-based variable uses organization GUID
				variable = "vstoken.dev.azure.com/${var.ado_organization_id}:aud"
				values   = ["api://AzureADTokenExchange"]
			}
			condition {
				test     = "StringLike"
				variable = "vstoken.dev.azure.com/${var.ado_organization_id}:sub"
				# subject pattern still uses friendly organization name
				values   = ["sc://${var.ado_organization}/${var.ado_project}/*"]
			}
		}
	}
}

resource "aws_iam_role" "epic_service" {
	name                 = "pge-epic-service-role"
	assume_role_policy   = data.aws_iam_policy_document.epic_service_assume_role.json
	max_session_duration = 3600

	tags = merge(module.tags.tags, {
		Name = "pge-epic-service-role"
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
	name   = "pge-epic-state-access"
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
			"arn:aws:iam::*:role/pge-epic-deployment-role"
		]
	}
}

resource "aws_iam_role_policy" "epic_cross_account_assume" {
	name   = "pge-epic-cross-account-assume"
	role   = aws_iam_role.epic_service.id
	policy = data.aws_iam_policy_document.epic_cross_account_assume.json
}


###############################################################################
# EPIC Service Role - Local Account Deployment (optional)
###############################################################################

data "aws_iam_policy_document" "epic_local_deployment" {
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
	name   = "pge-epic-local-deployment"
	role   = aws_iam_role.epic_service.id
	policy = data.aws_iam_policy_document.epic_local_deployment.json
}