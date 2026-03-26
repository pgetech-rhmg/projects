run "lambda_with_efs" {
  command = apply

  module {
    source = "./examples/lambda_with_efs"
  }
}

variables {
  account_num                         = "750713712981"
  aws_region                          = "us-west-2"
  aws_role                            = "CloudAdmin"
  kms_role                            = "CloudAdmin"
  vpc_id_name                         = "/vpc/id"
  subnet_id1_name                     = "/vpc/2/privatesubnet1/id"
  AppID                               = "1001"
  Environment                         = "Dev"
  DataClassification                  = "Internal"
  CRIS                                = "Low"
  Notify                              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                               = ["abc1", "def2", "ghi3"]
  Compliance                          = ["None"]
  Order                               = 8115205
  kms_name                            = "lambda-test-cmk-key"
  kms_description                     = "CMK for encrypting lambda with efs"
  function_name                       = "lambda-with-efs-tf-test"
  description                         = "testing aws lambda with efs"
  runtime                             = "python3.9"
  handler                             = "lambda_function.lambda_handler"
  file_system_config_local_mount_path = "/mnt/efs"
  source_dir                          = "lambda_source_code"
  memory_size                         = 10240
  reserved_concurrent_executions      = 8
  lambda_sg_name                      = "lambda_sg"
  lambda_sg_description               = "Security group for example usage with lambda"
  lambda_cidr_ingress_rules = [{
    from             = 2049,
    to               = 2049,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    }
  ]
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  efs_sg_name        = "lambda_efs_sg"
  efs_sg_description = "Security group for  efs"
  efs_cidr_ingress_rules = [
    {
      from             = 2049,
      to               = 2049,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  efs_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  iam_name        = "lambda_efs_policy"
  iam_aws_service = ["lambda.amazonaws.com"]
  iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess", "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"]
}
