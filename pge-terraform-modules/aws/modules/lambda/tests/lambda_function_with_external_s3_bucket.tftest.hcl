run "lambda_function_with_external_s3_bucket" {
  command = apply

  module {
    source = "./examples/lambda_function_with_external_s3_bucket"
  }
}

variables {
  account_num           = "750713712981"
  aws_region            = "us-west-2"
  aws_role              = "CloudAdmin"
  kms_role              = "CloudAdmin"
  vpc_id_name           = "/vpc/id"
  subnet_id1_name       = "/vpc/2/privatesubnet1/id"
  AppID                 = "1001"
  Environment           = "Dev"
  DataClassification    = "Internal"
  CRIS                  = "Low"
  Notify                = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                 = ["abc1", "def2", "ghi3"]
  Compliance            = ["None"]
  Order                 = 8115205
  function_name         = "lambda-s3-tf"
  description           = "testing aws lambda"
  runtime               = "python3.9"
  handler               = "lambda_function.lambda_handler"
  kms_name              = "lambda-test-cmk-key-aicg"
  kms_description       = "CMK for encrypting lambda"
  s3_bucket_name        = "lambdatestbucketexample-aicg"
  bucket_object_key     = "deployment_artifact.zip"
  lambda_sg_name        = "lambda_sg_aicg"
  lambda_sg_description = "Security group for example usage with lambda"
  lambda_cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name        = "lambda_policy_aicg"
  iam_aws_service = ["lambda.amazonaws.com"]
  iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
}
