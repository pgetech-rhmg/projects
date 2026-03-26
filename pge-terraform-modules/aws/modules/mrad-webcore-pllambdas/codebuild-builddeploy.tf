resource "aws_codebuild_project" "build_deploy" {
  name           = "${var.repo_name}-builddeploy-${local.suffix}"
  description    = "Build and Deploy"
  build_timeout  = "15"
  service_role   = data.aws_iam_role.build.arn
  encryption_key = data.aws_kms_key.pipeline.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "NODE_ENV"
      type  = "PLAINTEXT"
      value = local.node_env
    }

    environment_variable {
      name  = "PREFIX"
      type  = "PLAINTEXT"
      value = local.prefix
    }

    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = local.suffix
    }

    environment_variable {
      name  = "SHORT_NAME"
      type  = "PLAINTEXT"
      value = local.short_name
    }
  }

  source {
    type         = "CODEPIPELINE"
    insecure_ssl = false

    buildspec = templatefile("${path.module}/templates/buildspec-builddeploy.yml", {
      repo_name    = var.repo_name
      node_version = local.repo_data[var.repo_name].node_version
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
      group_name = "${var.repo_name}-builddeploy-${var.suffix}"
      status     = "ENABLED"
    }
  }

  tags = var.tags
}
