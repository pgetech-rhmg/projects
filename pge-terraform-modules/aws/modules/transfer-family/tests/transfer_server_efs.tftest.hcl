run "transfer_server_efs" {
  command = apply

  module {
    source = "./examples/transfer_server_efs"
  }
}

variables {
  aws_region                 = "us-west-2"
  account_num                = "056672152820"
  aws_role                   = "CloudAdmin"
  kms_role                   = "TF_Developers"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  optional_tags              = { service = "transfer-family" }
  ssm_parameter_vpc_id       = "/vpc/id"
  ssm_parameter_subnet_id1   = "/vpc/2/privatesubnet1/id"
  name                       = "example"
  endpoint_type              = "VPC"
  directory_id               = "d-92670c4e30"
  policy_arns                = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  aws_service                = ["transfer.amazonaws.com", "lambda.amazonaws.com"]
  source_file_location       = "$${original.file}"
  type1                      = "COPY"
  type2                      = "CUSTOM"
  type3                      = "DELETE"
  type4                      = "TAG"
  timeout_seconds            = 60
  bucket_object_key          = "labels.csv"
  description                = "testing aws lambda"
  runtime                    = "python3.9"
  handler                    = "lambda_function.lambda_handler"
  local_zip_source_directory = "lambda_source_code"
  external_id                = "S-1-1-12-1234567890-1234567890-1234567890-1234"
  gid                        = 1000
  uid                        = 1000
  secondary_gids             = null
}
