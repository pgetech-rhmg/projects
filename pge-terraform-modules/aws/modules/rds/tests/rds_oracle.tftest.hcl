run "rds_oracle" {
  command = apply

  module {
    source = "./examples/rds_oracle"
  }
}

variables {
  aws_role                             = "CloudAdmin"
  kms_role                             = "CloudAdmin"
  account_num                          = "750713712981"
  user                                 = "rb1c"
  aws_region                           = "us-west-2"
  kms_name                             = "kms-rds-oracle"
  s3_bucket_arn                        = "arn:aws:s3:::c7bh-test-rds-lzv2"
  domain                               = "d-926705cff6"
  identifier                           = "rds-oracle-3"
  port                                 = "1521"
  multi_az                             = true
  monitoring_interval                  = 60
  allocated_storage                    = "20"
  storage_type                         = "gp2"
  engine                               = "oracle-se2"
  family                               = "oracle-se2-19"
  license_model                        = "license-included"
  engine_version                       = "19"
  skip_final_snapshot                  = true
  delete_automated_backups             = true
  instance_class                       = "db.t3.medium"
  allow_major_version_upgrade          = true
  db_name                              = "ORCLTF"
  username                             = "admin"
  manage_master_user_password          = true
  maintenance_window                   = "sun:20:00-sun:21:00"
  backup_window                        = "11:00-12:00"
  max_allocated_storage                = 200
  cpu_credit_balance_too_low_threshold = 150
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
  options = [
    {
      option_name                    = "Timezone"
      db_security_group_memberships  = []
      vpc_security_group_memberships = []
      port                           = null
      version                        = ""
      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "US/Pacific"
        }
      ]
    },
    {
      option_name                    = "S3_INTEGRATION"
      db_security_group_memberships  = []
      vpc_security_group_memberships = []
      port                           = null
      version                        = "1.0"
      option_settings                = []
    }
  ]
  autostart = {
    autostart = "yes"
  }
  autostop = {
    autostop = "yes"
  }
}
