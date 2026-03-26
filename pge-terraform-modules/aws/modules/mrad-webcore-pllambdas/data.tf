data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.envname}-VPC"]
  }
}

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

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "MRAD_GITHUB_TOKEN"
}

data "aws_security_groups" "lambda_sgs" {
  filter {
    name   = "group-name"
    values = ["terraform-template-lambda-sg"]
  }
}

# reuse standard pipeline roles
# webcore-management:/tf/modules/infra/iam.tf
data "aws_iam_role" "pipeline" {
  name = "webcore_pipeline_role"
}

data "aws_iam_role" "build" {
  name = "webcore_build_role"
}

data "aws_kms_key" "pipeline" {
  key_id = "alias/webcore_pipeline"
}

data "aws_ssm_parameter" "sonar_bin" {
  name = "/mrad/codepipeline/sonar-scanner-cli-url"
}
