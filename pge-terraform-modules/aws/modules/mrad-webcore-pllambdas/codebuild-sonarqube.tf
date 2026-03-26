module "sonarqube" {
  source                 = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                = "0.0.10"
  codebuild_project_name = "sonarqube_${lower(var.repo_name)}-${local.suffix}"
  artifact_type          = "CODEPIPELINE"
  source_type            = "CODEPIPELINE"
  environment_image      = "aws/codebuild/standard:7.0"
  environment_type       = "LINUX_CONTAINER"
  concurrent_build_limit = 1
  codebuild_project_role = data.aws_iam_role.build.arn
  codebuild_sc_token     = "MRAD_GITHUB_TOKEN"
  compute_type           = "BUILD_GENERAL1_LARGE"
  tags                   = var.tags
  source_buildspec       = file("${path.module}/templates/buildspec-sonarqube.yml")
  vpc_id                 = data.aws_vpc.mrad_vpc.id

  subnet_ids = [
    data.aws_subnet.mrad1.id,
    data.aws_subnet.mrad2.id,
    data.aws_subnet.mrad3.id
  ]

  security_group_ids = [data.aws_security_groups.lambda_sgs.ids[0]]

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
      "codebuild:ListBuildsForProject"],
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/sonarqube_${lower(var.repo_name)}-${var.suffix}"

    }]
  })
  # encryption_key = module.kms_key.key_arn

  environment_variables = [
    {
      name  = "REPO"
      value = var.repo_name
      type  = "PLAINTEXT"
    },
    {
      name  = "BRANCH"
      value = var.repo_branch
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_HOST"
      value = local.sonar_host
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_PROJECT_KEY_PREFIX"
      value = local.sonar_project_key_prefix
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_CLI_DOWNLOAD_URL"
      value = local.sonar_cli_download_url
      type  = local.sonar_cli_download_type
    }
  ]
}
