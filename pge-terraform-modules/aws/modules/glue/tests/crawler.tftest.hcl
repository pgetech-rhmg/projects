run "crawler" {
  command = apply

  module {
    source = "./examples/crawler"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    managed_by = "terraform"
  }
  name                                  = "iac-crawler"
  glue_crawler_database_name            = "testdb_03"
  glue_crawler_table_prefix_s3          = "iac_s3_"
  glue_crawler_table_prefix_dynamodb    = "iac_dynamodb_"
  glue_crawler_table_prefix_s3_dynamodb = "iac_s3_dynamodb_"
  glue_crawler_schedule                 = "cron(15 10 * * ? *)"
  glue_crawler_schema_change_policy = {
    update_behavior = "UPDATE_IN_DATABASE"
  }
  glue_crawler_lineage_configuration = {
    crawler_lineage_settings = "DISABLE"
  }
  glue_crawler_recrawl_policy = {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
  s3_target = [{
    path = "s3://test-iac-s3-bucket/read"
  }]
  dynamodb_target = [{
    path = "a0ks-music"
  }]
  policy_arns         = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin", "arn:aws:iam::056672152820:policy/service-role/AWSGlueServiceRole-a0ks-music-EZCRC-dynamoDBPolicy"]
  aws_service         = ["glue.amazonaws.com"]
  permissions         = ["ALL"]
  database_name       = "testdb_03"
  database_catalog_id = "056672152820"
}
