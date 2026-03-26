data "aws_caller_identity" "current" {}

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

data "aws_secretsmanager_secret_version" "tf_arbitrary_secret" {
  secret_id = "tf_arbitrary_secret"
}

data "aws_security_groups" "lambda_sgs" {
  filter {
    name   = "group-name"
    values = ["terraform-template-lambda-sg"]
  }
}

data "aws_s3_bucket" "logging_bucket" {
  # FIXME: find the policy behind the naming scheme here
  bucket = "ccoe-s3-accesslogs-spoke-${data.aws_region.current.name}-${local.aws_account_id}"
}

# reuse standard pipeline roles
# webcore-infra:/tf/modules/infra/iam.tf
data "aws_iam_role" "pipeline" {
  name = "webcore_pipeline_role"
}

data "aws_iam_role" "build" {
  name = "webcore_build_role"
}

data "aws_iam_role" "deploy" {
  name = "webcore_deploy_role"
}

data "aws_kms_key" "pipeline" {
  key_id = "alias/webcore_pipeline"
}

data "github_branch" "queries_current_branch" {
  repository = "Engage-Queries-ECS"
  branch     = var.git_branch
}

data "aws_ssm_parameter" "sonar_bin" {
  name = "/mrad/codepipeline/sonar-scanner-cli-url"
}

data "aws_partition" "current" {}
