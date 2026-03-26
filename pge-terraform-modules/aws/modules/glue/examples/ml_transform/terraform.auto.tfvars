aws_region  = "us-west-2"
account_num = "056672152820"
aws_role    = "CloudAdmin"

# Tag variables

AppID              = "1001"                                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order = 8115205 #Order must be between 7 and 9 digits

optional_tags = { service = "glue" }

# Common variable name for resources

name = "example"

# Variables for Glue ml transform

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

# Variables for IAM Role

role_service    = ["glue.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::056672152820:policy/service-role/AWSGlueServiceRole-a0ks-ML"]

# lakeformation_permissions

permissions         = ["ALL"]
database_name       = "demo-db-dblp-acm"
database_catalog_id = "056672152820"