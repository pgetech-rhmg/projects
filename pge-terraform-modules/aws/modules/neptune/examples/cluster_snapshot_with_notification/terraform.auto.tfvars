account_num        = "056672152820"
aws_region         = "us-west-2"
aws_role           = "CloudAdmin"
kms_role           = "TF_Developers"
template_file_name = "kms_user_policy.json"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits
optional_tags = {
  managed_by = "terraform"
}

#common vriable for name 
name = "example"

#vaiable values for cluster
engine_version      = "1.1.0.0"
skip_final_snapshot = "true"
timeouts = {
  create = "140m"
  update = "140m"
  delete = "140m"
}

#event subscription variables
source_type      = "db-cluster-snapshot"
event_categories = ["backup", "notification"]



#subnet group variables - parameter store names
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"