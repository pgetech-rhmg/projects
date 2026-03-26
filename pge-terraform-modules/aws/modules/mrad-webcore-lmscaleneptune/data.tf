data "aws_caller_identity" "current" {}

data "aws_subnet" "mrad1" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_id}-PrivateSubnet1"]
  }
}

data "aws_subnet" "mrad2" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_id}-PrivateSubnet2"]
  }
}

data "aws_subnet" "mrad3" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_id}-PrivateSubnet3"]
  }
}

# reuse MRAD security group
data "aws_security_group" "lambda_sg" {
  filter {
    name   = "group-name"
    values = ["terraform-template-lambda-sg"]
  }
}

data "aws_ssm_parameter" "cloudutils_version" {
  name = "/webcore/cloudutils-layer-version"
}

data "aws_lambda_layer_version" "cloud_utilities" {
  layer_name = "cloud-utilities"
  version    = data.aws_ssm_parameter.cloudutils_version.value
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/lambda.zip"
}