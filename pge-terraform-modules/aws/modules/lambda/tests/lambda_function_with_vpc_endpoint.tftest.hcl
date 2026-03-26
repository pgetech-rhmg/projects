run "lambda_function_with_vpc_endpoint" {
  command = apply

  module {
    source = "./examples/lambda_function_with_vpc_endpoint"
  }
}

variables {
  account_num           = "750713712981"
  aws_region            = "us-west-2"
  aws_role              = "CloudAdmin"
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
  function_name         = "lambda-with-vpc-endpoint-tf-test"
  description           = "testing aws lambda with vpc endpoint"
  runtime               = "python3.9"
  handler               = "lambda_function.lambda_handler"
  source_dir            = "lambda_source_code"
  lambda_sg_name        = "lambda_sg"
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
  vpc_endpoint_sg_name        = "vpc_endpoint_security_group"
  vpc_endpoint_sg_description = "Security group for vpc endpoint"
  vpc_endpoint_cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  vpc_endpoint_cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name        = "lambda-vpc-endpoint-policy"
  iam_aws_service = ["lambda.amazonaws.com"]
  iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  service_name    = "com.amazonaws.us-west-2.lambda"
  optional_tags = {
    Name = "test_lambda"
  }
}
