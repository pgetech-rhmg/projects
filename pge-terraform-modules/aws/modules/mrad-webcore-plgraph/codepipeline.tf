resource "aws_codepipeline" "pipeline" {
  name     = "${lower(local.prefix)}-graph-${lower(local.suffix)}"
  role_arn = data.aws_iam_role.pipeline.arn
  tags     = var.tags

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
      output_artifacts = ["${lower(local.prefix)}-graph-source-${lower(local.suffix)}"]

      configuration = {
        Owner  = "PGEDigitalCatalyst"
        Repo   = var.repo_name
        Branch = nonsensitive(data.github_branch.graph_current_branch.branch)

        PollForSourceChanges = false

        OAuthToken = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["github"]
      }
    }
  }

  # Static Code Analysis with SonarQube
  stage {
    name = "Sonarqube"

    action {
      input_artifacts  = ["${lower(local.prefix)}-graph-source-${lower(local.suffix)}"]
      name             = "sonarqube"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["${lower(local.prefix)}-graph-sonarqube-${lower(local.suffix)}"]

      configuration = {
        ProjectName = module.sonarqube.codebuild_project_id
      }
    }
  }

  stage {
    name = "Images"

    dynamic "action" {
      for_each = var.poller_ids
      content {
        input_artifacts = ["${lower(local.prefix)}-graph-source-${lower(local.suffix)}"]
        name            = "Poller-${action.value}"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        run_order       = 1

        configuration = {
          ProjectName = aws_codebuild_project.poller[action.value].name
        }
      }
    }

    action {
      input_artifacts = ["${lower(local.prefix)}-graph-source-${lower(local.suffix)}"]
      name            = "Consumer"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1

      configuration = {
        ProjectName = aws_codebuild_project.consumer.name
      }
    }
  }
}
