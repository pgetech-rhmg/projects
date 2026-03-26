run "sagemaker_endpoint" {
  command = apply

  module {
    source = "./examples/sagemaker_endpoint"
  }
}

variables {
  account_num        = "056672152820"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags      = { service = "sagemaker" }
  name               = "sagemaker-endpoint-tf-test"
  deployment_config = [{
    blue_green_update_policy = [{
      maximum_execution_timeout_in_seconds = 600
      termination_wait_in_seconds          = 300
      traffic_routing_configuration = [{
        type                     = "ALL_AT_ONCE"
        wait_interval_in_seconds = 300
      }]
    }]
    auto_rollback_configuration = [{
      alarms = [{
        alarm_name = "sagemaker_test_tf"
      }]
    }]
  }]
  endpoint_config_name = "IAC-TEST-EP-CONFIG"
}
