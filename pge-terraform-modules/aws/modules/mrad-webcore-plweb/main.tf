#
# Filename    : modules/awm-webcore-plweb/main.tf
# Date        : 2024-03-14
# Author      : ENGAGE (engageteam@pge.onmicrosoft.com)
# Description : This terraform module provisions a pipeline to deploy
#               a web app to a pre-defined S3 bucket.

resource "aws_codepipeline" "pipeline" {
  name     = "${local.repo_name}-${local.suffix}"
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
      output_artifacts = ["${local.repo_name}-source-artifact-${local.suffix}"]

      configuration = {
        Owner  = "PGEDigitalCatalyst"
        # Use the variable instead of the local reference as it should not be lowercased here.
        Repo   = var.repo_name
        Branch = var.git_branch
        PollForSourceChanges = false
        OAuthToken = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
      }
    }
  }

  stage {
    name = "Build"

    action {
      input_artifacts  = ["${local.repo_name}-source-artifact-${local.suffix}"]
      output_artifacts = ["${local.repo_name}-build-artifact-${local.suffix}"]
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

  # Static Code Analysis with SonarQube
  stage {
    name = "Sonarqube"

    action {
      name             = "sonarqube"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["${local.repo_name}-sonarqube-${local.suffix}"]
      input_artifacts  = ["${local.repo_name}-source-artifact-${local.suffix}"]

      configuration = {
        ProjectName = module.sonarqube.codebuild_project_id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      input_artifacts = ["${local.repo_name}-build-artifact-${local.suffix}"]
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }

  tags = var.tags

  depends_on = [data.aws_iam_role.pipeline]
}

resource "aws_codebuild_project" "build" {
  name           = "${local.repo_name}-build-${local.suffix}"
  description    = "Build and compress"
  build_timeout  = "15"
  service_role   = data.aws_iam_role.build.arn
  encryption_key = data.aws_kms_key.pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = local.codebuild_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "NODE_ENV"
      type  = "PLAINTEXT"
      value = var.node_env
    }

    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = local.suffix
    }

  }

  source {
    type         = "CODEPIPELINE"
    insecure_ssl = false

    buildspec = templatefile("${path.module}/templates/buildspec-code.yml", {
      github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
      repo_name    = var.repo_name
      node_version = local.node_version
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
      group_name = "${local.repo_name}-build-${local.suffix}"
      status     = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "deploy" {
  name           = "${local.repo_name}-deploy-${local.suffix}"
  description    = "Deploy build artifacts to destination bucket"
  build_timeout  = "50"
  service_role   = data.aws_iam_role.deploy.arn
  encryption_key = data.aws_kms_key.pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = local.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = local.suffix
    }

    environment_variable {
      name  = "SOURCE_BRANCH"
      type  = "PLAINTEXT"
      value = var.git_branch
    }

    environment_variable {
      name  = "REPO_NAME"
      type  = "PLAINTEXT"
      value = var.repo_name
    }

    environment_variable {
      name  = "TF_WORKSPACE"
      type  = "PLAINTEXT"
      value = terraform.workspace
    }

    environment_variable {
      name  = "AWS_ACCOUNT_NUMBER"
      type  = "PLAINTEXT"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      type  = "PLAINTEXT"
      value = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
    }

    environment_variable {
      name  = "NODE_ENV"
      type  = "PLAINTEXT"
      value = var.node_env
    }

    environment_variable {
      name  = "DEST_BUCKET"
      type  = "PLAINTEXT"
      value = var.s3_bucket_id
    }

    environment_variable {
      name  = "DIST_ID"
      type  = "PLAINTEXT"
      value = var.cloudfront_distribution_id
    }

  }

  source {
    type         = "CODEPIPELINE"
    insecure_ssl = false
    buildspec    = file("${path.module}/templates/buildspec-deploy.yml")
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
      group_name = "${local.repo_name}-deploy-${local.suffix}"
      status     = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codepipeline_webhook" "pipeline_webhook" {
  name            = "${local.repo_name}-${local.suffix}"
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
  repository = local.repo_name
  configuration {
    url          = aws_codepipeline_webhook.pipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = data.aws_secretsmanager_secret_version.tf_arbitrary_secret.secret_string
  }

  events = [local.github_webhook_event]
}

module "pipeline_bucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name   = "${lower(local.repo_name)}-${local.suffix}-pipeline-logs"
  force_destroy = true
  policy        = data.aws_iam_policy_document.pipeline_bucket.json
  tags          = var.tags
}

data "aws_iam_policy_document" "pipeline_bucket" {
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      module.pipeline_bucket.arn,
      "${module.pipeline_bucket.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
