# KMS keys for AMI encryption

locals {
  components = ["webadapter", "portal", "datastore", "server"]
}

# KMS key for CloudWatch Logs encryption with proper permissions
module "cloudwatch_logs_kms" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = "ami-factory-cloudwatch-logs-${var.environment}"
  description = "KMS key for CloudWatch Logs encryption - enables encryption at rest for all CloudWatch log groups"
  aws_role    = var.aws_role
  kms_role    = var.aws_role

  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogsServiceToUseKey"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      },
      {
        Sid    = "AllowAWSServicesToDencryptLogData"
        Effect = "Allow"
        Principal = {
          Service = [
            "logs.${data.aws_region.current.region}.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        "Sid" : "Allow IAM user permission",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })

  tags = local.merged_tags
}

# KMS keys for AMI encryption
module "ami_encryption_kms" {

  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = "ami-factory-amis-${var.environment}"
  description = "AMI encryption key for AMIs"
  aws_role    = var.aws_role
  kms_role    = var.aws_role

  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid    = "AllowImageBuilderAndEC2ToUseKey"
        Effect = "Allow"
        Principal = {
          Service = [
            "imagebuilder.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "ec2.${data.aws_region.current.region}.amazonaws.com",
              "imagebuilder.${data.aws_region.current.region}.amazonaws.com"
            ]
          }
        }
      },
      length(var.share_account_ids) > 0 ? {
        Sid    = "AllowTargetAccountsToUseKeyForAMI"
        Effect = "Allow"
        Principal = {
          AWS = [for id in var.share_account_ids : "arn:aws:iam::${id}:root"]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      } : null,

      length(var.share_account_ids) > 0 ? {
        Sid    = "AllowAttachPersistentResXAccount"
        Effect = "Allow"
        Principal = {
          AWS = [for id in var.share_account_ids : "arn:aws:iam::${id}:root"]
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = "*"
        Condition = {
          Bool = { "kms:GrantIsForAWSResource" = "true" }
        }
      } : null
    ]
  })

  tags = local.merged_tags
}

# Store KMS key ARNs in SSM for reference
resource "aws_ssm_parameter" "kms_key_arn" {

  name        = "/amifactory/kms/keyarn"
  description = "KMS key ARN for AMI encryption"
  type        = "String"
  value       = module.ami_encryption_kms.key_arn

  tags = merge(
    local.merged_tags,
    {
      Component = "amifactory"
    }
  )
}

# KMS key for Lambda environment variable encryption
module "lambda_env_encryption_kms" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = "ami-factory-lambda-env-${var.environment}"
  description = "KMS key for Lambda environment variable encryption"
  aws_role    = var.aws_role
  kms_role    = var.aws_role

  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaRolesToDecryptEnvVars"
        Effect = "Allow"
        Principal = {
          AWS = [
            module.ami_writer_lambda_iam.arn,
            module.tfc_runner_lambda_iam.arn,
            module.config_manager_lambda_iam.arn,
            module.ami_publisher_lambda_iam.arn
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        "Sid" : "Allow IAM user permission",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })

  tags = local.merged_tags
}

# KMS key for SNS encryption
module "sns_encryption_kms" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = "ami-factory-sns-${var.environment}"
  description = "KMS key for SNS encryption"
  aws_role    = var.aws_role
  kms_role    = var.aws_role

  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSToEncrypt"
        Effect = "Allow"
        Principal = {
          Service = [
            "sns.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        "Sid" : "Allow IAM user permission",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })

  tags = local.merged_tags
}

# KMS key for CodePipeline artifact store encryption
module "codepipeline_artifacts_kms" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name        = "ami-factory-codepipeline-artifacts-${var.environment}"
  description = "KMS key for CodePipeline artifact store encryption - enables encryption at rest for build artifacts"
  aws_role    = var.aws_role
  kms_role    = var.aws_role

  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCodePipelineToUseKey"
        Effect = "Allow"
        Principal = {
          AWS = [
            module.codepipeline_iam.arn,
            module.pipeline_input_preparer_lambda_iam.arn,
            module.ami-factory-image-builder-iam.arn
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3ToUseKey"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowKeyManagement"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_role}"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        "Sid" : "Allow IAM user permission",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })

  tags = local.merged_tags
}


################################################################################
# Outputs
################################################################################

output "cloudwatch_logs_kms_key_id" {
  value       = module.cloudwatch_logs_kms.key_id
  description = "KMS key ID for CloudWatch Logs"
}

output "cloudwatch_logs_kms_key_arn" {
  value       = module.cloudwatch_logs_kms.key_arn
  description = "KMS key ARN for CloudWatch Logs"
}

output "lambda_env_encryption_kms_key_arn" {
  value       = module.lambda_env_encryption_kms.key_arn
  description = "KMS key ARN for Lambda environment variable encryption"
}

output "codepipeline_artifacts_kms_key_id" {
  value       = module.codepipeline_artifacts_kms.key_id
  description = "KMS key ID for CodePipeline artifact store encryption"
}

output "codepipeline_artifacts_kms_key_arn" {
  value       = module.codepipeline_artifacts_kms.key_arn
  description = "KMS key ARN for CodePipeline artifact store encryption"
}

output "ami_encryption_kms_keys_key_arn" {
  value       = module.ami_encryption_kms.key_arn
  description = "KMS keys for AMI encryption"
}

output "sns_encryption_kms_key_arn" {
  value       = module.sns_encryption_kms.key_arn
  description = "KMS keys for SNS encryption"
}

output "kms_key_arns_ssm_parameters" {
  value       = aws_ssm_parameter.kms_key_arn.arn
  description = "SSM parameter ARNs for KMS key ARNs"
}