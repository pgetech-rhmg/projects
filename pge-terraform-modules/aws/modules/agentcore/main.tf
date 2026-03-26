/*
 * AWS Bedrock AgentCore Module
 *
 * ## Overview
 *
 * Terraform module for deploying **AWS Bedrock Agent Core** infrastructure to build, run, and scale AI-powered agents with custom runtimes, memory management, and gateway integrations.
 *
 * This module provisions the complete infrastructure stack for Amazon Bedrock Agent Core, enabling you to:
 *
 * - Deploy Custom Agent Runtimes - Container or code-based runtimes with VPC isolation
 * - Configure Agent Memory - DynamoDB-backed persistent memory with configurable retention policies
 * - Set Up Gateway Targets - API Gateway integrations for agent endpoints
 * - Enable Agent Tools - Browser automation and code interpreter capabilities
 * - Manage Workload Identity - IAM role federation for secure agent execution
 *
 * ## Key Features
 *
 * - Multi-Framework Support: Compatible with LangChain, CrewAI, AutoGPT, Haystack, and custom frameworks
 * - Flexible Runtime Options: Container-based (ECR) or code-based (Lambda) runtime deployment
 * - VPC Integration: Secure agent runtime execution within your VPC with configurable security groups
 * - Memory Management: Configurable memory strategies (session-based, entity-based, user-based)
 * - Built-in CI/CD: Automated build and deployment pipelines with WIZ security scanning
 * - Production-Ready: KMS encryption, tagging standards, and PGE compliance built-in
 *
 * ## Documentation
 *
 * - Wiki: [Bedrock AgentCore Documentation](https://wiki.comp.pge.com/display/CCE/AWS+Bedrock+AgentCore)
 * - Examples: Complete working examples in `examples/agent_runtime/`
 * - Encryption: [Terraform Modules and KMS](https://wiki.comp.pge.com/display/CCE/Terraform+Modules+and+KMS)
 *
 * ## Quick Start
 *
 * ```hcl
 * module "bedrock_agent" {
 *   source  = "app.terraform.io/pgetech/agentcore/aws"
 *   version = "~> 0.1.0"
 *
 *   # Runtime Configuration
 *   create_runtime        = true
 *   runtime_name          = "my-ai-agent-runtime"
 *   runtime_container_uri = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-agent:latest"
 *   
 *   runtime_network_configuration = {
 *     security_groups = ["sg-12345678"]
 *     subnets         = ["subnet-abc123", "subnet-def456"]
 *   }
 *
 *   # Memory Configuration
 *   create_memory = true
 *   memory_name   = "my-agent-memory"
 *   memory_type   = "DYNAMODB"
 *
 *   # Agent Configuration
 *   create_agent      = true
 *   agent_name        = "my-ai-agent"
 *   agent_instruction = "You are a helpful AI assistant"
 * }
 * ```
 *
 * Source can be found at https://github.com/pgetech/pge-terraform-modules
 *
 * To use with encryption please refer https://wiki.comp.pge.com/display/CCE/Terraform+Modules+and+KMS
 */

# – Bedrock Agent Core Runtime –
resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  namespace                     = "ccoe-tf-developers"
  module_tags                   = merge(coalesce(var.runtime_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  runtime_endpoint_tags_merged  = merge(coalesce(var.runtime_endpoint_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  memory_tags_merged            = merge(coalesce(var.memory_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  gateway_tags_merged           = merge(coalesce(var.gateway_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  browser_tags_merged           = merge(coalesce(var.browser_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  code_interpreter_tags_merged  = merge(coalesce(var.code_interpreter_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  workload_identity_tags_merged = merge(coalesce(var.workload_identity_tags, {}), { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  create_runtime = var.create_runtime
  # Sanitize runtime name to ensure it follows the regex pattern ^[a-zA-Z][a-zA-Z0-9_]{0,47}$
  sanitized_runtime_name = replace(var.runtime_name, "-", "_")
}

# AWS Bedrock Agent Core Runtime resource for container-based runtime
resource "awscc_bedrockagentcore_runtime" "agent_runtime_container" {
  count              = local.create_runtime && var.runtime_artifact_type == "container" ? 1 : 0
  agent_runtime_name = "${random_string.solution_prefix.result}_${local.sanitized_runtime_name}"
  description        = var.runtime_description
  role_arn           = var.runtime_role_arn != null ? var.runtime_role_arn : aws_iam_role.runtime_role[0].arn
  depends_on = [
    aws_iam_role.runtime_role,
    aws_iam_role_policy.runtime_role_policy,
    aws_iam_role_policy.runtime_slr_policy,
    time_sleep.iam_role_propagation
  ]
  agent_runtime_artifact = {
    container_configuration = {
      container_uri = var.runtime_container_uri
    }
  }
  network_configuration = {
    network_mode = var.runtime_network_mode
    network_mode_config = var.runtime_network_mode == "VPC" ? {
      security_groups = var.runtime_network_configuration.security_groups
      subnets         = var.runtime_network_configuration.subnets
    } : null
  }
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
  tags                   = local.module_tags
}

# AWS Bedrock Agent Core Runtime resource for code-based runtime
resource "awscc_bedrockagentcore_runtime" "agent_runtime_code" {
  count              = local.create_runtime && var.runtime_artifact_type == "code" ? 1 : 0
  agent_runtime_name = "${random_string.solution_prefix.result}_${local.sanitized_runtime_name}"
  description        = var.runtime_description
  role_arn           = var.runtime_role_arn != null ? var.runtime_role_arn : aws_iam_role.runtime_role[0].arn
  depends_on = [
    aws_iam_role.runtime_role,
    aws_iam_role_policy.runtime_role_policy,
    aws_iam_role_policy.runtime_slr_policy,
    time_sleep.iam_role_propagation
  ]
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
  network_configuration = {
    network_mode = var.runtime_network_mode
    network_mode_config = var.runtime_network_mode == "VPC" ? {
      security_groups = var.runtime_network_configuration.security_groups
      subnets         = var.runtime_network_configuration.subnets
    } : null
  }
  environment_variables = var.runtime_environment_variables
  authorizer_configuration = var.runtime_authorizer_configuration != null ? {
    custom_jwt_authorizer = {
      allowed_audience = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_audience
      allowed_clients  = var.runtime_authorizer_configuration.custom_jwt_authorizer.allowed_clients
      discovery_url    = var.runtime_authorizer_configuration.custom_jwt_authorizer.discovery_url
    }
  } : null
  protocol_configuration = var.runtime_protocol_configuration
  tags                   = local.module_tags
}

# Reference for agent runtime ID
locals {
  agent_runtime_id = var.runtime_artifact_type == "container" ? try(awscc_bedrockagentcore_runtime.agent_runtime_container[0].agent_runtime_id, null) : try(awscc_bedrockagentcore_runtime.agent_runtime_code[0].agent_runtime_id, null)
}

# IAM Role for Agent Runtime
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
  tags                 = local.module_tags
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
  tags             = local.runtime_endpoint_tags_merged
}
