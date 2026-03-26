account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "DatabaseAdmin"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits
optional_tags = {
  managed_by = "terraform"
}

#common vriable for name 
name = "example"

#Kinesis firehose
kinesis_stream_arn      = null
kinesis_stream_role_arn = null
#s3
prefix              = null
s3_buffer_size      = 5
s3_buffer_interval  = 300
compression_format  = "UNCOMPRESSED"
error_output_prefix = null
s3_log_stream_name  = "s3_log"
#elasticsearch_configuration
index_name                          = "elasticsearch_test"
cluster_endpoint                    = null
buffering_interval                  = 300
buffering_size                      = 5
index_rotation_period               = "OneDay"
s3_backup_mode                      = "FailedDocumentsOnly"
type_name                           = "elasticsearch"
retry_duration                      = 300
elasticsearch_log_stream_name       = "elasticsearch_log"
processing_configuration_enabled    = false
processing_configuration_processors = []

#iam policy
path        = "/"
aws_service = ["firehose.amazonaws.com", "opensearchservice.amazonaws.com"]

#subnet
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

#SSM 
parameter_vpc_id_name = "/vpc/id"

#elasticsearch resource
domain_name            = "elasticsearch-test-oxdi"
instance_count         = 2
zone_awareness_enabled = true
instance_type          = "t2.small.elasticsearch"
ebs_enabled            = true
volume_size            = 10