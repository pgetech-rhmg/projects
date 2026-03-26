#
# Filename    : modules/mrad-webcore-plqueries/main.tf
# Date        : 2024-03-14
# Author      : ENGAGE (engageteam@pge.onmicrosoft.com)
# Description : This terraform module provisions a pipeline to deploy
#               a Docker container to ECS Fargate.

resource "aws_codepipeline" "pipeline" {
  name     = "${local.prefix}-${local.short_name}-${local.suffix}"
  role_arn = data.aws_iam_role.pipeline.arn

  artifact_store {
    location = module.pipeline_bucket.id
    type     = "S3"
    encryption_key {
      type = "KMS"
      id   = data.aws_kms_key.pipeline.id
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${local.prefix}-source-artifact-${local.suffix}"]

      configuration = {
        Owner  = var.repo_org
        Repo   = var.repo_name
        Branch = var.git_branch

        PollForSourceChanges = false

        OAuthToken = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
      }
    }
  }

  # Static Code Analysis with SonarQube
  stage {
    name = "Sonarqube"

    action {
      name             = "Sonarqube"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["${local.prefix}-source-artifact-${local.suffix}"]
      output_artifacts = ["${local.prefix}-sonarqube-${local.suffix}"]

      configuration = {
        ProjectName = module.sonarqube.codebuild_project_id
      }
    }
  }

  stage {
    name = "Build"

    action {
      input_artifacts  = ["${local.prefix}-source-artifact-${local.suffix}"]
      output_artifacts = ["${local.prefix}-build-artifact-${local.suffix}"]
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  tags = var.tags

  depends_on = [data.aws_iam_role.pipeline]
}

/*
  --- CodeBuild Project(s) ---
*/

resource "aws_codebuild_project" "build" {
  name           = "${local.prefix}-${local.short_name}-build-${local.suffix}"
  description    = "Build & deploy Queries container"
  build_timeout  = "15"
  service_role   = data.aws_iam_role.build.arn
  encryption_key = data.aws_kms_key.pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "NODE_ENV"
      type  = "PLAINTEXT"
      value = var.node_env
    }

    # The suffix is combined with "engage-queries-" to form the ECR name to deploy into
    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = local.suffix
    }

    environment_variable {
      name  = "PREFIX"
      type  = "PLAINTEXT"
      value = local.prefix
    }

    environment_variable {
      name  = "AWS_ACCOUNT_NUMBER"
      type  = "PLAINTEXT"
      value = lower(local.aws_account_id)
    }
  }

  source {
    type         = "CODEPIPELINE"
    insecure_ssl = false

    buildspec = templatefile("${path.module}/templates/buildspec-code.yml", {
      github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
      repo_name    = var.repo_name
    })
  }

  vpc_config {
    security_group_ids = [
      data.aws_security_groups.lambda_sgs.ids[0]
    ]

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    vpc_id = data.aws_vpc.mrad_vpc.id
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${local.prefix}-${local.short_name}-build-${local.suffix}"
      status     = "ENABLED"
    }
  }

  tags = var.tags
}

/*
    --- Webhook ---
*/

resource "aws_codepipeline_webhook" "pipeline_webhook" {
  name            = "${local.prefix}-${local.short_name}-${local.suffix}"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name

  authentication_configuration {
    secret_token = data.aws_secretsmanager_secret_version.tf_arbitrary_secret.secret_string
  }

  filter {
    json_path    = local.github_filter_json_path
    match_equals = local.github_filter_match_equals
  }

  tags = var.tags
}

resource "github_repository_webhook" "repo_webhook" {
  repository = var.repo_name
  configuration {
    url          = aws_codepipeline_webhook.pipeline_webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = data.aws_secretsmanager_secret_version.tf_arbitrary_secret.secret_string
  }

  events = [local.github_webhook_event]
}
