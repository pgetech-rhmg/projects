# Lambda execution role for AMI writer
module "ami_writer_lambda_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-ami-writer"
  description = "IAM role for AMI writer Lambda function"
  aws_service = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "SSMParameterAccess"
          Effect = "Allow"
          Action = [
            "ssm:PutParameter",
            "ssm:AddTagsToResource",
            "ssm:LabelParameterVersion"
          ]
          Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/ami_factory/*"
        },

        {
          Sid    = "KMSForEncryptedAMIs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*"
          ]
          Resource = data.aws_ssm_parameter.enterprise_kms.value
        }

      ]
    })
  ]

  tags = local.merged_tags
}

# Data source for TFC API role ARN
#data "aws_ssm_parameter" "tfc_api_role_arn" {
# TODO: Update this to the path that COE provides (should be published to our accounts from a COE-controlled deployment)
#  name = "/tfc/api_access_role_arn"
#}

# Lambda execution role for TFC runner ###### TODO - replace assumer role with 'data.aws_ssm_parameter.tfc_api_role_arn.value' once we have the parameter from COE #################
module "tfc_runner_lambda_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-tfc-runner"
  description = "IAM role for TFC runner Lambda function"
  aws_service = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AssumeRoleForTFC"
          Effect = "Allow"
          Action = [
            "sts:AssumeRole"
          ]
          Resource = module.test_instance_iam.arn
        },
        {
          Sid    = "SecretsAccess"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:Terraform/*"
        },
        {
          Sid    = "EC2LaunchInstances"
          Effect = "Allow"
          Action = [
            "ec2:RunInstances"
          ]
          Resource = [
            "arn:aws:ec2:${data.aws_region.current.region}::image/*",
            "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/*",
            "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
            "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:security-group/*",
            "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:subnet/*",
            "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:volume/*"
          ]
        },
        {
          Sid    = "EC2CreateTags"
          Effect = "Allow"
          Action = [
            "ec2:CreateTags"
          ]
          Resource = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
          Condition = {
            StringEquals = {
              "ec2:CreateAction" = "RunInstances"
            }
          }
        },
        {
          Sid    = "PassRoleForInstances"
          Effect = "Allow"
          Action = [
            "iam:PassRole"
          ]
          Resource = module.test_instance_iam.arn
        },
        {
          Sid    = "SSMSandboxState"
          Effect = "Allow"
          Action = [
            "ssm:PutParameter"
          ]
          Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/ami_factory/sandbox_state"
        },
        {
          Sid    = "KMSForEncryptedAMIs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:CreateGrant",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*"
          ]
          Resource = [
            data.aws_ssm_parameter.enterprise_kms.value,
            module.ami_encryption_kms.key_arn
          ]
        }
      ]
    })
  ]

  tags = local.merged_tags
}

# IAM role and instance profile for test instances launched in dry_run mode
module "test_instance_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-test-instance"
  description = "IAM role for test instances launched in dry-run mode"
  aws_service = ["ec2.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [

        {
          Sid    = "KMSForEncryptedAMIs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*"
          ]
          Resource = [
            data.aws_ssm_parameter.enterprise_kms.value,
            module.ami_encryption_kms.key_arn
          ]
        }

      ]
    })
  ]

  tags = local.merged_tags
}

resource "aws_iam_instance_profile" "test_instance" {
  name_prefix = "ami-factory-test-instance-"
  role        = module.test_instance_iam.name

  tags = merge(
    local.merged_tags,
    {
      Name = "ami-factory-test-instance-profile"
    }
  )
}

# Lambda execution role for ConfigManager
module "config_manager_lambda_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-config-manager"
  description = "IAM role for ConfigManager Lambda function"
  aws_service = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "SSMSandboxStateAccess"
          Effect = "Allow"
          Action = [
            "ssm:GetParameter"
          ]
          Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/ami_factory/sandbox_state"
        },
        {
          Sid    = "EC2DescribeInstances"
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances"
          ]
          Resource = "*"
        },
        {
          Sid    = "SSMSendDocumentCommands"
          Effect = "Allow"
          Action = [
            "ssm:SendCommand"
          ]
          Resource = [
            "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:document/ConfigDoc-*",
            "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:document/TestDoc-*",
            "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:document/arcgis-*"
          ]
        },
        {
          Sid    = "SSMSendCommandToInstances"
          Effect = "Allow"
          Action = [
            "ssm:SendCommand"
          ]
          Resource = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/*"
          # Condition = {
          #   StringEquals = {
          #     "ssm:resourceTag/ManagedBy" = "ami-factory-dry-run"
          #   }
          # }
        },
        {
          Sid    = "SSMGetCommandInvocation"
          Effect = "Allow"
          Action = [
            "ssm:GetCommandInvocation",
            "ssm:ListCommandInvocations"
          ]
          Resource = "*"
        },
        {
          Sid    = "KMSForEncryptedEnvs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*"
          ]
          Resource = data.aws_ssm_parameter.enterprise_kms.value
        },
        {
          Sid    = "AssumeRoleForTFC"
          Effect = "Allow"
          Action = [
            "sts:AssumeRole"
          ]
          Resource = module.test_instance_iam.arn
        },
        {
          Sid    = "SecretsAccess"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:Terraform/*"
        }
      ]
    })
  ]

  tags = local.merged_tags
}

# Lambda execution role for AMI publisher
module "ami_publisher_lambda_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-ami-publisher"
  description = "IAM role for AMI publisher Lambda function"
  aws_service = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "SSMParameterReadAccess"
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameterHistory",
            "ssm:LabelParameterVersion"
          ]
          Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/ami_factory/*/ami"
        },
        {
          Sid    = "CodePipelineAccess"
          Effect = "Allow"
          Action = [
            "codepipeline:PutJobSuccessResult",
            "codepipeline:PutJobFailureResult"
          ]
          Resource = "*"
        },
        {
          Sid    = "KMSForEncryptedEnvs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*"
          ]
          Resource = data.aws_ssm_parameter.enterprise_kms.value
        },
        # {
        #   Sid    = "PublishEvents"
        #   Effect = "Allow"
        #   Action = [
        #     "events:PutEvents"
        #   ]
        #   Resource = aws_cloudwatch_event_bus.ami_factory.arn
        # }
      ]
    })
  ]

  tags = local.merged_tags
}

