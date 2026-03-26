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

# the s3 object referenced MUST be created by aws s3api put-object
# with the --checksum-algorithm SHA256 flag
data "aws_s3_object" "lambda_zip" {
  bucket         = local.s3_bucket
  key            = local.s3_key
  checksum_mode  = "ENABLED"
}
