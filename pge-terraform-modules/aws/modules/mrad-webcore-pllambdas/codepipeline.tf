resource "aws_codepipeline" "pipeline" {
  name     = local.pipeline_name
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
      output_artifacts = ["${local.pipeline_name}-source-artifact"]

      configuration = {
        Owner  = local.repo_data[var.repo_name].org
        Repo   = var.repo_name
        Branch = var.repo_branch

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
      input_artifacts  = ["${local.pipeline_name}-source-artifact"]
      output_artifacts = ["${local.pipeline_name}-sonarqube-artifact"]

      configuration = {
        ProjectName = module.sonarqube.codebuild_project_id
      }
    }
  }

  stage {
    name = "BuildAndDeploy"

    action {
      input_artifacts  = ["${local.pipeline_name}-source-artifact"]
      output_artifacts = ["${local.pipeline_name}-builddeploy-artifact"]
      name             = "BuildAndDeploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_deploy.name
      }
    }
  }

  tags = var.tags

  depends_on = [data.aws_iam_role.pipeline]
}
