run "lambda_function_with_cloudfront_resource" {
  command = apply

  module {
    source = "./examples/lambda_function_with_cloudfront_resource"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-east-1"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  aws_r53_role       = "CloudAdmin"
  aws_r53_region     = "us-east-1"
  account_num_r53    = "514712703977"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  geo_restriction = [{
    restriction_type = "whitelist",
    locations        = ["US", "CA"]
  }]
  kms_name               = "lambda-test-cmk-key"
  kms_description        = "CMK for encrypting lambda"
  kms_template_file_name = "kms_user_policy.json"
  bucket_name            = "s3-static-ccoe-6521-a8tq"
  custom_domain_name     = "static-web-lambda-edge-test.nonprod.pge.com"
  static_content         = "static_content/index.html"
  Order                  = 8115205
  grants = [
    {
      id          = null
      type        = "Group"
      permissions = ["READ"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      id          = null
      type        = "Group"
      permissions = ["WRITE"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]
  object_lock_configuration = null
  cors_rule_inputs = [{
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://static-web-lambda-edge.nonprod.pge.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
    id              = null
  }]
  function_name              = "lambda-edge-local-cloudfront-resource"
  description                = "testing aws lambda edge"
  runtime                    = "nodejs18.x"
  handler                    = "index.handler"
  local_zip_source_directory = "lambda_source_code"
  iam_name                   = "lambda-edge-policy"
  policy_arns_list           = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  lambda_policy_name         = "ccoe_terraform_multiple_policies"
  lambda_policy_path         = "/"
  lambda_policy_description  = "policy creation for ccoe terrform test"
  optional_tags = {
    Name = "test_lambda"
  }
}
