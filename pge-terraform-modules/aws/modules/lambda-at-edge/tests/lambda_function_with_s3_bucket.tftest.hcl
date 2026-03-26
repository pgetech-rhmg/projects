run "lambda_function_with_s3_bucket" {
  command = apply

  module {
    source = "./examples/lambda_function_with_s3_bucket"
  }
}

variables {
  account_num          = "750713712981"
  aws_region           = "us-west-2"
  aws_role             = "CloudAdmin"
  kms_role             = "CloudAdmin"
  AppID                = "1001"
  Environment          = "Dev"
  DataClassification   = "Internal"
  CRIS                 = "Low"
  Notify               = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                = ["abc1", "def2", "ghi3"]
  Compliance           = ["None"]
  function_name        = "lambda-edge-s3-e6bo"
  description          = "testing aws lambda@edge"
  runtime              = "python3.9"
  handler              = "lambda_function.lambda_handler"
  kms_name             = "lambda-test-cmk-key"
  kms_description      = "CMK for encrypting lambda"
  s3_bucket_name       = "lambdatestbucketexample-e6bo"
  bucket_object_key    = "deployment_artifact.zip"
  bucket_object_source = "lambda_function.zip"
  iam_name             = "lambda_policy"
  policy_arns_list     = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  policy_name          = "ccoe_terraform_multiple_policies"
  policy_path          = "/"
  policy_description   = "policy creation for ccoe terrform test"
  Order                = 8115205
}
