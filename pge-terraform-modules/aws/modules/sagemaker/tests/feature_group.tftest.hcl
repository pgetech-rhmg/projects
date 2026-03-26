run "feature_group" {
  command = apply

  module {
    source = "./examples/feature_group"
  }
}

variables {
  account_num                    = "056672152820"
  aws_region                     = "us-west-2"
  aws_role                       = "CloudAdmin"
  kms_role                       = "TF_Developers"
  AppID                          = "1001"
  Environment                    = "Dev"
  DataClassification             = "Internal"
  CRIS                           = "Low"
  Notify                         = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                          = ["abc1", "def2", "ghi3"]
  Compliance                     = ["None"]
  Order                          = 8115205
  optional_tags                  = { service = "sagemaker" }
  role_service                   = ["sagemaker.amazonaws.com"]
  iam_policy_arns                = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"]
  name                           = "test-iac5"
  record_identifier_feature_name = "abcd"
  event_time_feature_name        = "abcf"
  feature_definition = [{
    feature_name = "abcd"
    feature_type = "String"
    },
    {
      feature_name = "abcf"
      feature_type = "Fractional"
    }
  ]
  s3_uri     = "s3://a0ks-test/glue-ml/"
  database   = "test-a0ks02"
  table_name = "test0001"
  catalog    = "056672152820"
}
