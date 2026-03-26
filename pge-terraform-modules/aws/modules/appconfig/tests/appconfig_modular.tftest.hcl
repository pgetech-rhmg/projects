run "appconfig_modular" {
  command = apply

  module {
    source = "./examples/appconfig_modular"
  }
}

variables {
  account_num               = "750713712981"
  aws_region                = "us-west-2"
  aws_role                  = "CloudAdmin"
  kms_role                  = "CloudAdmin"
  kms_name                  = "ccoe-kms-appconfig-example"
  kms_description           = "A test key created for the AppConfig TF module"
  AppID                     = "1001"
  Environment               = "Dev"
  DataClassification        = "Internal"
  CRIS                      = "Low"
  Notify                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                     = ["abc1", "def2", "ghi3"]
  Compliance                = ["None"]
  name                      = "ccoe-compound-test-e6bo"
  description               = "A test of multiple submodules"
  config_profile_name       = "config-profile"
  config_profile_desc       = "config-profile-description"
  hosted_config_description = "A description of the hosted configuration version"
  content                   = "some content"
  env_name                  = "ccoe-test-env"
  env_description           = "ccoe-test-env-description"
  monitors = [
    {
      alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmLow-12e28ff6-3e7a-469c-93e6-3f5ca7707f8b"
      alarm_role_arn = "arn:aws:iam::750713712981:role/AWSAppSyncPushToCloudWatchLogsRole"
    }
  ]
  strategy_name        = "ccoe-deploy-strat"
  strategy_description = "ccoe-deploy-strat-description"
}
