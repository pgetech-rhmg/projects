run "appconfig_simple" {
  command = apply

  module {
    source = "./examples/appconfig_simple"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  kms_role                   = "CloudAdmin"
  kms_name                   = "ccoe-kms-appconfig-example"
  kms_description            = "A test key created for the AppConfig TF module"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  name                       = "ccoe-compound-test-e6bo"
  description                = "A test of multiple submodules"
  config_profile_name        = "config-profile"
  config_profile_description = "config-profile-description"
  hosted_config_content      = "{\"some\":\"content\"}"
  hosted_config_description  = "Describing the content. Optional."
  hosted_config_content_type = "application/json"
  env_name                   = "non-prod"
  env_description            = "a non production environment description."
  env_monitors = [
    {
      alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmLow-12e28ff6-3e7a-469c-93e6-3f5ca7707f8b"
      alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
    },
    {
      alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmHigh-0a0dc473-be61-4dcb-9975-0ba855424671"
      alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
    }
  ]
}
