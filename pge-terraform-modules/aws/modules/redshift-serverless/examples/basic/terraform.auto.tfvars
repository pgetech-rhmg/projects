##### General Configuration #####
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

##### PGE Required Tags #####
AppID = 1001 # Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####
Environment        = "Dev"      # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" # Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"      # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["mzrk@pge.com", "r0k6@pge.com", "s7aw@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["mzrk", "r0k6", "s7aw"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          # Order must be between 7 and 9 digits

##### Optional Tags #####
optional_tags = {}

##### VPC Configuration #####
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
parameter_vpc_id_name    = "/vpc/id"

##### Redshift Serverless Configuration #####
name                 = "ccoe-test-redshift-serverless"
admin_username       = "admin"
db_name              = "dev"
base_capacity        = 128
max_capacity         = 256
log_exports          = ["userlog", "connectionlog"]
enhanced_vpc_routing = false
