
aws_role               = "CloudAdmin"
account_num            = "750713712981"
aws_region             = "us-west-2"
user                   = "rb1c"
identifier             = "aurora-mysql-v3"
cluster_instance_count = 2
skip_final_snapshot    = true
instance_class         = "db.t3.medium"

# Notes on performance_insights_enabled at cluster and instance level
# Recommendation is to always enabled performance insights at instance level to give more control, However if your use case
# demands at cluster level, make sure to comment out instance level parameters and vice versa
# performance_insights_enabled = true
performance_insights_retention_period = null # keep this null when instance level is not true

# when cluster level parameter are needed make sure to enable to true as shown below
# cluster_performance_insights_enabled = true
cluster_performance_insights_retention_period = null # make this to null if instance level is not true
/***************************************rds db cluster****************************************************/
database_name   = "dbtestname"
master_username = "superadmin"
# Note : 
# Serverless v1 clusters do not support managed master user password, Aurora Serverless v2 is supported for MySQL 8.0 onwards & PostgreSQL 13 onwards.
# If manage_master_user_password is set to true, password value can be null
manage_master_user_password = true
#master_password              = "alphatest123alarm$$"
engine_version               = "8.0.mysql_aurora.3.04.0"
preferred_backup_window      = "11:00-12:00"
preferred_maintenance_window = "sun:20:00-sun:23:00"
/***************************************rds db cluster param group****************************************************/
cluster_parameters = [
  {
    name  = "server_audit_events",
    value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  },
  {
    name  = "server_audit_excl_users",
    value = "rdsadmin"
  },
  {
    name  = "server_audit_logs_upload",
    value = "1"
  },
  {
    name  = "server_audit_logging",
    value = "1"
  },
  {
    name  = "time_zone",
    value = "US/Pacific"
  }
]

/***************************************rds db param group ****************************************************/
family = "aurora-mysql8.0"
db_parameter_group_tags = {
  CreatedBy = "rb1c"
}

/**************************************************************************************************************/

tags = {
  Owner              = "abc1_def2_ghi3"
  AppID              = "APP-1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  Compliance         = "None"
  CRIS               = "High"
  Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
  Order              = 8115205 #Order must be between 7 and 9 digits" 

}

#ssm_parameter

ssm_description = "DB cluster master password"

#cloudwatch metrics

cpu_credit_balance_too_low_threshold = 150

# KMS

kms_role = "CloudAdmin"
kms_name = "ccoe-aurora-mysql-kms"

