#
# Filename    : aws/modules/opensearch/examples/opensearch-serverless/main.tf
# Date        : 09 Mar 2026
# Author      : PGE
# Description : Example Terraform configuration for OpenSearch Serverless (AOSS) collection
#               This example demonstrates:
#               - VectorSearch collection for RAG/Knowledge Base use cases
#               - VPC endpoint for private access
#               - Customer-managed KMS encryption (PGE standard)
#               - Proper IAM access policies
#               - PGE tag compliance



locals {
  # Generate unique collection name with prefix and random suffix
  collection_name = "${var.app_prefix}-${random_string.suffix.result}"
  optional_tags   = var.optional_tags
}

################################################################################
# Supporting Resources
################################################################################

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

################################################################################
# VPC and Subnet Data from SSM Parameters (PGE Standard)
################################################################################

# Retrieve VPC ID from SSM parameter
data "aws_ssm_parameter" "vpc_id" {
  count = var.create_vpce && var.use_ssm_for_network ? 1 : 0
  name  = var.vpc_id_ssm_parameter
}

# Retrieve subnet IDs from SSM parameter (comma-separated list)
data "aws_ssm_parameter" "subnet_ids" {
  count = var.create_vpce && var.use_ssm_for_network ? 1 : 0
  name  = var.subnet_ids_ssm_parameter
}

# Retrieve security group IDs from SSM parameter (comma-separated list)
data "aws_ssm_parameter" "security_group_ids" {
  count = var.create_vpce && var.use_ssm_for_network ? 1 : 0
  name  = var.security_group_ids_ssm_parameter
}

locals {
  # Use SSM parameters if enabled, otherwise use variables
  vpc_id             = var.create_vpce ? (var.use_ssm_for_network ? data.aws_ssm_parameter.vpc_id[0].value : var.vpc_id) : null
  subnet_ids         = var.create_vpce ? (var.use_ssm_for_network ? split(",", data.aws_ssm_parameter.subnet_ids[0].value) : var.subnet_ids) : []
  security_group_ids = var.create_vpce ? (var.use_ssm_for_network ? split(",", data.aws_ssm_parameter.security_group_ids[0].value) : var.security_group_ids) : []
}

################################################################################
# PGE Tags Module
################################################################################

# PGE required tags - using centralized tags module
module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = tonumber(replace(var.AppID, "APP-", ""))
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

################################################################################
# KMS Key for Encryption (PGE Standard)
################################################################################

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# Uncomment the following lines to create the KMS key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"
#
#   name        = "alias/${var.app_prefix}-aoss-key"
#   description = "CMK for encrypting OpenSearch Serverless collection"
#   aws_role    = var.aws_role
#   kms_role    = var.kms_role
#
#   # Key policy allows OpenSearch Serverless service to use the key
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "Enable IAM User Permissions"
#         Effect = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         }
#         Action   = "kms:*"
#         Resource = "*"
#       },
#       {
#         Sid    = "Allow OpenSearch Serverless"
#         Effect = "Allow"
#         Principal = {
#           Service = "aoss.amazonaws.com"
#         }
#         Action = [
#           "kms:Decrypt",
#           "kms:CreateGrant",
#           "kms:DescribeKey"
#         ]
#         Resource = "*"
#         Condition = {
#           StringEquals = {
#             "kms:ViaService" = "aoss.${data.aws_region.current.name}.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
#
#   tags = merge(module.tags.tags, local.optional_tags)
# }

################################################################################
# VPC Endpoint for Private Access (Optional)
################################################################################

# VPC Endpoint for OpenSearch Serverless
# Allows private connectivity from VPC without internet gateway
module "opensearch_vpce" {
  count   = var.create_vpce ? 1 : 0
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  service_name        = "com.amazonaws.${data.aws_region.current.name}.aoss"
  vpc_id              = local.vpc_id
  subnet_ids          = local.subnet_ids
  security_group_ids  = local.security_group_ids
  private_dns_enabled = true
  auto_accept         = true
  policy              = "{}" # Empty policy allows all actions

  tags = merge(module.tags.tags, local.optional_tags, {
    Name = "${var.app_prefix}-aoss-vpce"
  })
}

################################################################################
# OpenSearch Serverless Collection
################################################################################

# OpenSearch Serverless Collection for Vector Search (RAG/Knowledge Base)
module "opensearch_serverless" {
  source = "../../modules/opensearch-serverless"

  collection_name        = local.collection_name
  collection_type        = var.collection_type
  collection_description = "OpenSearch Serverless collection for ${var.app_prefix} - ${var.collection_type}"
  standby_replicas       = var.enable_standby_replicas ? "ENABLED" : "DISABLED"

  # Encryption Policy - Using AWS-owned keys for testing
  # For production with customer-managed KMS, uncomment the kms_key module above and change:
  # use_aws_owned_key = false
  # kms_key_arn       = module.kms_key.key_arn
  create_encryption_policy      = true
  use_aws_owned_key             = true # Change to false when using customer-managed KMS
  kms_key_arn                   = null # Set to module.kms_key.key_arn when using customer-managed KMS
  encryption_policy_description = "Encryption policy for ${var.app_prefix} AOSS collection"

  # Network Policy - Controls access via VPC endpoint or public internet
  create_network_policy      = true
  allow_public_access        = var.allow_public_access
  vpce_ids                   = var.create_vpce ? [module.opensearch_vpce[0].vpc_endpoint_id] : var.vpce_ids
  network_policy_description = "Network policy for ${var.app_prefix} AOSS collection"

  # Data Access Policy - IAM permissions for collection and indexes
  create_data_access_policy      = true
  data_access_policy_description = "Data access policy for ${var.app_prefix} AOSS collection"

  # Grant permissions to specified IAM principals
  data_access_principals = coalescelist(
    var.data_access_principals,
    # Default to current user/role if no principals specified (for testing)
    [data.aws_caller_identity.current.arn]
  )

  # Collection-level permissions (manage collection metadata)
  data_access_permissions = var.data_access_permissions

  # Index-level permissions (CRUD operations on indexes and documents)
  index_permissions = var.index_permissions

  # PGE required tags
  tags = merge(module.tags.tags, local.optional_tags)

  # Ensure VPC endpoint is created before collection
  depends_on = [module.opensearch_vpce]
}

################################################################################
# Outputs for Integration
################################################################################

# These outputs can be used to integrate with:
# - Amazon Bedrock Knowledge Base
# - Custom RAG applications
# - Data ingestion pipelines
