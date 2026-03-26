/*
 * # AWS codepipeline example for Containarized Java module example
 * # Prerequisites : In the variables 'secretsmanager_github_token_secret_name', 'github_repo_url', 'dependency_file_location', 'artifactory_repo_key', 'project_root_directory' Provide the suitable values respectively in tfvars for testing.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_eks_java/main.tf
#  Date        : 04 Nov 2022
#  Author      : Tekyantra
#  Description : The terraform module creates a container codepipeline_eks_Java

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  custom_domain_name = var.custom_domain_name

}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key

# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = "${var.codepipeline_name}_kms_key"
#   description = "${var.codepipeline_name} codepipeline kms key"
#   policy = templatefile("${path.module}/kms_user_policy.json", {
#     account_num       = data.aws_caller_identity.current.account_id
#     codepipeline_name = var.codepipeline_name
#     #principal_orgid   = local.principal_orgid
#   })
#   tags     = merge(module.tags.tags, local.optional_tags)
#   aws_role = var.aws_role
#   kms_role = module.codepipeline_iam_role.name
# }


module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}

###########################################################################

module "codepipeline" {
  source             = "../../modules/codepipeline_eks_java"
  codepipeline_name  = var.codepipeline_name
  role_arn           = module.codepipeline_iam_role.arn
  region             = data.aws_region.current.name
  aws_account_number = var.account_num
  project_key        = var.project_key
  project_name       = var.project_name

  #Dynamic stages are added inside stages = [] block. stage "test" is addedd to test dynamic stage and a code build module is added as additional configuration.
  stages = [
    {
      name = "Deploy"
      action = [{
        name             = "deploy-helmcharts"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["build"]
        output_artifacts = ["publish"]
        version          = "1"
        run_order        = 1
        configuration = {
          ProjectName = module.helmchart_deployment.codebuild_project_id
        }
      }]
    }
  ]
  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch

  branch_codesecret      = var.branch_codesecret
  pollchanges_codesecret = var.pollchanges_codesecret

  artifact_store_location_bucket = module.s3.id
  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  environment_type_codebuild     = var.environment_type_codebuild
  environment_type_codesecret    = var.environment_type_codesecret
  environment_type_codescan      = var.environment_type_codescan
  environment_type_codepublish   = var.environment_type_codepublish
  privileged_mode_twistlockscan  = var.privileged_mode

  codebuild_role_service             = var.codebuild_role_service
  source_location_codebuild          = var.source_location_codebuild
  source_location_codesecret         = var.source_location_codesecret
  source_location_codescan           = var.source_location_codescan
  source_location_codepublish        = var.source_location_codepublish
  environment_image_codebuild        = var.environment_image_codebuild
  environment_image_codesecret       = var.environment_image_codesecret
  environment_image_codescan         = var.environment_image_codescan
  environment_image_codepublish      = var.environment_image_codepublish
  concurrent_build_limit_codepublish = var.concurrent_build_limit_codepublish
  concurrent_build_limit_codescan    = var.concurrent_build_limit_codescan
  concurrent_build_limit_codesecret  = var.concurrent_build_limit_codesecret
  concurrent_build_limit_codebuild   = var.concurrent_build_limit_codebuild
  compute_type_codebuild             = var.compute_type_codebuild
  compute_type_codesecret            = var.compute_type_codesecret
  compute_type_codescan              = var.compute_type_codescan
  compute_type_codepublish           = var.compute_type_codepublish
  artifact_path                      = var.artifact_path
  artifact_bucket_owner_access       = var.artifact_bucket_owner_access
  artifact_location                  = module.s3.id
  cidr_egress_rules                  = var.cidr_egress_rules
  sg_name                            = "codebuild-sg-${var.codepipeline_name}"
  sg_description                     = "${var.codepipeline_name} sg "
  java_runtime                       = var.java_runtime
  source_buildspec_codebuild         = file("${path.module}/buildspec_codebuild.yml")

  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  #environment_variables_codebuild - stage 2 environment variables
  environment_variables_codebuild_stage = [
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
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    }
  ]
  project_root_directory = var.project_root_directory
  #ssm parameter variables
  subnet_ids = [data.aws_ssm_parameter.subnet_id2.value]

  vpc_id                      = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token          = var.secretsmanager_github_token_secret_name
  artifactory_host            = data.aws_ssm_parameter.artifactory_host.value
  sonar_host                  = data.aws_ssm_parameter.sonar_host.value
  artifactory_docker_registry = data.aws_ssm_parameter.artifactory_docker_registry.value
  artifactory_helm_local_repo = data.aws_ssm_parameter.artifactory_helm_local_repo.value

  twistlock_console = data.aws_ssm_parameter.twistlock_console.value

  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  secretsmanager_twistlock_user_id = var.secretsmanager_twistlock_user_id
  secretsmanager_twistlock_token   = var.secretsmanager_twistlock_token

  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  ### SNS and Lambda funtion
  ##########################################################################
  # #SNS
  cidr_egress_rules_SNS_codestar    = var.cidr_egress_rules_SNS_codestar
  codestar_lambda_encryption_key_id = null # replace with module.kms_key.key_arn, after key creation
  codestar_sns_kms_key_arn          = null # replace with module.kms_key.key_arn, after key creation
  endpoint_email                    = var.endpoint_email

  # Application
  container_name          = var.container_name
  publish_docker_registry = var.publish_docker_registry
  acm_certificate_arn     = module.acm_public_certificate.acm_certificate_arn
  custom_domain_name      = local.custom_domain_name
  Environment             = var.Environment

  Notify         = join("_", var.Notify)
  is_eks_fargate = var.is_eks_fargate
  AppID          = var.AppID

  tags_codebuild = merge(module.tags.tags, local.optional_tags)

}

##########################################################################################
#To use a CodeBuild project in Dynamic stage of codepipeline, this state deployes helm charts to EKS
module "helmchart_deployment" {
  source  = "app.terraform.io/pgetech/codebuild/aws"
  version = "0.1.4"

  codebuild_project_name       = "codebuild_helmchart_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_helmchart
  environment_type             = var.environment_type_helmchart
  artifact_location            = module.s3.id
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_helmchart
  concurrent_build_limit       = var.concurrent_build_limit_helmchart
  codebuild_project_role       = "arn:aws:iam::${var.account_num}:role/${var.eks_cluster_name}-codebuild"
  compute_type                 = var.compute_type_helmchart
  tags                         = merge(module.tags.tags, local.optional_tags)
  source_buildspec             = templatefile("${path.module}/buildspec_helmchart_deploy.yml", {})
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  subnet_ids                   = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]

  security_group_ids = [module.security-group-codebuild.sg_id]
  codebuild_sc_token = var.secretsmanager_github_token_secret_name
  codebuild_resource_policy = templatefile("${path.module}/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id
    partition              = data.aws_partition.current.partition
    aws_region             = data.aws_region.current.name
    codebuild_project_name = "codebuild_helmchart_${var.codepipeline_name}"
  })

  encryption_key = null # replace with module.kms_key.key_arn, after key creation
  #buildspec environment variables
  environment_variables = [
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
      value = data.aws_ssm_parameter.artifactory_host.value
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = var.account_num
      type  = "PLAINTEXT"
    },
    {
      name  = "CONTAINER_NAME"
      value = var.container_name
      type  = "PLAINTEXT"
    },

    {
      name  = "HELMCHART_VIRTUAL"
      value = data.aws_ssm_parameter.artifactory_helm_virtual_repo.value
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
      name  = "NAMESPACE"
      value = var.namespace
      type  = "PLAINTEXT"
    }

  ]

}

#github webhook creation

module "codepipeline_webhook" {
  source            = "../../modules/codepipeline_webhook"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

#security group for codebuild - helm chart deploy
module "security-group-codebuild" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = "${var.codepipeline_name}-sg"
  description       = "${var.codepipeline_name} security"
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = var.cidr_egress_rules_codebuild
  tags              = merge(module.tags.tags, local.optional_tags)
}

# S3 bucket to store Codepipeline artifacts
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name = "s3-${var.codepipeline_name}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = merge(module.tags.tags, local.optional_tags)

}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]
}



module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.0"
  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_domain_name = local.custom_domain_name
  tags            = merge(module.tags.tags, local.optional_tags)

}
