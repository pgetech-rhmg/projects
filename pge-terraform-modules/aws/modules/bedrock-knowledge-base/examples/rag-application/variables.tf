#  Filename    : aws/modules/bedrock-knowledge-base/examples/rag-application/variables.tf
#  Date        : 19 Mar 2026
#  Author      : PGE
#  Description : Variables for RAG application example

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

####################################################
# Variables for Tags
####################################################

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "optional_tags" {
  description = "Optional tags to apply to resources"
  type        = map(string)
  default     = {}
}

####################################################
# General Configuration
####################################################

variable "app_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

####################################################
# Knowledge Base Configuration
####################################################

variable "knowledge_base_description" {
  description = "Description of the Bedrock Knowledge Base"
  type        = string
  default     = "Bedrock Knowledge Base for RAG applications with OpenSearch Serverless"
}

variable "embedding_model_id" {
  description = "ID of the Bedrock embedding model to use"
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "chunk_max_tokens" {
  description = "Maximum number of tokens per chunk"
  type        = number
  default     = 300
}

variable "chunk_overlap_percentage" {
  description = "Percentage overlap between chunks"
  type        = number
  default     = 20
}

####################################################
# OpenSearch Serverless Configuration
####################################################

variable "enable_standby_replicas" {
  description = "Enable standby replicas for OpenSearch Serverless collection (increases cost)"
  type        = bool
  default     = false
}

variable "collection_type" {
  description = "Type of OpenSearch Serverless collection"
  type        = string
  default     = "VECTORSEARCH"
}

variable "use_aws_owned_key" {
  description = "Use AWS-owned key for encryption (true) or customer managed KMS key (false)"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (if use_aws_owned_key is false)"
  type        = string
  default     = null
}

variable "allow_public_access" {
  description = "Allow public access to OpenSearch Serverless collection"
  type        = bool
  default     = true
}

variable "vpce_ids" {
  description = "List of VPC endpoint IDs for private access"
  type        = list(string)
  default     = []
}

variable "data_access_permissions" {
  description = "Data access permissions for OpenSearch collection"
  type        = list(string)
  default     = ["aoss:DescribeCollectionItems", "aoss:CreateCollectionItems"]
}

variable "index_permissions" {
  description = "Index permissions for OpenSearch collection"
  type        = list(string)
  default = [
    "aoss:UpdateIndex",
    "aoss:DescribeIndex",
    "aoss:ReadDocument",
    "aoss:WriteDocument",
    "aoss:CreateIndex"
  ]
}

variable "data_access_principals" {
  description = "Additional IAM principals to grant data access (beyond Terraform user, CloudAdmin, and KB role)"
  type        = list(string)
  default     = []
}

####################################################
# OpenSearch Index Configuration
####################################################

variable "index_number_of_shards" {
  description = "Number of shards for the OpenSearch index"
  type        = string
  default     = "2"
}

variable "index_number_of_replicas" {
  description = "Number of replicas for the OpenSearch index"
  type        = string
  default     = "1"
}

variable "index_knn_algo_param_ef_search" {
  description = "ef_search parameter for KNN algorithm"
  type        = string
  default     = "512"
}

variable "vector_dimension" {
  description = "Dimension of the vector embeddings (1024 for Titan v2, 1536 for Cohere v3)"
  type        = number
  default     = 1024
}

variable "vector_ef_construction" {
  description = "ef_construction parameter for HNSW index"
  type        = number
  default     = 512
}

variable "vector_m" {
  description = "m parameter for HNSW index (number of bi-directional links)"
  type        = number
  default     = 16
}

variable "vector_field_name" {
  description = "Name of the vector field in OpenSearch"
  type        = string
  default     = "bedrock-knowledge-base-default-vector"
}

variable "text_field_name" {
  description = "Name of the text field in OpenSearch"
  type        = string
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "metadata_field_name" {
  description = "Name of the metadata field in OpenSearch"
  type        = string
  default     = "AMAZON_BEDROCK_METADATA"
}

####################################################
# S3 Configuration
####################################################

variable "s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = string
  default     = "Enabled"
}

variable "s3_force_destroy" {
  description = "Allow Terraform to destroy bucket with objects"
  type        = bool
  default     = true
}

variable "s3_acl" {
  description = "S3 bucket ACL"
  type        = string
  default     = "private"
}

variable "s3_block_public_acls" {
  description = "Block public ACLs for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Block public bucket policies for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Ignore public ACLs for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_restrict_public_buckets" {
  description = "Restrict public bucket policies for S3 bucket"
  type        = bool
  default     = true
}

####################################################
# Data Source Configuration
####################################################

variable "create_data_source" {
  description = "Whether to create a data source for the knowledge base"
  type        = bool
  default     = true
}

variable "s3_inclusion_prefixes" {
  description = "S3 prefixes to include for data ingestion (empty list = all objects)"
  type        = list(string)
  default     = []
}

variable "chunking_strategy" {
  description = "Chunking strategy (FIXED_SIZE, HIERARCHICAL, SEMANTIC, NONE)"
  type        = string
  default     = "FIXED_SIZE"
}
