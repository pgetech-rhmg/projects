# To run this example, add input for the aws_role, user, account_num, kms_key_id, domain, cidr_ingress_rules, cidr_egress_rules, and s3_bucket_arn field.  You should also update the tags
# to reflect your info.  The identifier variable is populated below, however, this should be unique to your account.

aws_role      = "CloudAdmin"
kms_role      = "CloudAdmin"
account_num   = "750713712981"
user          = "rb1c"
aws_region    = "us-west-2"
kms_name      = "kms-rds-oracle"
s3_bucket_arn = "arn:aws:s3:::c7bh-test-rds-lzv2"
domain        = "d-926705cff6"

identifier          = "rds-oracle-3"
port                = "1521"
multi_az            = true
monitoring_interval = 60
allocated_storage   = "20"
storage_type        = "gp2"
engine              = "oracle-se2"
family              = "oracle-se2-19"
license_model       = "license-included"
engine_version      = "19"

skip_final_snapshot      = true
delete_automated_backups = true
instance_class           = "db.t3.medium"

allow_major_version_upgrade = true

db_name  = "ORCLTF"
username = "admin"
# Note : If manage_master_user_password is set to true, password value can be null
# password                    = "pass123xyz2024za"
manage_master_user_password = true
maintenance_window          = "sun:20:00-sun:21:00"
backup_window               = "11:00-12:00"

max_allocated_storage                = 200
cpu_credit_balance_too_low_threshold = 150
#create_low_disk_burst_alarm = false # By default this feature is true, make changes as per the use case
# Uncomment below variable when the DataClassification is not Internal or Public 
#storage_encrypted = true

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

## auto start stop variables, enable auto start and auto stop by setting autostart and autostop to "yes"
## when the value is set to "yes", the rds instance will be started and stopped as per the schedule defined in the schedule_rds_auto_start and schedule_rds_auto_stop variables
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are in cron format
## the cron format is "cron(minute hour day month weekday)"
## for example, to start the rds instance every monday at 12:32 PM, set the schedule_rds_auto_start variable to "cron(32 12 ? * MON *)"
## to stop the rds instance every sunday at 9:30 PM, set the schedule_rds_auto_stop variable to "cron(30 21 ? * SUN *)"
## the cron format is explained in detail at https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
## the autostart and autostop variables are optional, by default the values are set to "no"
## the schedule_rds_auto_start and schedule_rds_auto_stop variables are optional, by default the values are set to null
## these variables are used by rds-start-stop module which uses lambda and cloudwatch event to start and stop the rds instance as per the schedule

autostart = {
  autostart = "yes"
}

autostop = {
  autostop = "yes"
}
### NOTES:
# uncomment all variables below if managed_master_user_password is set to default i.e false and provide your own values as per your requirements


# secrets manager variables
# rotation_enabled = true  #default is false
# secretsmanager_name = "rds-secrets"

# rotation lambda variables, necessary for SAF compliance
# lambda_function_name = "secretsmanager_rotation" #default is secretsmanager_rotation
# lambda_description   = "Lambda function code for secretsmanager rotation"
# lambda_handler_name  = "index.lambda_handler" # default is null
# lambda_runtime       = "python3.8" # default is python3.9
# timeout              = 120 # default is 10
# source_dir           = "lambda_source" # default is "lambda_source" 

# lambda layer version s3 variables
# layer_version_layer_name               = "cx_oracle_lambda_layer" # default is null
# layer_version_compatible_architectures = "x86_64" # default is null
# layer_version_compatible_runtimes      = ["python3.7"] # default is python3.9
# layer_version_permission_principal     = "*"  # default is null
# s3_bucket                              = "lambda-layer-cx-oracle-rb1c" # default is null
# s3_key                                 = "cx_oracle_lambda_layer.zip" # default is null
# layer_version_permission_statement_id  = "dev-account" # default is null
# layer_version_permission_action        = "lambda:GetLayerVersion" # default is null



