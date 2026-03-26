run "sagemaker_model" {
  command = apply

  module {
    source = "./examples/sagemaker_model"
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
  name               = "test-model"
  image              = "246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:0.90-2-cpu-py3"
  mode               = "SingleModel"
  model_data_url     = "https://a0ks-test.s3.us-west-2.amazonaws.com/glue-ml/dblp_acm_labels.csv"
  container_hostname = "Container"
  environment        = { "name" = "aws" }
  security_group_ids = ["sg-09b9d2b627613b47b"]
  subnet_ids         = ["subnet-086169df2f630eb89"]
  role_service       = ["sagemaker.amazonaws.com"]
  iam_policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", "arn:aws:iam::aws:policy/AmazonSageMakerFeatureStoreAccess"]
}
