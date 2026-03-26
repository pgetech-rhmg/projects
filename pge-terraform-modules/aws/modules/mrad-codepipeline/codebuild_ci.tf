/* Run CI on GitHub commits. */

resource "aws_codebuild_project" "codebuild_project" {
  count = var.ci_enable ? 1 : 0

  name         = "${local.repo_name}-ci"
  service_role = module.codebuild_build_iam_role.arn
  tags         = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/PGEDigitalCatalyst/${local.repo_name}"
    buildspec           = var.buildspec_ci != null ? var.buildspec_ci : var.buildspec_build
    report_build_status = true
  }

  environment {
    type         = var.ci_type
    compute_type = var.ci_compute_type
    image        = var.ci_image

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = "${var.github_secret}:github"
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "BRANCH"
      value = var.branch
      type  = "PLAINTEXT"
    }
  }
}

resource "aws_codebuild_source_credential" "codebuild_source_credential" {
  count = var.ci_enable ? 1 : 0

  server_type = "GITHUB"
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  token       = local.github_token
}

resource "aws_codebuild_webhook" "webhook" {
  count = var.ci_enable ? 1 : 0

  project_name = aws_codebuild_project.codebuild_project[0].name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH,PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED,PULL_REQUEST_REOPENED"
    }
  }
}
