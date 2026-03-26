aws_region  = "us-west-2"
account_num = "056672152820"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

# Tag variables
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits
optional_tags      = { service = "transfer-family" }

#parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"

#Common variable name for resources
name = "example"

#Variables for Transfer server
endpoint_type = "VPC"
directory_id  = "d-92670c4e30"

#Variables for iam
policy_arns = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
aws_service = ["transfer.amazonaws.com", "lambda.amazonaws.com"]

#Variables for Transfer workflow
source_file_location = "$${original.file}"
type1                = "COPY"
type2                = "CUSTOM"
type3                = "DELETE"
type4                = "TAG"
timeout_seconds      = 60

#Variables for aws_s3_bucket_object
bucket_object_key = "labels.csv"

#Lambda
description                = "testing aws lambda"
runtime                    = "python3.9"
handler                    = "lambda_function.lambda_handler"
local_zip_source_directory = "lambda_source_code"

#Variables for transfer access
external_id = "S-1-1-12-1234567890-1234567890-1234567890-1234"