#  Filename    : aws/modules/bedrock-knowledge-base/variables.tf
#  Date        : 11 Mar 2026
#  Author      : PGE
#  Description : Variables for Bedrock Knowledge Base module

#########################################
# PGE Required Tags
#########################################

variable "tags" {
  description = "Map of mandatory PGE tags to apply to all resources. Must include: AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order"
  type        = map(string)
}

# Validate PGE required tags
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#########################################
# Knowledge Base Configuration
#########################################

variable "knowledge_base_name" {
  description = "Name of the Bedrock Knowledge Base"
  type        = string
}

variable "knowledge_base_description" {
  description = "Description of the Bedrock Knowledge Base"
  type        = string
  default     = "Bedrock Knowledge Base for RAG applications"
}

variable "kb_role_arn" {
  description = "ARN of the IAM role for the Knowledge Base to assume. Must have permissions for S3, OpenSearch Serverless, Bedrock model invocation, and optionally KMS."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@_-]+(/[a-zA-Z0-9+=,.@_-]+)*$", var.kb_role_arn))
    error_message = "Must be a valid IAM role ARN. Format: arn:aws:iam::{account-id}:role/{role-name} or arn:aws:iam::{account-id}:role/{path}/{role-name}"
  }
}

#########################################
# Embedding Model Configuration
#########################################

variable "embedding_model_id" {
  description = "ID of the Bedrock embedding model to use. Common values: amazon.titan-embed-text-v1, amazon.titan-embed-text-v2:0, cohere.embed-english-v3, cohere.embed-multilingual-v3"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

#########################################
# OpenSearch Serverless Configuration
#########################################

variable "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:aoss:[a-z0-9-]+:[0-9]{12}:collection/[a-z0-9]{20,}$", var.opensearch_collection_arn))
    error_message = "Must be a valid OpenSearch Serverless collection ARN."
  }
}

variable "opensearch_vector_index_name" {
  description = "Name of the vector index in the OpenSearch Serverless collection"
  type        = string
}

variable "vector_field_name" {
  description = "Name of the vector field in OpenSearch index"
  type        = string
  default     = "AMAZON_BEDROCK_VECTOR"
}

variable "text_field_name" {
  description = "Name of the text field in OpenSearch index"
  type        = string
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "metadata_field_name" {
  description = "Name of the metadata field in OpenSearch index"
  type        = string
  default     = "AMAZON_BEDROCK_METADATA"
}

#########################################
# S3 Data Source Configuration
#########################################

variable "s3_data_source_bucket_arn" {
  description = "ARN of the S3 bucket containing knowledge base documents"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:s3:::[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.s3_data_source_bucket_arn))
    error_message = "Must be a valid S3 bucket ARN."
  }
}

variable "s3_inclusion_prefixes" {
  description = "List of S3 prefixes to include for data ingestion. Leave empty to include all objects in the bucket"
  type        = list(string)
  default     = []
}

#########################################
# Data Source Configuration
#########################################

variable "create_data_source" {
  description = "Whether to create a data source for the knowledge base"
  type        = bool
  default     = true
}

variable "data_source_name" {
  description = "Name of the data source"
  type        = string
  default     = "s3-data-source"
}

variable "data_source_description" {
  description = "Description of the data source"
  type        = string
  default     = "S3 data source for Bedrock Knowledge Base"
}

#########################################
# Chunking Strategy Configuration
#########################################

variable "chunking_strategy" {
  description = "Chunking strategy for document processing. Valid values: FIXED_SIZE, HIERARCHICAL, SEMANTIC, NONE"
  type        = string
  default     = "FIXED_SIZE"
  validation {
    condition     = contains(["FIXED_SIZE", "HIERARCHICAL", "SEMANTIC", "NONE"], var.chunking_strategy)
    error_message = "Valid values for chunking_strategy are FIXED_SIZE, HIERARCHICAL, SEMANTIC, or NONE."
  }
}

# Fixed Size Chunking Configuration
variable "chunk_max_tokens" {
  description = "Maximum number of tokens per chunk for FIXED_SIZE strategy"
  type        = number
  default     = 300
  validation {
    condition     = var.chunk_max_tokens >= 20 && var.chunk_max_tokens <= 8192
    error_message = "chunk_max_tokens must be between 20 and 8192."
  }
}

variable "chunk_overlap_percentage" {
  description = "Percentage of overlap between chunks for FIXED_SIZE strategy"
  type        = number
  default     = 20
  validation {
    condition     = var.chunk_overlap_percentage >= 1 && var.chunk_overlap_percentage <= 99
    error_message = "chunk_overlap_percentage must be between 1 and 99."
  }
}

# Hierarchical Chunking Configuration
variable "hierarchical_parent_max_tokens" {
  description = "Maximum tokens for parent chunks in HIERARCHICAL strategy"
  type        = number
  default     = 1500
  validation {
    condition     = var.hierarchical_parent_max_tokens >= 20 && var.hierarchical_parent_max_tokens <= 8192
    error_message = "hierarchical_parent_max_tokens must be between 20 and 8192."
  }
}

variable "hierarchical_child_max_tokens" {
  description = "Maximum tokens for child chunks in HIERARCHICAL strategy"
  type        = number
  default     = 300
  validation {
    condition     = var.hierarchical_child_max_tokens >= 20 && var.hierarchical_child_max_tokens <= 8192
    error_message = "hierarchical_child_max_tokens must be between 20 and 8192."
  }
}

variable "hierarchical_overlap_tokens" {
  description = "Number of overlapping tokens between hierarchical chunks"
  type        = number
  default     = 60
  validation {
    condition     = var.hierarchical_overlap_tokens >= 1
    error_message = "hierarchical_overlap_tokens must be at least 1."
  }
}

# Semantic Chunking Configuration
variable "semantic_max_tokens" {
  description = "Maximum tokens per semantic chunk"
  type        = number
  default     = 300
  validation {
    condition     = var.semantic_max_tokens >= 20 && var.semantic_max_tokens <= 8192
    error_message = "semantic_max_tokens must be between 20 and 8192."
  }
}

variable "semantic_buffer_size" {
  description = "Buffer size for semantic chunking"
  type        = number
  default     = 1
  validation {
    condition     = var.semantic_buffer_size >= 0
    error_message = "semantic_buffer_size must be non-negative."
  }
}

variable "semantic_breakpoint_threshold" {
  description = "Breakpoint percentile threshold for semantic chunking (0-100)"
  type        = number
  default     = 95
  validation {
    condition     = var.semantic_breakpoint_threshold >= 0 && var.semantic_breakpoint_threshold <= 100
    error_message = "semantic_breakpoint_threshold must be between 0 and 100."
  }
}
