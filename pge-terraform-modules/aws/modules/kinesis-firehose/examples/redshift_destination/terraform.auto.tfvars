account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                          #Order must be between 7 and 9 digits
optional_tags = {
  managed_by = "terraform"
}

#common vriable for name 
name = "example"

#kinesis firehose
kinesis_stream_arn      = null
kinesis_stream_role_arn = null
#s3
prefix              = null
s3_buffer_size      = 5
s3_buffer_interval  = 300
compression_format  = "UNCOMPRESSED"
error_output_prefix = null
s3_log_stream_name  = "s3_log"
#redshift configuration
retry_duration           = 3600
copy_options             = null
data_table_columns       = null
redshift_log_stream_name = "redshift_log"
s3_backup_mode           = "Enabled"
#s3_backup configuration
s3_backup_prefix                    = null
s3_backup_buffer_size               = 5
s3_backup_buffer_interval           = 300
s3_backup_compression_format        = "UNCOMPRESSED"
s3_backup_error_output_prefix       = null
s3_backup_log_stream_name           = "s3_backup_log"
processing_configuration_enabled    = false
processing_configuration_processors = []

#iam policy
path        = "/"
aws_service = ["firehose.amazonaws.com", "redshift.amazonaws.com"]

#subnet
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

#SSM 
parameter_vpc_id_name = "/vpc/id"

#Cluster
node_type            = "ra3.xlplus"
cluster_type         = "single-node"
skip_final_snapshot  = true
s3_key_prefix        = "redshift/"
database_name        = "database01"

#Time Sleep
create_duration = "05m"