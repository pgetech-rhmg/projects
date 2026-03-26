#
# Filename    : aws/modules/bedrock-knowledge-base/examples/rag-application/main.tf
# Date        : 11 Mar 2026
# Author      : PGE
# Description : RAG application using Knowledge Bases for Amazon Bedrock
#

################################################################################
# Data Sources
################################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

################################################################################
# PGE Tags Module
################################################################################

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

################################################################################
# IAM Policies (Created Before OpenSearch to Avoid Circular Dependency)
################################################################################

# OpenSearch policy with wildcard (data access policy controls actual access)
data "aws_iam_policy_document" "kb_opensearch" {
  statement {
    sid    = "OpenSearchServerlessAPIAccess"
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = [
      "arn:aws:aoss:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:collection/*"
    ]
  }
}

module "kb_opensearch_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "${var.app_prefix}-aoss-policy"
  description = "Allows Bedrock KB to access OpenSearch Serverless"
  policy      = [data.aws_iam_policy_document.kb_opensearch.json]
  tags        = merge(module.tags.tags, var.optional_tags)
}

# Bedrock model invocation policy
data "aws_iam_policy_document" "kb_bedrock" {
  statement {
    sid    = "BedrockInvokeModel"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.id}::foundation-model/*"
    ]
  }
}

module "kb_bedrock_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "${var.app_prefix}-bedrock-policy"
  description = "Allows Bedrock KB to invoke foundation models"
  policy      = [data.aws_iam_policy_document.kb_bedrock.json]
  tags        = merge(module.tags.tags, var.optional_tags)
}

# IAM Role for Bedrock KB
module "kb_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.app_prefix}-role"
  description = "IAM role for Bedrock Knowledge Base"
  aws_service = ["bedrock.amazonaws.com"]
  policy_arns = [
    module.kb_opensearch_policy.arn,
    module.kb_bedrock_policy.arn
  ]
  tags = merge(module.tags.tags, var.optional_tags)
}

################################################################################
# OpenSearch Serverless Collection
################################################################################

module "opensearch_serverless" {
  source  = "app.terraform.io/pgetech/opensearch/aws//modules/opensearch-serverless"
  version = "0.1.3"

  collection_name        = "${var.app_prefix}-aoss"
  collection_type        = var.collection_type
  collection_description = "OpenSearch Serverless for ${var.app_prefix} Bedrock KB"
  standby_replicas       = var.enable_standby_replicas ? "ENABLED" : "DISABLED"

  # Encryption
  create_encryption_policy      = true
  use_aws_owned_key             = var.use_aws_owned_key
  kms_key_arn                   = var.kms_key_arn
  encryption_policy_description = "Encryption policy for ${var.app_prefix}"

  # Network
  create_network_policy      = true
  allow_public_access        = var.allow_public_access
  vpce_ids                   = var.vpce_ids
  network_policy_description = "Network policy for ${var.app_prefix}"

  # Data Access - Include TFCBProvisioningRole and KB role
  create_data_access_policy      = true
  data_access_policy_description = "Data access policy for ${var.app_prefix}"
  data_access_principals = distinct(concat(
    [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TFCBProvisioningRole",
      module.kb_role.arn
    ],
    var.data_access_principals
  ))
  data_access_permissions = var.data_access_permissions
  index_permissions       = var.index_permissions

  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [module.kb_role]
}

################################################################################
# Wait for OpenSearch Collection and Policies to Propagate
################################################################################

resource "time_sleep" "wait_for_aoss" {
  depends_on = [module.opensearch_serverless]

  create_duration = "90s"
}

################################################################################
# OpenSearch Index
################################################################################

resource "opensearch_index" "bedrock_kb" {
  name                           = "${var.app_prefix}-bedrock-kb-index"
  number_of_shards               = var.index_number_of_shards
  number_of_replicas             = var.index_number_of_replicas
  index_knn                      = true
  index_knn_algo_param_ef_search = var.index_knn_algo_param_ef_search

  mappings = jsonencode({
    properties = {
      (var.vector_field_name) = {
        type      = "knn_vector"
        dimension = var.vector_dimension
        method = {
          name       = "hnsw"
          engine     = "faiss"
          space_type = "l2"
          parameters = {
            ef_construction = var.vector_ef_construction
            m               = var.vector_m
          }
        }
      }
      "AMAZON_BEDROCK_METADATA" = {
        type  = "text"
        index = false
      }
      "AMAZON_BEDROCK_TEXT_CHUNK" = {
        type  = "text"
        index = true
      }
      "AMAZON_BEDROCK_TEXT" = {
        type = "text"
        fields = {
          keyword = { type = "keyword" }
        }
      }
      "id" = {
        type = "text"
        fields = {
          keyword = {
            type         = "keyword"
            ignore_above = 256
          }
        }
      }
      "x-amz-bedrock-kb-data-source-id" = {
        type = "text"
        fields = {
          keyword = { type = "keyword" }
        }
      }
      "x-amz-bedrock-kb-document-page-number" = {
        type = "long"
      }
      "x-amz-bedrock-kb-source-uri" = {
        type = "text"
        fields = {
          keyword = { type = "keyword" }
        }
      }
    }
  })

  force_destroy = true

  depends_on = [time_sleep.wait_for_aoss]
}

################################################################################
# S3 Bucket
################################################################################

module "kb_s3_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.2"

  bucket_name   = "${var.app_prefix}-kb-data"
  versioning    = var.s3_versioning
  force_destroy = var.s3_force_destroy
  acl           = var.s3_acl

  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets

  kms_key_arn = null

  tags = merge(module.tags.tags, var.optional_tags)
}

################################################################################
# S3 Policy and Attachment
################################################################################

data "aws_iam_policy_document" "kb_s3" {
  statement {
    sid       = "S3ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.kb_s3_bucket.arn]
  }

  statement {
    sid       = "S3GetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.kb_s3_bucket.arn}/*"]
  }
}

module "kb_s3_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "${var.app_prefix}-s3-policy"
  description = "Allows Bedrock KB to read from S3"
  policy      = [data.aws_iam_policy_document.kb_s3.json]
  tags        = merge(module.tags.tags, var.optional_tags)

  depends_on = [module.kb_s3_bucket]
}

resource "aws_iam_role_policy_attachment" "kb_s3" {
  role       = module.kb_role.name
  policy_arn = module.kb_s3_policy.arn
}

################################################################################
# Bedrock Knowledge Base
################################################################################

module "bedrock_kb" {
  source = "../.."

  knowledge_base_name        = var.app_prefix
  knowledge_base_description = var.knowledge_base_description
  kb_role_arn                = module.kb_role.arn

  embedding_model_id = var.embedding_model_id

  opensearch_collection_arn    = module.opensearch_serverless.collection_arn
  opensearch_vector_index_name = "${var.app_prefix}-bedrock-kb-index"
  vector_field_name            = var.vector_field_name
  text_field_name              = var.text_field_name
  metadata_field_name          = var.metadata_field_name

  create_data_source        = var.create_data_source
  data_source_name          = "${var.app_prefix}-kb-s3-source"
  data_source_description   = "S3 data source for ${var.app_prefix}"
  s3_data_source_bucket_arn = module.kb_s3_bucket.arn
  s3_inclusion_prefixes     = var.s3_inclusion_prefixes

  chunking_strategy        = var.chunking_strategy
  chunk_max_tokens         = var.chunk_max_tokens
  chunk_overlap_percentage = var.chunk_overlap_percentage

  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    opensearch_index.bedrock_kb,
    aws_iam_role_policy_attachment.kb_s3
  ]
}
