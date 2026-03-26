##################################################################
#
#  Filename    : aws/modules/lm-pipeline/codepipeline.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Codepipeline terraform module creates a Codepipeline to build container images
#
##################################################################
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.application_name}-pipeline"
  role_arn = module.codepipeline_iam_role.arn

  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = data.aws_ssm_parameter.archive_bucket.value
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"

      push {
        branches {
          includes = [local.branch]
        }

        file_paths {
          includes = length(var.file_path_includes) > 0 ? local.full_file_path_includes : null
          excludes = length(var.file_path_excludes) > 0 ? local.full_file_path_excludes : null
        }
      }
    }
  }

  # Stage 1
  # Source stage connecting to GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_org}/${var.repo_name}"
        BranchName       = local.branch
      }
    }
  }

  # Application build stage
  stage {
    name = "Build"

    action {
      name             = "build-project"
      run_order        = 1
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["build"]
      input_artifacts  = ["code"]
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = module.codebuild_build.codebuild_project_id
      }
    }

    action {
      name             = "sonarqube-code-analysis"
      run_order        = 1
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = []
      input_artifacts  = ["code"]

      configuration = {
        ProjectName = module.codebuild_sonar.codebuild_project_id
      }
    }
  }

  dynamic "stage" {
    for_each = local.requires_approval_step ? [true] : []

    content {
      name = "Approval"

      action {
        name             = "approve-deployment"
        run_order        = 2
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        version          = "1"
        output_artifacts = []
        input_artifacts  = []

        configuration = {
          ExternalEntityLink = "#{BuildVariables.WIZ_REPORT}"
          CustomData         = <<EOL
          WIZ Report: #{BuildVariables.WIZ_REPORT}
          SonarQube Dashboard: https://sonarqube.io.pge.com/dashboard?branch=${local.branch}&id=${var.application_name}
          ECR Image: ${var.ecr_repo_url}
          EOL
        }
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "deploy-project"
      run_order        = 4
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = []
      input_artifacts  = ["build"]

      configuration = {
        ProjectName = module.codebuild_deploy.codebuild_project_id
        EnvironmentVariables = jsonencode([
          {
            name  = "GIT_HASH"
            value = "#{BuildVariables.GIT_HASH}"
            type  = "PLAINTEXT"
          },
        ])
      }
    }
  }

  tags = module.tags.tags
}
