aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

# Tag variables

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits

# Variables for dms source endpoint

source_endpoint_id            = "test-source-manual-123"
source_endpoint_engine_name   = "sqlserver"
source_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
source_endpoint_database_name = "m1rf-cyber"
source_endpoint_ssl_mode      = "require"
source_endpoint_port          = "1433"
source_certificate_arn        = null # certifcate arn required if source_endpoint_ssl_mode if the value of source_endpoint_ssl_mode is "verify-ca" or "require"


# Variables for dms target endpoint

target_endpoint_id            = "test-target-manual-123"
target_endpoint_engine_name   = "sqlserver"
target_endpoint_server_name   = "m1rf-cyber.ctcxkxuqjgzd.us-west-2.rds.amazonaws.com"
target_endpoint_database_name = "m1rf-cyber"
target_endpoint_ssl_mode      = "require"
target_endpoint_username      = "testuser"
target_endpoint_password      = "password123"
target_endpoint_port          = "1433"
target_certificate_arn        = null # certifcate arn required if target_endpoint_ssl_mode if the value of target_endpoint_ssl_mode is "verify-ca" or "require"

#support resource
ssm_parameter_dms_username = "/dms/username"
ssm_parameter_dms_password = "/dms/password"

# KMS variables

kms_name        = "test-dms-manual-12111"
kms_description = "CMK for encrypting dms"

