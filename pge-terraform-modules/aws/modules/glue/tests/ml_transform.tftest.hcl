run "ml_transform" {
  command = apply

  module {
    source = "./examples/ml_transform"
  }
}

variables {
  aws_region                 = "us-west-2"
  account_num                = "056672152820"
  aws_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  optional_tags              = { service = "glue" }
  name                       = "example"
  glue_database_name         = "demo-db-dblp-acm"
  table_name                 = "dblp_acm_records_csv"
  transform_type             = "FIND_MATCHES"
  accuracy_cost_trade_off    = 0.5
  precision_recall_trade_off = 0.5
  primary_key_column_name    = "id"
  glue_version               = "1.0"
  max_capacity               = null
  max_retries                = 1
  worker_type                = "G.2X"
  number_of_workers          = 3
  role_service               = ["glue.amazonaws.com"]
  iam_policy_arns            = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::056672152820:policy/service-role/AWSGlueServiceRole-a0ks-ML"]
  permissions                = ["ALL"]
  database_name              = "demo-db-dblp-acm"
  database_catalog_id        = "056672152820"
}
