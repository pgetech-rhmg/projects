/*
 * # AWS Bedrock Agent Core Runtime module
 * Terraform module which creates and manages Runtime resources for AWS Bedrock Agent Core.
 *
 * Source can be found at https://github.com/pgetech/pge-terraform-modules
 *
 * To use with encryption please refer https://wiki.comp.pge.com/display/CCE/Terraform+Modules+and+KMS
 *
 */

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Random string for unique naming
resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  create_runtime = var.create_runtime
  # Sanitize runtime name to ensure it follows the regex pattern ^[a-zA-Z][a-zA-Z0-9_]{0,47}$
  sanitized_runtime_name = replace(var.runtime_name, "-", "_")
}

# IAM Role for Bedrock Agent Runtime
resource "aws_iam_role" "runtime_role" {
  count = local.create_runtime && var.runtime_role_arn == null ? 1 : 0
  name  = "${random_string.solution_prefix.result}-bedrock-agent-runtime-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AssumeRolePolicy"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary_arn
  tags                 = local.merged_tags
  #tags                 = var.runtime_tags
}

# IAM Policy for Agent Runtime
# Attach SLR policy to runtime role if created
resource "aws_iam_role_policy" "runtime_slr_policy" {
  count  = local.create_runtime && var.runtime_role_arn == null ? 1 : 0
  name   = "${random_string.solution_prefix.result}-bedrock-agent-runtime-slr-policy"
  role   = aws_iam_role.runtime_role[0].name
  policy = data.aws_iam_policy_document.service_linked_role[0].json
}

# Add a time delay to ensure IAM role propagation
resource "time_sleep" "iam_role_propagation" {
  count           = local.create_runtime && var.runtime_role_arn == null ? 1 : 0
  depends_on      = [aws_iam_role.runtime_role, aws_iam_role_policy.runtime_role_policy, aws_iam_role_policy.runtime_slr_policy]
  create_duration = "20s"
}

resource "aws_iam_role_policy" "runtime_role_policy" {
  count = local.create_runtime && var.runtime_role_arn == null ? 1 : 0
  name  = "${random_string.solution_prefix.result}-bedrock-agent-runtime-policy"
  role  = aws_iam_role.runtime_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRImageAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtime/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*:log-stream:*"
        ]
      },
      {
        Sid    = "ECRTokenAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Resource = "*"
        Action   = "cloudwatch:PutMetricData"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "bedrock-agentcore"
          }
        }
      },
      {
        Sid    = "GetAgentAccessToken"
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:GetWorkloadAccessToken",
          "bedrock-agentcore:GetWorkloadAccessTokenForJWT",
          "bedrock-agentcore:GetWorkloadAccessTokenForUserId"
        ]
        Resource = [
          "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default",
          "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default/workload-identity/${random_string.solution_prefix.result}_${local.sanitized_runtime_name}-*"
        ]
      },
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
}

# AWS Bedrock Agent Core Runtime resource for container-based runtime
resource "awscc_bedrockagentcore_runtime" "agent_runtime_container" {
  count              = local.create_runtime && var.runtime_artifact_type == "container" ? 1 : 0
  agent_runtime_name = "${random_string.solution_prefix.result}_${local.sanitized_runtime_name}"
  description        = var.runtime_description
  role_arn           = var.runtime_role_arn != null ? var.runtime_role_arn : aws_iam_role.runtime_role[0].arn

  agent_runtime_artifact = {
    container_configuration = {
      container_uri = var.runtime_container_uri
    }
  }

  network_configuration = var.runtime_network_configuration != null ? {
    network_mode = var.runtime_network_mode
    network_mode_config = var.runtime_network_mode == "VPC" ? {
      security_groups = var.runtime_network_configuration.security_groups
      subnets         = var.runtime_network_configuration.subnets
    } : null
  } : null

  environment_variables = var.runtime_environment_variables

  authorizer_configuration = var.runtime_authorizer_configuration != null ? {
    custom_jwt_authorizer = {
      allowed_audience = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_audience
      allowed_clients  = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_clients
      discovery_url    = var.runtime_authorizer_configuration.custom_jwt_authorizer.discovery_url
    }
  } : null

  lifecycle_configuration = var.runtime_lifecycle_configuration != null ? {
    idle_runtime_session_timeout = var.runtime_lifecycle_configuration.idle_runtime_session_timeout
    max_lifetime                 = var.runtime_lifecycle_configuration.max_lifetime
  } : null

  request_header_configuration = var.runtime_request_header_configuration != null ? {
    request_header_allowlist = var.runtime_request_header_configuration.request_header_allowlist
  } : null

  protocol_configuration = var.runtime_protocol_configuration
  tags                   = local.merged_tags

  depends_on = [
    time_sleep.iam_role_propagation
  ]

  lifecycle {
    ignore_changes = [agent_runtime_artifact] #ignores container_uri updates
  }
}

