/*
 * # AWS codepipeline for docker images module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline/modules/codepipeline_dockerimages/codebuild.tf
#  Date        : 28 Dec 2023
#  Author      : PGE
#  Description : creation of codepipeline module from codepipeline_dockerimages
#

######################################################################
#CodeBuild module for respective stages in codepipeline

locals {
  codebuild_inline_policy = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_twistlockscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_twistlockscan_iam_policy.json", {})]
}

module "codebuild_project" {
  source  = "app.terraform.io/pgetech/codebuild/aws"
  version = "0.1.4"

  codebuild_project_name       = "dockerbuild_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codebuild
  environment_type             = var.environment_type_codebuild
  environment_privileged_mode  = var.privileged_mode_codebuild
  artifact_location            = var.artifact_store_location_bucket
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codebuild
  codebuild_project_role       = module.codebuild_iam_role.arn
  compute_type                 = var.compute_type_codebuild
  tags                         = merge(var.tags, { pge_team = local.namespace })
  source_buildspec             = var.source_buildspec_codebuild
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "dockerbuild_${var.codepipeline_name}"
  })

  encryption_key = var.encryption_key_id

  #buildspec environment variables
  environment_variables = var.environment_variables_codebuild_stage
}

##############################################################################
#security greoup for codebuild projects
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = var.sg_name
  description       = var.sg_description
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(var.tags, { pge_team = local.namespace })
}

#################################################################################
module "codebuild_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codebuild_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
  #inline_policy
  inline_policy = local.codebuild_inline_policy
}