# Lambda execution role for preparing pipeline input (used by a private Lambda, not part of step function)
module "pipeline_input_preparer_lambda_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-pipeline-input-preparer"
  description = "IAM role for pipeline input preparer Lambda function"
  aws_service = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "SSMParameterReadAccess"
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
        },
        {
          Sid    = "KMSForEncryptedEnvs"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey*"
          ]
          Resource = [
            data.aws_ssm_parameter.enterprise_kms.value,
            module.codepipeline_artifacts_kms.key_arn
          ]
        },
        {
          Sid    = "CodePipelineAccess"
          Effect = "Allow"
          Action = [
            "codepipeline:PutJobSuccessResult",
            "codepipeline:PutJobFailureResult"
          ]
          Resource = "*"
        },
        {
          Sid    = "S3ReadAccessForPipelineInput"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:GetBucketLocation"
          ]
          Resource = [
            module.pipeline_artifacts_s3.arn,
            "${module.pipeline_artifacts_s3.arn}/*"
          ]
        }
      ]
    })
  ]

  tags = local.merged_tags
}

################################################################################
# Outputs
################################################################################

output "ami_writer_lambda_role_arn" {
  value       = module.ami_writer_lambda_iam.arn
  description = "ARN of the AMI writer Lambda execution role"
}

output "tfc_runner_lambda_role_arn" {
  value       = module.tfc_runner_lambda_iam.arn
  description = "ARN of the TFC runner Lambda execution role"
}

output "config_manager_lambda_role_arn" {
  value       = module.config_manager_lambda_iam.arn
  description = "ARN of the ConfigManager Lambda execution role"
}

output "ami_publisher_lambda_role_arn" {
  value       = module.ami_publisher_lambda_iam.arn
  description = "ARN of the AMI publisher Lambda execution role"
}

output "test_instance_role_arn" {
  value       = module.test_instance_iam.arn
  description = "ARN of the test instance IAM role"
}

output "test_instance_profile_arn" {
  value       = aws_iam_instance_profile.test_instance.arn
  description = "ARN of the test instance profile"
}
