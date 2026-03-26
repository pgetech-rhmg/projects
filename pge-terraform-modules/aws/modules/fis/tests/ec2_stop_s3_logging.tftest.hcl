run "ec2_stop_s3_logging" {
  command = apply

  module {
    source = "./examples/ec2_stop_s3_logging"
  }
}

variables {
  name                = "FIS-Testing-EC2-terminate-S3-logging"
  fis_experiment_name = "FIS-Testing-EC2-terminate-S3-logging"
  account_num         = "750713712981"
  aws_service         = ["fis.amazonaws.com"]
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  fis_role_name       = ""
  inline_policy = [
  ]
  policy_name        = "fis_managed_policy_s3_dev"
  policy_description = "IAM policy for FIS experiment with S3 logging"
  policy_content     = ""
  LogGroupNamePrefix = "/aws/fis/"
  AppID              = 1001
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    Purpose = "chaos-engineering-s3-logging"
  }
  description = "Terminate EC2 instances experiment with S3 logging"
  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }
  stop_condition = [
    {
      source = "none"
      value  = ""
    }
  ]
  target = [
    {
      name           = "SpecificInstances"
      resource_type  = "aws:ec2:instance"
      selection_mode = "COUNT(1)"
      resource_arns  = []
      filter         = []
      resource_tags = [
        {
          key   = "Fis"
          value = "Chaos"
        },
        {
          key   = "Environment"
          value = "Dev"
        }
      ]
    }
  ]
  action = [
    {
      name        = "StopInstances"
      action_id   = "aws:ec2:stop-instances"
      description = "Stops specific EC2 instances for resilience testing"
      start_after = []
      parameter   = {}
      target = [
        {
          key   = "Instances"
          value = "SpecificInstances"
        }
      ]
    }
  ]
  log_type           = "s3"
  log_schema_version = 1
  s3_bucket_name     = "my-fis-logs-bucket"
  s3_logging = {
    prefix = "fis-logs/ec2-stop/"
  }
  cloudwatch_log_group_name = ""
}
