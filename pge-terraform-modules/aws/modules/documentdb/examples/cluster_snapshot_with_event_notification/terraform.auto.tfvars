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
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits
optional_tags      = { managed_by = "terraform" }

# Parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

# Module docdb_cluster
name                        = "docdb-test"
cluster_engine_version      = "4.0.0"
cluster_skip_final_snapshot = true
cluster_timeouts = {
  create = "120m"
  update = "120m"
  delete = "120m"
}

# KMS
description = "KMS CMK for cluster"

# Variable values for parameter
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

# Event subscription variables
source_type      = "db-cluster-snapshot"
event_categories = ["backup", "notification"]

# SNS topic variables
endpoint = ["r0k6@pge.com"]
protocol = "email"

# cluster_instance
cluster_instance_instance_class = "db.t3.medium"