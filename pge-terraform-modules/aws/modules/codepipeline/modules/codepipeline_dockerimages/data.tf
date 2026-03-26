################################################################################
# Supporting Resources
################################################################################
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "environment" {
  name = "/general/environment"
}

