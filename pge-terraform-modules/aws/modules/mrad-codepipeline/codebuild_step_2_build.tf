# Build the code and run the test suite.

module "codebuild_build_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version       = "0.0.8"
  name          = "${var.project_name}-app-build-${var.branch}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = var.tags
  inline_policy = [file("${path.module}/codebuild_iam_policies/codebuild_step_2_build.json")]
}

module "codebuild_build" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "codebuild_build_${var.project_name}-${var.branch}"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = var.codebuild_image
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = module.codebuild_build_iam_role.arn
  codebuild_sc_token     = var.github_secret
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = var.tags
  source_buildspec       = var.buildspec_build
  vpc_id                 = data.aws_vpc.mrad_vpc.id
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
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/codebuild_build_${var.project_name}-${var.branch}"
    }]
  })
  encryption_key = local.kms_key_arn

  environment_variables = [
    {
      name  = "GITHUB_TOKEN"
      value = "${var.github_secret}:github"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "BRANCH"
      value = var.branch
      type  = "PLAINTEXT"
    },
  ]
}
