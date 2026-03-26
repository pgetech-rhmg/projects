/*
 * AWS codepipeline for Container based rollback pipelines for eks workloads
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline/modules/codepipeline_eks_rollback/codebuild.tf
#  Date        : 12-19-2022
#  Author      : Tekyantra
#  Description : Creation of codepipeline module from codepipeline_eks_rollback
#

######################################################################

##########################################################################################
#To use a CodeBuild project in Dynamic stage of codepipeline, this state deployes helm charts to EKS 
module "helmchart_rollback" {
  source  = "app.terraform.io/pgetech/codebuild/aws"
  version = "0.1.4"

  codebuild_project_name       = "helmchart_rollback_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_helmchart
  environment_type             = var.environment_type_helmchart
  compute_type                 = var.compute_type_helmchart
  artifact_location            = var.artifact_store_location_bucket
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_helmchart
  concurrent_build_limit       = var.concurrent_build_limit_helmchart
  codebuild_project_role       = "arn:aws:iam::${var.aws_account_number}:role/${var.eks_cluster_name}-codebuild"
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_rollback_config
  cache_location               = var.cache_location_rollback_config
  cache_modes                  = var.cache_modes_rollback_config
  source_buildspec             = templatefile("${path.module}/codebuild_buildspec/buildspec_helmchart_deploy.yml", {})
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids

  security_group_ids = [module.security-group.sg_id]
  codebuild_sc_token = var.secretsmanager_github_token_secret_name
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id
    partition              = data.aws_partition.current.partition
    aws_region             = data.aws_region.current.name
    codebuild_project_name = "helmchart_rollback_${var.codepipeline_name}"
  })

  encryption_key = var.encryption_key_id
  #buildspec environment variables
  environment_variables = concat([
    {
      name  = "ARTIFACTORY_TOKEN"
      value = var.secretsmanager_artifactory_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ARTIFACTORY_USER"
      value = var.secretsmanager_artifactory_user
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = data.aws_caller_identity.current.id
      type  = "PLAINTEXT"
    },

    {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "CHART_REVISION"
      value = var.chart_revision
      type  = "PLAINTEXT"
    },
    {
      name  = "NAMESPACE"
      value = var.namespace
      type  = "PLAINTEXT"
    },
    {
      name  = "CONTAINER_NAME"
      value = var.container_name
      type  = "PLAINTEXT"
    },

  ], var.environment_variables_helmchart_rollback)

}

##############################################################################
#security greoup for codebuild projects
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = "sg_codepipeline_${var.codepipeline_name}"
  description       = "security group for sg_codepipeline_${var.codepipeline_name}"
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = var.tags_codebuild
}


