##################################################################
#
#  Filename    : aws/modules/lm-pipeline/codebuild.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
module "codebuild_build" {
  source                        = "app.terraform.io/pgetech/codebuild/aws"
  version                       = "0.1.11"
  codebuild_project_name        = "${var.application_name}_codebuild_build"
  codebuild_project_role        = module.codebuild_build_iam_role.arn
  concurrent_build_limit        = 1
  codebuild_project_description = "Build step for ${var.application_name}"
  tags                          = module.tags.tags
  artifact_type                 = "CODEPIPELINE"
  source_type                   = "CODEPIPELINE"
  environment_image             = var.codebuild_image
  environment_type              = "LINUX_CONTAINER"
  compute_type                  = "BUILD_GENERAL1_LARGE"
  codebuild_sc_token            = var.github_secret
  environment_privileged_mode   = true

  source_buildspec = templatefile("${path.module}/buildspecs/buildspec_build.yml", {
    build_path = var.build_path
  })
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
  security_group_ids = [module.security_group.sg_id]
  # codebuild_resource_policy = jsonencode({})
  codebuild_resource_policy = templatefile("${path.module}/iam_policies/codebuild_build_policy.json", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "${var.application_name}_codebuild_build" })

  environment_variables = [
    {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    },
    {
      name  = "RUN_TIME"
      value = var.runtime_version
      type  = "PLAINTEXT"
    },
    {
      name  = "GITHUB_TOKEN"
      value = var.github_secret
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ECR_REGISTRY"
      value = var.ecr_repo_url
      type  = "PLAINTEXT"
    },
    {
      name  = "BRANCH"
      value = local.branch
      type  = "PLAINTEXT"
    },
    {
      name  = "WIZ_CLIENT_ID"
      value = "${var.wiz_secret}:WIZ_CLIENT_ID"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "WIZ_CLIENT_SECRET"
      value = "${var.wiz_secret}:WIZ_CLIENT_SECRET"
      type  = "SECRETS_MANAGER"
    },
  ]
}

module "codebuild_sonar" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "${var.application_name}_codebuild_sonar"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = var.codebuild_image
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = module.codebuild_build_iam_role.arn
  codebuild_sc_token     = var.github_secret
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = module.tags.tags
  source_buildspec = templatefile("${path.module}/buildspecs/buildspec_sonar.yml", {
    build_path = var.build_path
  })
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
  security_group_ids = [module.security_group.sg_id]
  codebuild_resource_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      },
      "Action" : [
        "codebuild:BatchGetProjects",
        "codebuild:BatchGetBuilds",
        "codebuild:ListBuildsForProject"
      ],
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/${var.application_name}_codebuild_sonar"
    }]
  })

  environment_variables = [
    {
      name  = "GITHUB_TOKEN"
      value = var.github_secret
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "BRANCH"
      value = local.branch
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_CLI_DOWNLOAD_URL"
      value = var.sonar_cli_download_url
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_TOKEN"
      value = var.sonar_token
      type  = "SECRETS_MANAGER"
    }
  ]
}

module "codebuild_deploy" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "${var.application_name}_codebuild_deploy"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = var.codebuild_image
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = module.codebuild_build_iam_role.arn
  codebuild_sc_token     = var.github_secret
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = module.tags.tags
  source_buildspec = {
    LAMBDA = templatefile("${path.module}/buildspecs/buildspec_lambda_deploy.yml", {
      application_name = var.application_name
    })
    # TODO: Update EKS buildspec with process to deploy EKS services
    EKS = templatefile("${path.module}/buildspecs/buildspec_eks_deploy.yml", {})
  }[var.pipeline_type]
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
  security_group_ids = [module.security_group.sg_id]
  codebuild_resource_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      },
      "Action" : [
        "codebuild:BatchGetProjects",
        "codebuild:BatchGetBuilds",
        "codebuild:ListBuildsForProject"
      ],
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/${var.application_name}_codebuild_deploy"
    }]
  })

  environment_variables = [
    {
      name  = "GITHUB_TOKEN"
      value = var.github_secret
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "BRANCH"
      value = local.branch
      type  = "PLAINTEXT"
    },
    {
      name  = "ECR_REGISTRY"
      value = var.ecr_repo_url
      type  = "PLAINTEXT"
    },
  ]
}
