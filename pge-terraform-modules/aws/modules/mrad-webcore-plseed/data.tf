data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.environment_name}-VPC"]
  }
}

data "aws_subnet" "mrad1" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet1"]
  }
}

data "aws_subnet" "mrad2" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet2"]
  }
}

data "aws_subnet" "mrad3" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet3"]
  }
}

data "aws_security_group" "lambda_sgs" {
  filter {
    name   = "group-name"
    values = ["terraform-template-lambda-sg"]
  }
}

# reuse standard pipeline roles
# webcore-infra:/tf/modules/infra/iam.tf
data "aws_iam_role" "pipeline" {
  name = "webcore_pipeline_role"
}

data "aws_iam_role" "build" {
  name = "webcore_build_role"
}

data "aws_iam_role" "neptune" {
  name = "webcore_neptune_s3load_role"
}

data "aws_kms_key" "pipeline" {
  key_id = "alias/webcore_pipeline"
}

data "aws_ssm_parameter" "mrad_github_token" {
  name = "MRAD_GITHUB_TOKEN"
}
