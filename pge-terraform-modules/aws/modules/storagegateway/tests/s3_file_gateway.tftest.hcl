run "s3_file_gateway" {
  command = apply

  module {
    source = "./examples/s3_file_gateway"
  }
}

variables {
  account_num                    = "056672152820"
  aws_region                     = "us-west-2"
  aws_role                       = "CloudAdmin"
  kms_role                       = "CloudAdmin"
  AppID                          = "2102"
  Environment                    = "Dev"
  DataClassification             = "Internal"
  CRIS                           = "Low"
  Notify                         = ["abc1@pge.com", "def2@pge.com"]
  Owner                          = ["abc1", "def2", "ghi3"]
  Compliance                     = ["None"]
  optional_tags                  = { service = "storagegateway" }
  Order                          = 8115205
  secretsmanager_name            = "tf-test-storagegateway-activation-key"
  secretsmanager_description     = "Activation key for storage gateway"
  secret_version_enabled         = true
  ssm_parameter_activation_key   = "/storagegateway/activationkey"
  name                           = "tf-test-s3-file-system"
  gateway_timezone               = "GMT-4:00"
  gateway_type                   = "FILE_S3"
  gateway_vpc_endpoint           = "vpce-0e12576fa3ac6b7d5"
  day_of_month                   = 1
  day_of_week                    = 0
  hour_of_day                    = 00
  minute_of_hour                 = 59
  logs_name                      = "/aws/vendedlogs/sgw-s3"
  disk_node                      = "/dev/sdb"
  client_list                    = ["0.0.0.0/0"]
  directory_mode                 = "0777"
  file_mode                      = "0666"
  group_id                       = 65534
  owner_id                       = 65534
  cache_stale_timeout_in_seconds = 300
  timeouts = {
    create = "15m"
    delete = "20m"
    update = "15m"
  }
  aws_service = ["storagegateway.amazonaws.com"]
}
