/*
 * AWS Bedrock AgentCore Module
 *
 * This module provisions an AWS Bedrock AgentCore Runtime with optional memory and strategy configurations.
 * It also sets up necessary resources such as ECR repositories for container images, KMS keys for encryption, and security groups for network access. * Source can be found at https://github.com/pgetech/pge-terraform-modules
 * 
 * Source can be found at https://github.com/pgetech/pge-terraform-modules
 * To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
 */

locals {
  name = var.runtime_name
}

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Order              = var.Order
  Compliance         = var.Compliance

}

#### Tags module ########
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

#### KMS module ########
module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name                    = "${local.name}-kms-key"
  description             = "KMS key for Bedrock Agent Runtime encryption"
  deletion_window_in_days = 30
  aws_role                = var.aws_role
  kms_role                = var.aws_role
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM Root User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = module.tags.tags
}

# Create an ECR repository for the agent runtime container using a reusable module
module "ecr" {
  source               = "app.terraform.io/pgetech/ecr/aws"
  version              = "0.1.3"
  ecr_name             = "bedrock/${var.runtime_name}"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  tags                 = module.tags.tags
  kms_key              = module.kms_key.key_arn
  policy               = data.aws_iam_policy_document.ecr_policy.json
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "ReadECR"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${local.name}-sg"
  description = "Security group for Bedrock Agent Runtime"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  cidr_ingress_rules = [
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow HTTPS traffic from VPC"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "tcp",
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow All traffic from 172.16.0.0/12"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "tcp",
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow All traffic from 192.168.0.0/16"
    }
  ]

  cidr_egress_rules = [
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow all outbound traffic"
    }
  ]

  tags = module.tags.tags
}

module "bedrock_agent_runtime" {
  source = "../../modules/runtime/"
  providers = {
    aws   = aws
    awscc = awscc
  }

  # Enable agent runtime creation
  create_runtime = var.create_runtime

  # Runtime configuration
  runtime_name              = local.name
  runtime_description       = var.runtime_description
  runtime_container_uri     = "${module.ecr.ecr_repository_url}:latest"
  runtime_network_mode      = "VPC"
  runtime_code_runtime_type = var.runtime_code_runtime_type
  runtime_network_configuration = {
    subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
    security_groups = [module.security_group.sg_id]
  }

  # Environment variables for the runtime
  runtime_environment_variables = var.runtime_environment_variables

  # Tags
  runtime_tags = merge(module.tags.tags, var.runtime_tags)

  # Enable agent runtime endpoint creation
  create_runtime_endpoint      = var.create_runtime_endpoint
  runtime_endpoint_name        = var.runtime_endpoint_name
  runtime_endpoint_description = var.runtime_endpoint_description

  # Tags for the endpoint
  runtime_endpoint_tags = merge(module.tags.tags, var.runtime_endpoint_tags)

  # Required tagging variables
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

# ========================================
# CI/CD Pipeline Configuration
# ========================================

###########################################################################
# S3 bucket for Codepipeline build logs and artifacts
# Created before codepipeline module as it's a dependency
###########################################################################

module "s3_ci" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.ci_logs_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn if encryption is needed
  policy      = data.aws_iam_policy_document.ci_allow_access.json
  tags        = module.tags.tags
}

###########################################################################
# IAM role for codepipeline
# Created before codepipeline module as it's a dependency
###########################################################################

module "codepipeline_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "codepipeline_${local.name}_iam_role"
  aws_service = ["codepipeline.amazonaws.com"]
  tags        = module.tags.tags
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3_ci.arn
  })]
}

###########################################################################
# CodePipeline Module
###########################################################################

module "codepipeline" {
  source  = "app.terraform.io/pgetech/codepipeline-container/aws"
  version = "0.1.0"

  codepipeline_name                       = "${local.name}-ci"
  role_arn                                = module.codepipeline_iam_role.arn
  region                                  = var.aws_region
  secretsmanager_github_token_secret_name = var.ci_github_secret
  github_org                              = "pgetech"
  repo_name                               = split("/", replace(var.repo_url, "https://github.com/", ""))[1]
  branch                                  = var.ci_branch
  environment_type_codebuild              = "LINUX_CONTAINER"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  source_location_codebuild               = var.repo_url
  environment_image_codebuild             = var.ci_image
  concurrent_build_limit_codebuild        = 1
  compute_type_codebuild                  = var.ci_compute_type
  artifact_path                           = "/"
  artifact_bucket_owner_access            = "FULL"
  cidr_egress_rules = [
    {
      from             = 0
      to               = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow all outbound traffic"
    }
  ]
  s3_bucket                  = module.s3_ci.id
  sg_name                    = "sg_codepipeline_${local.name}"
  sg_description             = "Security group for codepipeline ${local.name}"
  source_buildspec_codebuild = file("${path.module}/buildspec.yml")
  tags                       = module.tags.tags
  subnet_ids                 = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]

  vpc_id = data.aws_ssm_parameter.vpc_id.value
  environment_variables_codebuild_stage = [
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = var.account_num
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_REGION"
      value = var.aws_region
      type  = "PLAINTEXT"
    },
    {
      name  = "DOCKER_IMAGE_NAME"
      value = "bedrock/${var.runtime_name}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ECR_REPOSITORY_URI"
      value = module.ecr.ecr_repository_url
      type  = "PLAINTEXT"
    },
    {
      name  = "WIZ_CLIENT_ID"
      value = "shared-wiz-access:WIZ_CLIENT_ID"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "WIZ_CLIENT_SECRET"
      value = "shared-wiz-access:WIZ_CLIENT_SECRET"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ENVIRONMENT"
      value = var.Environment
      type  = "PLAINTEXT"
    }
  ]

  endpoint_email = var.Notify

  encryption_key_id              = null # replace with module.kms_key.key_arn if encryption is needed
  artifact_store_location_bucket = module.s3_ci.id
}
