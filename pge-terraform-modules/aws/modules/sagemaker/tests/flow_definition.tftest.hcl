run "flow_definition" {
  command = apply

  module {
    source = "./examples/flow_definition"
  }
}

variables {
  account_num                           = "056672152820"
  aws_region                            = "us-west-2"
  aws_role                              = "CloudAdmin"
  kms_role                              = "TF_Developers"
  AppID                                 = "1001"
  Environment                           = "Dev"
  DataClassification                    = "Internal"
  CRIS                                  = "Low"
  Notify                                = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                 = ["abc1", "def2", "ghi3"]
  Compliance                            = ["None"]
  Order                                 = 8115205
  optional_tags                         = { service = "sagemaker" }
  name                                  = "iac-test"
  task_availability_lifetime_in_seconds = 1
  task_count                            = 1
  task_keywords                         = ["test"]
  task_time_limit_in_seconds            = 3600
  task_title                            = "test-iac-example"
  workteam_arn                          = "arn:aws:sagemaker:us-west-2:056672152820:workteam/private-crowd/a0ks-test"
  human_loop_activation_config = {
    human_loop_activation_conditions_config = {
      human_loop_activation_conditions = <<EOF
            {
                "Conditions": [
                {
                    "ConditionType": "Sampling",
                    "ConditionParameters": {
                    "RandomSamplingPercentage": 5
                    }
                }
                ]
            }
        EOF
    }
  }
  human_loop_request_source = {
    aws_managed_human_loop_request_source = "AWS/Textract/AnalyzeDocument/Forms/V1"
  }
  content     = "sagemaker-human-task-ui-template.html"
  policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonAugmentedAIIntegratedAPIAccess"]
  aws_service = ["sagemaker.amazonaws.com", "s3.amazonaws.com"]
}
