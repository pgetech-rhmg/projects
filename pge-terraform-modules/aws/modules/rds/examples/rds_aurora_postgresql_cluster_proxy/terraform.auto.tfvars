aws_role                              = "CloudAdmin"
account_num                           = "750713712981"
aws_region                            = "us-west-2"
user                                  = "rb1c"
kms_role                              = "CloudAdmin"
kms_name                              = "ccoe-aurora-postresql-kms"
identifier                            = "aurora-postgres"
engine_version                        = 15
performance_insights_retention_period = null
cluster_instance_count                = 2
skip_final_snapshot                   = true
instance_class                        = "db.t3.medium"
aws_service                           = ["rds.amazonaws.com"]
### provide secressmanager_arn when manage_master_user_password is false
# secretsmanager_arn = "arn:aws:secretsmanager:us-west-2:750713712981:secret:rds!cluster-13f652da-5839-4956-9e30-d00d38759a0c-dtw9lB"


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
family = "aurora-postgresql15"
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

