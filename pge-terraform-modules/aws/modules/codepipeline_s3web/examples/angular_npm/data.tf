################################################################################
# Supporting Resources
################################################################################

data "aws_region" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "artifactory_repo_key" {
  name = var.ssm_parameter_artifactory_repo_key
}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}
