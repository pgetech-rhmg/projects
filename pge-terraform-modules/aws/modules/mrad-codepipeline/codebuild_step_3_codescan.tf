# Send the code to SonarQube for security scanning.

module "codebuild_codescan_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version       = "0.0.8"
  name          = "${var.project_name}-codescan-${var.branch}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = var.tags
  inline_policy = [file("${path.module}/codebuild_iam_policies/codebuild_step_3_codescan.json")]
}

module "codebuild_codescan" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "codebuild_codescan_${var.project_name}-${var.branch}"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = var.codebuild_image
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = module.codebuild_codescan_iam_role.arn
  codebuild_sc_token     = var.github_secret
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = var.tags
  source_buildspec       = file("${path.module}/codebuild_buildspec/buildspec_codescan.yml")
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
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/codebuild_codescan_${var.project_name}-${var.branch}"
    }]
  })
  encryption_key = local.kms_key_arn

  environment_variables = [
    {
      name  = "REPO"
      value = local.repo_name
      type  = "PLAINTEXT"
    },
    {
      name  = "BRANCH"
      value = var.branch
      type  = "PLAINTEXT"
    },
    {
      name  = "GITHUB_TOKEN"
      value = "${var.github_secret}:github"
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "SONAR_HOST"
      value = var.sonar_host
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_TOKEN"
      value = var.sonarqube_secret_name
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "SONAR_PROJECT_KEY_PREFIX"
      value = var.sonar_project_key_prefix
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_CLI_DOWNLOAD_URL"
      value = var.sonar_scanner_cli_zip_url != "" ? var.sonar_scanner_cli_zip_url : data.aws_ssm_parameter.sonar_scanner_cli_zip_url.value
      type  = "PLAINTEXT"
    }
  ]
}
