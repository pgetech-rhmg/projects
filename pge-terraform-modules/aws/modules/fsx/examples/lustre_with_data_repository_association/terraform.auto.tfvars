account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order = 8115205 #Order must be between 7 and 9 digits
optional_tags      = { managed_by = "terraform" }

#parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/privatesubnet3/id"

#common name
name = "luster-association-test"

#lustre_file_system
storage_capacity            = 1200
per_unit_storage_throughput = 125
log_configuration_level     = "WARN_ERROR"

#data repository association
file_system_path          = "/ns"
auto_import_policy_events = ["NEW", "CHANGED"]
auto_export_policy_events = ["NEW", "DELETED"]
data_repository_association_timeouts = {
  create = "10m"
  update = "10m"
  delete = "20m"
}