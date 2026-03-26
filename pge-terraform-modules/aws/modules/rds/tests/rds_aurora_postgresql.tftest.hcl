run "rds_aurora_postgresql" {
  command = apply

  module {
    source = "./examples/rds_aurora_postgresql"
  }
}

variables {
  aws_role                                      = "CloudAdmin"
  account_num                                   = "750713712981"
  aws_region                                    = "us-west-2"
  user                                          = "rb1c"
  kms_role                                      = "CloudAdmin"
  kms_name                                      = "ccoe-aurora-postresql-kms"
  identifier                                    = "aurora-postgres-750"
  engine_version                                = 14
  performance_insights_retention_period         = null
  cluster_performance_insights_retention_period = null
  cluster_instance_count                        = 2
  skip_final_snapshot                           = true
  instance_class                                = "db.serverless"
  allow_major_version_upgrade                   = true
  apply_immediately                             = true
  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
  /***************************************rds db cluster****************************************************/
  database_name                = "dbtestname1"
  master_username              = "superadmin"
  manage_master_user_password  = true
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
}
