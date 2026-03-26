# Deploy the app to the production environment.

module "codebuild_deploy_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version       = "0.0.8"
  name          = "${var.project_name}-app-deploy-${var.branch}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = var.tags
  inline_policy = [file("${path.module}/codebuild_iam_policies/codebuild_step_5_deploy.json")]
}

module "codebuild_deploy" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "codebuild_deploy_${var.project_name}-${var.branch}"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = var.codebuild_image
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = module.codebuild_deploy_iam_role.arn
  codebuild_sc_token     = var.github_secret
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = var.tags

  environment_privileged_mode = var.privileged_deploy_stage

  source_buildspec = {
    LAMBDA = yamlencode({
      version : 0.2,
      phases : {
        build : {
          commands : [
            file("${path.module}/codebuild_buildspec/buildspec_deploy_lambda.sh"),
          ]
        }
      }
    })
    ECS  = file("${path.module}/codebuild_buildspec/buildspec_deploy_ecs.yml")
    REPO = "buildspecs/buildspec-deploy.yml"
  }[var.buildspec_deploy]

  vpc_id = data.aws_vpc.mrad_vpc.id
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
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/codebuild_deploy_${var.project_name}-${var.branch}"
    }]
  })
  encryption_key = local.kms_key_arn

  environment_variables = [
    {
      name  = "ACCOUNT_NUM"
      value = local.account_num
      type  = "PLAINTEXT"
    },
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
      name  = "LOWER_PROJECT_NAME"
      value = lower(var.project_name)
      type  = "PLAINTEXT"
    },
    {
      name  = "GITHUB_TOKEN"
      value = "${var.github_secret}:github"
      type  = "SECRETS_MANAGER"
    },
  ]
}
