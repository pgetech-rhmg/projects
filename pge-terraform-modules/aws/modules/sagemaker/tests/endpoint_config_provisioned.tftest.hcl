run "endpoint_config_provisioned" {
  command = apply

  module {
    source = "./examples/endpoint_config_provisioned"
  }
}

variables {
  account_num            = "056672152820"
  aws_region             = "us-west-2"
  aws_role               = "CloudAdmin"
  kms_role               = "TF_Developers"
  AppID                  = "1001"
  Environment            = "Dev"
  DataClassification     = "Internal"
  CRIS                   = "Low"
  Notify                 = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                  = ["abc1", "def2", "ghi3"]
  Compliance             = ["None"]
  Order                  = 8115205
  optional_tags          = { service = "sagemaker" }
  name                   = "provisioned-endpoint-config-tf-test"
  initial_instance_count = 1
  instance_type          = "ml.t2.medium"
  model_name             = "IAC-TEST"
  variant_name           = "variant-1"
  async_inference_config = {
    client_config = {
      max_concurrent_invocations_per_instance = 1
    }
    output_config = {
      s3_output_path = "s3://a0ks-test/sftp-test/"
      notification_config = {
        error_topic   = "arn:aws:sns:us-west-2:056672152820:sns_topic-test"
        success_topic = "arn:aws:sns:us-west-2:056672152820:sns_topic_test-11"
      }
    }
  }
}
