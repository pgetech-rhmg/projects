/*
 * # AWS Bedrock Knowledge Base Module
 * Terraform module for deploying Amazon Bedrock Knowledge Base 
*/
#
#  Filename    : aws/modules/bedrock-knowledge-base/main.tf
#  Date        : 11 Mar 2026
#  Author      : PGE
#  Description : Bedrock Knowledge Base with RAG capabilities, OpenSearch Serverless, and S3 integration

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Description : Default for Tags

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# Get current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id
  partition  = data.aws_partition.current.partition
}

#########################################
# Bedrock Knowledge Base
#########################################

resource "aws_bedrockagent_knowledge_base" "kb" {
  name        = var.knowledge_base_name
  description = var.knowledge_base_description
  role_arn    = var.kb_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.embedding_model_id}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = var.opensearch_collection_arn
      vector_index_name = var.opensearch_vector_index_name
      field_mapping {
        metadata_field = var.metadata_field_name
        text_field     = var.text_field_name
        vector_field   = var.vector_field_name
      }
    }
  }

  tags = local.module_tags
}

#########################################
# Bedrock Knowledge Base Data Source
#########################################

resource "aws_bedrockagent_data_source" "kb_data_source" {
  count = var.create_data_source ? 1 : 0

  knowledge_base_id = aws_bedrockagent_knowledge_base.kb.id
  name              = var.data_source_name
  description       = var.data_source_description

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.s3_data_source_bucket_arn

      # Optional: Specify inclusion prefixes for selective ingestion
      inclusion_prefixes = length(var.s3_inclusion_prefixes) > 0 ? var.s3_inclusion_prefixes : null
    }
  }

  # Chunking strategy configuration
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = var.chunking_strategy

      # Fixed size chunking configuration
      dynamic "fixed_size_chunking_configuration" {
        for_each = var.chunking_strategy == "FIXED_SIZE" ? [1] : []
        content {
          max_tokens         = var.chunk_max_tokens
          overlap_percentage = var.chunk_overlap_percentage
        }
      }

      # Hierarchical chunking configuration
      dynamic "hierarchical_chunking_configuration" {
        for_each = var.chunking_strategy == "HIERARCHICAL" ? [1] : []
        content {
          level_configuration {
            max_tokens = var.hierarchical_parent_max_tokens
          }
          level_configuration {
            max_tokens = var.hierarchical_child_max_tokens
          }
          overlap_tokens = var.hierarchical_overlap_tokens
        }
      }

      # Semantic chunking configuration
      dynamic "semantic_chunking_configuration" {
        for_each = var.chunking_strategy == "SEMANTIC" ? [1] : []
        content {
          max_token                       = var.semantic_max_tokens
          buffer_size                     = var.semantic_buffer_size
          breakpoint_percentile_threshold = var.semantic_breakpoint_threshold
        }
      }
    }
  }

  depends_on = [
    aws_bedrockagent_knowledge_base.kb
  ]
}
