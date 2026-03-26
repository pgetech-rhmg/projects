
/*
 * # AWS codepipeline for Container based NodeJS application module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline_container/examples/eks_nodejs/data.tf
#  Date        : 03 November 2022 
#  Author      : Tekyantra
#  Description : creation of codepipeline module from eks_nodejs
# 

################################################################################
# Supporting Resources
################################################################################

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

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

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "artifactory_repo_name" {
  name = var.ssm_parameter_artifactory_repo_name
}

data "aws_ssm_parameter" "artifactory_docker_registry" {
  name = var.ssm_parameter_artifactory_docker_registry
}
data "aws_ssm_parameter" "artifactory_helm_virtual_repo" {
  name = var.ssm_parameter_artifactory_helm_virtual_repo
}

data "aws_ssm_parameter" "artifactory_helm_local_repo" {
  name = var.ssm_parameter_artifactory_helm_local_repo
}

data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }
}

