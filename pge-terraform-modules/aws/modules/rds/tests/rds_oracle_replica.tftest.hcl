run "rds_oracle_replica" {
  command = apply

  module {
    source = "./examples/rds_oracle_replica"
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
  engine                               = "oracle-ee"
  family                               = "oracle-ee-19"
  license_model                        = "bring-your-own-license"
  engine_version                       = "19"
  skip_final_snapshot                  = true
  delete_automated_backups             = true
  instance_class                       = "db.t3.medium"
  allow_major_version_upgrade          = true
  db_name                              = "ORCLTF"
  username                             = "admin"
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
  rotation_enabled                       = true
  lambda_function_name                   = "secretsmanager_rotation"
  lambda_description                     = "Lambda function code for secretsmanager rotation"
  lambda_handler_name                    = "index.lambda_handler"
  lambda_runtime                         = "python3.8"
  timeout                                = 120
  source_dir                             = "lambda_source"
  layer_version_layer_name               = "cx_oracle_lambda_layer"
  layer_version_compatible_architectures = "x86_64"
  layer_version_compatible_runtimes      = ["python3.7"]
  layer_version_permission_principal     = "*"
  s3_bucket                              = "lambda-layer-cx-oracle-rb1c"
  s3_key                                 = "cx_oracle_lambda_layer.zip"
  layer_version_permission_statement_id  = "dev-account"
  layer_version_permission_action        = "lambda:GetLayerVersion"
}