# AWS Bedrock Agent Core Runtime resource for code-based runtime
resource "awscc_bedrockagentcore_runtime" "agent_runtime_code" {
  count              = local.create_runtime && var.runtime_artifact_type == "code" ? 1 : 0
  agent_runtime_name = "${random_string.solution_prefix.result}_${local.sanitized_runtime_name}"
  description        = var.runtime_description
  role_arn           = var.runtime_role_arn != null ? var.runtime_role_arn : aws_iam_role.runtime_role[0].arn

  agent_runtime_artifact = {
    code_configuration = {
      code = {
        s3 = {
          bucket     = var.runtime_code_s3_bucket
          prefix     = var.runtime_code_s3_prefix
          version_id = var.runtime_code_s3_version_id
        }
      }
      entry_point = var.runtime_code_entry_point
      runtime     = var.runtime_code_runtime_type
    }
  }

  network_configuration = var.runtime_network_configuration != null ? {
    network_mode = var.runtime_network_mode
    network_mode_config = var.runtime_network_mode == "VPC" ? {
      security_groups = var.runtime_network_configuration.security_groups
      subnets         = var.runtime_network_configuration.subnets
    } : null
  } : null

  environment_variables = var.runtime_environment_variables

  authorizer_configuration = var.runtime_authorizer_configuration != null ? {
    custom_jwt_authorizer = {
      allowed_audience = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_audience
      allowed_clients  = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_clients
      discovery_url    = var.runtime_authorizer_configuration.custom_jwt_authorizer.discovery_url
    }
  } : null

  protocol_configuration = var.runtime_protocol_configuration
  tags                   = local.merged_tags

  depends_on = [
    time_sleep.iam_role_propagation
  ]
}

# Reference for agent runtime ID
locals {
  agent_runtime_id = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].agent_runtime_id, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].agent_runtime_id, null)
}

# – Bedrock Agent Core Runtime Endpoint –

locals {
  create_runtime_endpoint = var.create_runtime_endpoint
  # Sanitize runtime endpoint name to ensure it follows the regex pattern ^[a-zA-Z][a-zA-Z0-9_]{0,47}$
  sanitized_runtime_endpoint_name = replace(var.runtime_endpoint_name, "-", "_")
}

resource "awscc_bedrockagentcore_runtime_endpoint" "agent_runtime_endpoint" {
  count            = local.create_runtime_endpoint ? 1 : 0
  name             = "${random_string.solution_prefix.result}_${local.sanitized_runtime_endpoint_name}"
  description      = var.runtime_endpoint_description
  agent_runtime_id = var.runtime_endpoint_agent_runtime_id != null ? var.runtime_endpoint_agent_runtime_id : local.agent_runtime_id
  tags             = var.runtime_endpoint_tags
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
module "runtime_tags" {
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

# Merge workspace tags with PGE tags
locals {
  merged_tags = merge(module.runtime_tags.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}