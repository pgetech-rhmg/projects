#
#  Filename    : aws/modules/lm-lambda-pipeline/codepipeline.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.lambda_name}-pipeline"
  role_arn = module.codepipeline_iam_role.arn

  artifact_store {
    location = data.aws_ssm_parameter.archive_bucket.value
    type     = "S3"
  }

  # Stage 1
  # Source stage connecting to GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        OAuthToken           = data.aws_secretsmanager_secret_version.github_token.secret_string
        Repo                 = var.repo_name
        Branch               = local.branch
        PollForSourceChanges = "false"
        Owner                = var.github_org
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

  stage {
    name = "Deploy"

    action {
      name             = "deploy-project"
      run_order        = 3
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
