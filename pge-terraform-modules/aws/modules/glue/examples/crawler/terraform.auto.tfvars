account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order = 8115205 #Order must be between 7 and 9 digits
optional_tags = {
  managed_by = "terraform"
}

#crawler
name = "iac-crawler"

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

#iam crawler
policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin", "arn:aws:iam::056672152820:policy/service-role/AWSGlueServiceRole-a0ks-music-EZCRC-dynamoDBPolicy"]
aws_service = ["glue.amazonaws.com"]

#lakeformation_permissions

permissions = ["ALL"]

database_name       = "testdb_03"
database_catalog_id = "056672152820"