run "rds_aurora_mysql" {
  command = apply

  module {
    source = "./examples/rds_aurora_mysql"
  }
}

variables {
  aws_role                                      = "CloudAdmin"
  account_num                                   = "750713712981"
  aws_region                                    = "us-west-2"
  user                                          = "rb1c"
  identifier                                    = "aurora-mysql-v3"
  cluster_instance_count                        = 2
  skip_final_snapshot                           = true
  instance_class                                = "db.t3.medium"
  performance_insights_retention_period         = null
  cluster_performance_insights_retention_period = null
  /***************************************rds db cluster****************************************************/
  database_name                = "dbtestname"
  master_username              = "superadmin"
  manage_master_user_password  = true
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
    Order              = 8115205
  }
  ssm_description                      = "DB cluster master password"
  cpu_credit_balance_too_low_threshold = 150
  kms_role                             = "CloudAdmin"
  kms_name                             = "ccoe-aurora-mysql-kms"
}
