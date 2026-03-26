aws_role    = "CloudAdmin"
account_num = "750713712981"
aws_region  = "us-west-2"
# user           = "rb1c"
kms_role       = "CloudAdmin"
kms_name       = "ccoe-aurora-postresql-kms"
identifier     = "aurora-postgres-750"
engine_version = 14
# Notes on performance_insights_enabled at cluster and instance level
# Recommendation is to always enable performance insights at instance level to give more control, However if your use case
# demands at cluster level, make sure to comment out instance level parameters and vice versa
# performance_insights_enabled = true
performance_insights_retention_period = null # keep this null when instance level is not true, by default this value is 7

# when cluster level parameter are needed make sure to enable to true as shown below
# cluster_performance_insights_enabled = true
cluster_performance_insights_retention_period = null # make this to null if instance level is not true, by default this value is 7

cluster_instance_count = 2
skip_final_snapshot    = true
instance_class         = "db.serverless" ##"db.t3.medium" # change it to "db.serverless" if using serverlessv2

# Custom instance naming - optional feature
# Leave empty or comment out to use default naming (identifier-0, identifier-1, etc.)
custom_instance_names = []

# Example naming patterns:
# Writer/Reader pattern:
# custom_instance_names = [
#   "aurora-postgres-750-writer",
#   "aurora-postgres-750-reader-1"
# ]

# Environment-specific pattern:
# custom_instance_names = [
#   "dev-postgres-primary",
#   "dev-postgres-replica"
# ]

# Note: List length must match cluster_instance_count

# Note: The module now includes enhanced ignore_changes patterns to prevent unwanted 
# cluster replacements during snapshot restores and cross-environment deployments.
# This includes ignoring differences in KMS keys, security groups, subnets, and timing windows.

allow_major_version_upgrade = true
apply_immediately           = true


### use serverlessv2_scaling_configuration if using serverlessv2 and instance class "db.serverless"
serverlessv2_scaling_configuration = {
  min_capacity = 2
  max_capacity = 10
}

#uncomment the following lines to use AD authentication
# domain_directory_service_id = "d-926705cff6" // DEV directory ID.
# domain_ad_iam_role_name     = "rds-directoryservice-kerberos-access-role"


# storage_type = "aurora-iopt1"

/***************************************rds db cluster****************************************************/
database_name   = "dbtestname1"
master_username = "superadmin"
# Note : 
# Serverless v1 clusters do not support managed master user password, Aurora Serverless v2 is supported for MySQL 8.0 onwards & PostgreSQL 13 onwards.
# If manage_master_user_password is set to true, password value can be null
manage_master_user_password = true
#master_password              = "alphatest123dsadsax"

preferred_backup_window      = "11:00-12:00"
preferred_maintenance_window = "sun:20:00-sun:21:00"
/***************************************rds db cluster param group****************************************************/
cluster_parameters = [
  {
    name  = "autovacuum",
    value = "1"
  },
  {
    name  = "timezone",
    value = "US/Pacific"
  }
]

/***************************************rds db param group ****************************************************/

family = "aurora-postgresql14"
db_parameter_group_tags = {
  CreatedBy = "rb1c"
}

/**************************************************************************************************************/

tags = {
  Owner       = "abc1_def2_ghi3" #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader"
  AppID       = "APP-1001"       #Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  Environment = "Dev"            #Dev, Test, QA, Prod (only one environment) 
  # If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
  # detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
  DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
  Compliance         = "None"
  CRIS               = "High" #"Cyber Risk Impact Score High, Medium, Low (only one)"
  Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
  Order              = 8115205 #Order must be between 7 and 9 digits"
}


#ssm_parameter

ssm_description = "DB cluster master password"

#cloudwatch metrics

cpu_credit_balance_too_low_threshold = 150

