resource "aws_codebuild_project" "poller" {
  for_each = toset(var.poller_ids)

  name          = "${lower(local.prefix)}-build-poller-${each.value}-${lower(local.suffix)}"
  description   = "Build and push the Poller ${each.value} docker image"
  build_timeout = "50"
  service_role  = data.aws_iam_role.deploy.arn
  tags          = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "${local.aws_account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.baseimage_name}:newest"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "NODE_ENV"
      value = lower(var.node_env)
    }

    environment_variable {
      name  = "GIT_ASKPASS"
      value = "/set_git_pass.sh"
    }

    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = lower(local.suffix)
    }

    environment_variable {
      name  = "SWAPENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "SOURCE_BRANCH"
      type  = "PLAINTEXT"
      value = var.repo_branch
    }

    environment_variable {
      name  = "TF_WORKSPACE"
      type  = "PLAINTEXT"
      value = terraform.workspace
    }

    environment_variable {
      name  = "TF_WORKSPACE_LOWER"
      type  = "PLAINTEXT"
      value = lower(terraform.workspace)
    }

    environment_variable {
      name  = "ACCOUNT_NAME"
      type  = "PLAINTEXT"
      value = lower(local.envname)
    }

    environment_variable {
      name  = "ACCOUNT_NAME_RAW"
      type  = "PLAINTEXT"
      value = local.envname
    }

    environment_variable {
      name  = "AWS_ACCOUNT_NUMBER"
      type  = "PLAINTEXT"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "SOURCE_HASH"
      type  = "PLAINTEXT"
      value = data.github_branch.graph_current_branch.sha
    }

    environment_variable {
      name  = "PREFIX"
      type  = "PLAINTEXT"
      value = var.prefix
    }

    environment_variable {
      name  = "POLLER_ID"
      type  = "PLAINTEXT"
      value = each.value
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/poller.yaml")
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
      status = "ENABLED"
    }
  }
}
