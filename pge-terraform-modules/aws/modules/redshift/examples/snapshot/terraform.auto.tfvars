account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
optional_tags      = { service = "redshift" }

#Parameter
name = "redshift-test"

#subnet
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
ssm_parameter_vpc_id     = "/vpc/id"

# values for snapshot schedule

snapshot_schedule_definitions = ["cron(45 15 *)"]

#Event subscription
source_type      = null
enabled          = true
event_categories = ["pending"]
source_ids       = null

#sns topic variables

endpoint = "test@pge.com"
protocol = "email"

#kms variable
template_file_name = "kms_user_policy.json"

#Snapshot Copy Grant
destination_region = "us-east-1"
retention_period   = 1

#SSM 

Order                = 8115205
#Cluster
node_type            = "ra3.xlplus"
cluster_type         = "single-node"
skip_final_snapshot  = true
cluster_role_service = ["redshift.amazonaws.com", "scheduler.redshift.amazonaws.com"]

#S3
s3_key_prefix = "redshift/"


#Time Sleep
create_duration = "10m"