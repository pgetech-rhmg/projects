account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

# Tags
AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
optional_tags      = { managed_by = "terraform" }
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits

#parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

#module docdb_cluster
name                        = "documentdb-test"
cluster_engine_version      = "4.0.0"
cluster_skip_final_snapshot = true
cluster_timeouts = {
  create = "120m"
  update = "120m"
  delete = "120m"
}



#variable values for parameter
docdb_cluster_parameter_group_family = "docdb4.0"

parameter = [{
  name  = "change_stream_log_retention_duration"
  value = 10800
  },
  {
    name  = "profiler"
    value = "disabled"
  },
  {
    name  = "profiler_sampling_rate"
    value = 1.0
  },
  {
    name  = "profiler_threshold_ms"
    value = 100
  },
  {
    name  = "ttl_monitor"
    value = "enabled"
}]

#cluster_instance
instance_count                  = 2
cluster_instance_instance_class = "db.t3.medium"