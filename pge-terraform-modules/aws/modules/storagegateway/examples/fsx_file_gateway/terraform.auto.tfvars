account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


AppID              = "2102"                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
optional_tags      = { service = "storagegateway" }
Order              = 8115205 #Order must be between 7 and 9 digits

# scerets manager
secretsmanager_name                  = "storagegateway-activation-key"
secretsmanager_description           = "Activation key for storage gateway"
secret_version_enabled               = true
fsx_file_system_association_username = "fsx_association_username"
fsx_file_system_association_password = "fsx_association_password"
# Pass the activation key value in the parameter store
ssm_parameter_activation_key = "/storagegateway/activationkey"

# file gateway
name                  = "tf-test-fsx-file-system"
gateway_timezone      = "GMT-4:00"
gateway_type          = "FILE_FSX_SMB"
gateway_vpc_endpoint  = "vpce-0e12576fa3ac6b7d5"
smb_security_strategy = "MandatorySigning"
domain_name           = "pge.com"
password              = "password"
username              = "username"

# cloudwatch logs
# To avoid reaching the CloudWatch Logs resource policy size limit, prefix your CloudWatch Logs log group names with /aws/vendedlogs/. Refer: https://docs.aws.amazon.com/step-functions/latest/dg/bp-cwl.html
logs_name = "/aws/vendedlogs/sgw-fsx"

# cache
disk_node = "/dev/sdb"

# parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"

# smb_file_share
cache_stale_timeout_in_seconds = 300
timeouts = {
  create = "15m"
  delete = "20m"
  update = "15m"
}

# windows_file_system
file_system_type    = "windows"
storage_capacity    = 32
deployment_type     = "SINGLE_AZ_1"
storage_type        = "SSD"
throughput_capacity = 32
# The ID for an existing Microsoft Active Directory instance that the file system should join when it's created. 
windows_shared_active_directory_id = "d-92670c4e30"
file_access_audit_log_level        = "SUCCESS_AND_FAILURE"
file_share_access_audit_log_level  = "SUCCESS_AND_FAILURE"
skip_final_backup                  = true
file_system_timeouts = {
  create = "45m"
  update = "45m"
  delete = "60m"
}

# iam
aws_service = ["s3.amazonaws.com"]
policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]