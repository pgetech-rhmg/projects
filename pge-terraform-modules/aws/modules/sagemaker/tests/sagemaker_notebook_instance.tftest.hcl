run "sagemaker_notebook_instance" {
  command = apply

  module {
    source = "./examples/sagemaker_notebook_instance"
  }
}

variables {
  account_num              = "056672152820"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  Order                    = 8115205
  optional_tags            = { service = "sagemaker" }
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
  name                     = "tf-notebook-instance-test"
  instance_type            = "ml.t2.medium"
  platform_identifier      = "notebook-al1-v1"
  volume_size              = "10"
  accelerator_types        = ["ml.eia2.medium"]
  direct_internet_access   = "Enabled"
  root_access              = "Enabled"
  lifecycle_config_name    = "aws-notebook-tf-test"
  metadata_service_version = 1
  role_service             = ["sagemaker.amazonaws.com"]
}
