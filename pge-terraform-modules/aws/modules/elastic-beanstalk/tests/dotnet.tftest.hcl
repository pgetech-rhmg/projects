run "dotnet" {
  command = apply

  module {
    source = "./examples/dotnet"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    managed_by = "Terraform"
  }
  name                             = "tf-example-dotnet"
  ssm_parameter_vpc_id             = "/vpc/id"
  ssm_parameter_subnet_id1         = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2         = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3         = "/vpc/2/privatesubnet3/id"
  environment_solution_stack_name  = "64bit Amazon Linux 2023 v3.0.0 running .NET 6"
  application_version_force_delete = "true"
  application_version_source_zip   = "dotnet.zip"
  application_version              = "v1.0.0"
  solution_stack_name              = "64bit Amazon Linux 2023 v3.0.0 running .NET 6"
  aws_service                      = ["ec2.amazonaws.com"]
  policy_arns                      = ["arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker", "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"]
  template_file_name               = "s3_alb_logs_policy.json"
  acm_domain_name                  = "nonprod.pge.com"
  organization                     = "ACME Examples, Inc"
  private_key_algorithm            = "RSA"
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  validity_period_hours = 12
}
