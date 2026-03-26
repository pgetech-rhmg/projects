##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/codebuild.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
resource "aws_codebuild_project" "dispatch" {
  name         = "${var.repo_name}-pipelines-dispatch"
  service_role = module.codebuild_build_iam_role.arn
  tags         = module.tags.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/${var.github_org}/${var.repo_name}"
    report_build_status = true
    insecure_ssl        = false
    buildspec = yamlencode({
      version : 0.2,
      phases : {
        install : {
          commands : [
            <<-EOT
            cat << 'SCRIPT_EOF' > dispatch_pipelines.sh
            ${chomp(file("${path.module}/dispatch_pipelines.sh"))}
            SCRIPT_EOF
            EOT
            ,
            "chmod +x dispatch_pipelines.sh",
          ]
        }
        build : {
          commands : [
            "bash dispatch_pipelines.sh",
          ]
        }
      }
    })
  }

  environment {
    type         = "LINUX_CONTAINER"
    compute_type = var.compute_type
    image        = var.image

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = "system/github"
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "TFC_TOKEN"
      value = "lm/tfc_api_key"
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "ENV"
      value = lower(local.environment)
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "BRANCH"
      value = local.branch
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  vpc_config {
    vpc_id             = data.aws_ssm_parameter.vpc_id.insecure_value
    subnets            = [for s in values(data.aws_ssm_parameter.subnets) : s.value]
    security_group_ids = [module.security_group_project.sg_id]
  }
}

resource "aws_codebuild_source_credential" "codebuild_source_credential" {
  server_type = "GITHUB"
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  token       = data.aws_secretsmanager_secret_version.github_token.secret_string
}

resource "aws_codebuild_webhook" "webhook" {
  project_name = aws_codebuild_project.dispatch.name
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "${local.branch}$"
    }
  }
}
