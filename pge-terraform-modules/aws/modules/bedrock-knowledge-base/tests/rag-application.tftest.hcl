run "rag-application" {
  command = apply

  module {
    source = "./examples/rag-application"
  }
}

variables {
  account_num             = "750713712981"
  aws_region              = "us-west-2"
  aws_role                = "CloudAdmin"
  AppID                   = 1001
  Environment             = "Dev"
  DataClassification      = "Internal"
  CRIS                    = "Low"
  Notify                  = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                   = ["abc1", "def2", "ghi3"]
  Compliance              = ["None"]
  Order                   = 8115205
  app_prefix              = "tftest-kb"
  collection_type         = "VECTORSEARCH"
  enable_standby_replicas = false
  use_aws_owned_key       = true
  kms_key_arn             = null
  allow_public_access     = true
  vpce_ids                = []
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
  data_access_principals = [
    "arn:aws:sts::750713712981:assumed-role/AWSReservedSSO_CloudAdminNonProdAccess_165747fd3c43ab2d/R0K6@pge.com"
  ]
  index_number_of_shards         = "2"
  index_number_of_replicas       = "1"
  index_knn_algo_param_ef_search = "512"
  vector_dimension               = 1024
  vector_ef_construction         = 512
  vector_m                       = 16
  vector_field_name              = "bedrock-knowledge-base-default-vector"
  text_field_name                = "AMAZON_BEDROCK_TEXT_CHUNK"
  metadata_field_name            = "AMAZON_BEDROCK_METADATA"
  s3_versioning                  = "Enabled"
  s3_force_destroy               = true
  s3_acl                         = "private"
  s3_block_public_acls           = true
  s3_block_public_policy         = true
  s3_ignore_public_acls          = true
  s3_restrict_public_buckets     = true
  knowledge_base_description     = "Bedrock Knowledge Base with OpenSearch Serverless"
  embedding_model_id             = "amazon.titan-embed-text-v2:0"
  create_data_source             = true
  s3_inclusion_prefixes          = []
  chunking_strategy              = "FIXED_SIZE"
  chunk_max_tokens               = 300
  chunk_overlap_percentage       = 20
}
