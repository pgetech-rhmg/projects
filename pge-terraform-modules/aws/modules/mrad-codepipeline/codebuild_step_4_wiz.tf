# Secure the Docker container using Wiz.

module "wiz_scanning_iam_role" {
  count         = var.ecr_repo_urls != null ? 1 : 0
  source        = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version       = "0.0.8"
  name          = "${var.project_name}-wiz-${var.branch}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = var.tags
  inline_policy = [file("${path.module}/codebuild_iam_policies/codebuild_step_4_wiz.json")]
}

module "codebuild_wiz" {
  count                       = var.ecr_repo_urls != null ? 1 : 0
  source                      = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                     = "0.0.10"
  codebuild_project_name      = "wiz_scanning_${var.project_name}_${var.branch}"
  artifact_type               = "CODEPIPELINE"
  source_type                 = "CODEPIPELINE"
  environment_image           = var.codebuild_image
  environment_type            = "LINUX_CONTAINER"
  environment_privileged_mode = true
  concurrent_build_limit      = 1
  codebuild_project_role      = module.wiz_scanning_iam_role[0].arn
  codebuild_sc_token          = var.github_secret
  compute_type                = "BUILD_GENERAL1_LARGE"
  tags                        = var.tags
  source_buildspec            = coalesce(var.buildspec_wiz, file("${path.module}/codebuild_buildspec/buildspec_wizscan.yml"))
  vpc_id                      = data.aws_vpc.mrad_vpc.id
  subnet_ids = [
    data.aws_subnet.private1.id,
    data.aws_subnet.private2.id,
    data.aws_subnet.private3.id
  ]
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
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/wiz_scanning_${var.project_name}_${var.branch}"
    }]
  })
  encryption_key = local.kms_key_arn

  environment_variables = [
    {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_NAME"
      value = var.project_name
      type  = "PLAINTEXT"
    },
    {
      name  = "BRANCH"
      value = var.branch
      type  = "PLAINTEXT"
    },
    {
      name = "NODE_ENV"
      value = lookup(
        {
          development = "dev"
          test        = "test"
          master      = "qa"
          main        = "qa"
          production  = "prod"
        },
        var.branch,
        "dev"
      )
      type = "PLAINTEXT"
    },
    {
      name  = "WIZ_CLIENT_ID"
      value = "shared-wiz-access:WIZ_CLIENT_ID"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "WIZ_CLIENT_SECRET"
      value = "shared-wiz-access:WIZ_CLIENT_SECRET"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "DOCKER_NODE_BASEIMAGE"
      value = "${data.aws_caller_identity.current.id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.docker_node_base_image}-${local.docker_node_base_image_branch}:${var.docker_node_base_image_tag}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ECR_REGISTRY"
      value = "${data.aws_caller_identity.current.id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
      type  = "PLAINTEXT"
    },
    {
      name  = "ECR_REPO_URLS"
      value = join(" ", values(var.ecr_repo_urls))
      type  = "PLAINTEXT"
    },
    {
      name  = "LOWER_PROJECT_NAME"
      value = lower(var.project_name)
      type  = "PLAINTEXT"
    },
  ]
}
