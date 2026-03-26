########################################
# AWS Account Configuration
########################################
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

########################################
# PGE Required Tags
########################################
AppID              = 1001
Environment        = "Dev"
DataClassification = "Internal"
CRIS               = "Low"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"]
Compliance         = ["None"]
Order              = 8115205



########################################
# General Configuration
########################################
app_prefix = "r0k6test"

################################################################################
# Resource Creation Order (Dependency Flow)
################################################################################

################################################################################
#  OpenSearch Serverless Configuration (Depends on IAM Role)
################################################################################
collection_type         = "VECTORSEARCH"
enable_standby_replicas = false # Enable for production (increases cost)

# Encryption Configuration
use_aws_owned_key = true # Use AWS-owned keys (free) or customer KMS key
kms_key_arn       = null # Set if use_aws_owned_key = false

# Network Configuration  
allow_public_access = true # Set to false for private access via VPC endpoints
vpce_ids            = []   # VPC endpoint IDs if allow_public_access = false

# Data Access Configuration
data_access_permissions = [
  "aoss:CreateCollectionItems",
  "aoss:DeleteCollectionItems",
  "aoss:UpdateCollectionItems",
  "aoss:DescribeCollectionItems"
]
index_permissions = [
  "aoss:CreateIndex",
  "aoss:DeleteIndex",
  "aoss:UpdateIndex",
  "aoss:DescribeIndex",
  "aoss:ReadDocument",
  "aoss:WriteDocument"
]

# Additional principals for OpenSearch dashboard access (optional)
# Note: Terraform user, CloudAdmin role, and KB role are auto-included
data_access_principals = [
  "arn:aws:sts::750713712981:assumed-role/AWSReservedSSO_CloudAdminNonProdAccess_165747fd3c43ab2d/R0K6@pge.com"
]

################################################################################
#  OpenSearch Index Configuration (Depends on AOSS Collection)
################################################################################
# Optimized for Titan v2 embeddings (1024 dimensions)
index_number_of_shards         = "2"
index_number_of_replicas       = "1"
index_knn_algo_param_ef_search = "512"
vector_dimension               = 1024
vector_ef_construction         = 512
vector_m                       = 16
vector_field_name              = "bedrock-knowledge-base-default-vector"
text_field_name                = "AMAZON_BEDROCK_TEXT_CHUNK"
metadata_field_name            = "AMAZON_BEDROCK_METADATA"

################################################################################
#  S3 Bucket Configuration (Independent - Can Be Created Anytime)
################################################################################
s3_versioning              = "Enabled"
s3_force_destroy           = true
s3_acl                     = "private"
s3_block_public_acls       = true
s3_block_public_policy     = true
s3_ignore_public_acls      = true
s3_restrict_public_buckets = true

################################################################################
#  Bedrock Knowledge Base Configuration (Depends on All Above)
################################################################################
knowledge_base_description = "Bedrock Knowledge Base with OpenSearch Serverless"
embedding_model_id         = "amazon.titan-embed-text-v2:0" # 1024-dim embeddings

################################################################################
#  Data Source Configuration (Part of Knowledge Base)
################################################################################
create_data_source       = true
s3_inclusion_prefixes    = []
chunking_strategy        = "FIXED_SIZE"
chunk_max_tokens         = 300
chunk_overlap_percentage = 20
