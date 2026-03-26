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
secretsmanager_name        = "tf-test-storagegateway-activation-key"
secretsmanager_description = "Activation key for storage gateway"
secret_version_enabled     = true
# Pass the activation key value in the parameter store
ssm_parameter_activation_key = "/storagegateway/activationkey"

# file gateway
name                 = "tf-test-s3-file-system"
gateway_timezone     = "GMT-4:00"
gateway_type         = "FILE_S3"
gateway_vpc_endpoint = "vpce-0e12576fa3ac6b7d5"
day_of_month         = 1
day_of_week          = 0
hour_of_day          = 00
minute_of_hour       = 59

# cloudwatch logs
# To avoid reaching the CloudWatch Logs resource policy size limit, prefix your CloudWatch Logs log group names with /aws/vendedlogs/. Refer: https://docs.aws.amazon.com/step-functions/latest/dg/bp-cwl.html
logs_name = "/aws/vendedlogs/sgw-s3"

# cache
disk_node = "/dev/sdb"

# nfs_file_share
client_list                    = ["0.0.0.0/0"]
directory_mode                 = "0777"
file_mode                      = "0666"
group_id                       = 65534
owner_id                       = 65534
cache_stale_timeout_in_seconds = 300
timeouts = {
  create = "15m"
  delete = "20m"
  update = "15m"
}

# IAM
aws_service = ["storagegateway.amazonaws.com"]