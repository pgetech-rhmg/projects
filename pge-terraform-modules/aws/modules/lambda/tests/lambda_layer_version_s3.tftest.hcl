run "lambda_layer_version_s3" {
  command = apply

  module {
    source = "./examples/lambda_layer_version_s3"
  }
}

variables {
  account_num                            = "750713712981"
  aws_region                             = "us-west-2"
  aws_role                               = "CloudAdmin"
  kms_role                               = "CloudAdmin"
  AppID                                  = "1001"
  Environment                            = "Dev"
  DataClassification                     = "Internal"
  CRIS                                   = "Low"
  Notify                                 = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                  = ["abc1", "def2", "ghi3"]
  Compliance                             = ["None"]
  Order                                  = 8115205
  layer_version_layer_name               = "simple_layer"
  layer_version_compatible_architectures = "x86_64"
  layer_version_description              = "Description of what your Lambda Layer does"
  layer_version_compatible_runtimes      = ["python3.9", "nodejs14.x"]
  layer_version_permission_action        = "lambda:GetLayerVersion"
  layer_version_permission_statement_id  = "dev-account"
  layer_version_permission_principal     = "*"
  s3_bucket_name                         = "lambdabucketexample"
  bucket_object_key                      = "deployment_artifact.zip"
  bucket_object_source                   = "lambda_function.zip"
  kms_name                               = "lambda-layer-cmk-key"
  kms_description                        = "CMK for encrypting lambda layer"
}
