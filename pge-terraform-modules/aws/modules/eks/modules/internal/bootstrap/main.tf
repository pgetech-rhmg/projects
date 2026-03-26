# /*
#  * # AWS codepipeline module with s3 as source provider
#  * Terraform module which creates SAF2.0 codepipeline in AWS for add_on's installation
# */
# #
# #  Filename    :  aws/modules/eks/modules/k8s-addons-pipeline/main.tf
# #  Date        : 01 August 2024
# #  Author      : ccoe-tf-developers
# #  Description : creation of codepipeline module with s3 as source provider
# #
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "time_sleep" "delay_after_event_rule" {
  create_duration = "20s"

  triggers = {
    rule_arn = aws_cloudwatch_event_rule.codebuild_create_project.arn
  }
}

locals {
  namespace                = "ccoe-tf-developers"
  module_tags              = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  is_dc_public_or_internal = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
}

################################################################################
# Supporting Resources
################################################################################
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "codebuild_git_auth" {
  name = var.codebuild_git_auth
}

data "aws_secretsmanager_secret" "argocd_git_auth" {
  name = var.argocd_git_auth
}

locals {
  codebuild_git_auth_arn       = data.aws_secretsmanager_secret.codebuild_git_auth.arn
  argocd_git_auth_arn          = data.aws_secretsmanager_secret.argocd_git_auth.arn
  bootstrap_repo_url           = var.bootstrap_repo_url != null ? var.bootstrap_repo_url : "https://github.com/pgetech/ccoe-managed-eks-addons.git"
  bootstrap_repo_ref           = var.bootstrap_repo_ref != null ? var.bootstrap_repo_ref : "main"
  codebuild_project_identifier = "eks-bootstrap-${var.cluster_name}"
  codebuild_inline_policy = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)],
    [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {
      codebuild_git_auth = local.codebuild_git_auth_arn,
      argocd_git_auth    = local.argocd_git_auth_arn,
      })]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {
      codebuild_git_auth = local.codebuild_git_auth_arn,
      argocd_git_auth    = local.argocd_git_auth_arn,
  })]
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  environment_variables = concat([
    {
      name  = "AWS_R53_ROLE"
      value = "arn:aws:iam::${var.account_num_r53}:role/TFCBR53Role"
      type  = "PLAINTEXT"
    },
    {
      name  = "ARGOCD_GIT_AUTH"
      value = var.argocd_git_auth
      type  = "PLAINTEXT"
    },
    {
      name  = "ACM_CERTIFICATE_ARN"
      value = var.acm_certificate_arn
      type  = "PLAINTEXT"
    },
    {
      name  = "HOSTED_ZONE"
      value = var.hosted_zone
      type  = "PLAINTEXT"
    },
    {
      name  = "CUSTOM_REPO_URL"
      value = var.custom_repo_url
      type  = "PLAINTEXT"
    },
    {
      name  = "CUSTOM_REPO_BRANCH"
      value = var.custom_repo_branch
      type  = "PLAINTEXT"
    },
    {
      name  = "AUTO_MODE"
      value = var.auto_mode_enabled
    },
    {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
      type  = "PLAINTEXT"
    },
    {
      name  = "VPC_ID"
      value = local.vpc_id
      type  = "PLAINTEXT"
    },
    {
      name  = "BOOTSTRAP_REPO_REF"
      value = local.bootstrap_repo_ref
      type  = "PLAINTEXT"
    },
    {
      name  = "PYTHON_RUNTIME"
      value = "3.12"
      type  = "PLAINTEXT"
    },
    {
      name  = "ACCOUNT_NUM"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    },
    {
      name  = "SUBNETS"
      value = join(",", var.subnet_ids)
      type  = "PLAINTEXT"
    },
  ], var.environment_variables_codebuild_stage)
}

######################################################################
resource "aws_codebuild_project" "codebuild_project" {
  depends_on = [
    aws_cloudwatch_event_rule.codebuild_create_project,
    aws_cloudwatch_event_target.codebuild_create_project_target,
    time_sleep.delay_after_event_rule
  ]
  name           = local.codebuild_project_identifier
  description    = "codebuild project for ${var.cluster_name}"
  build_timeout  = 61
  service_role   = module.codebuild_iam_role.arn
  encryption_key = var.encryption_key_id
  artifacts {
    type = "NO_ARTIFACTS"
  }
  source {
    type         = "GITHUB"
    insecure_ssl = false
    location     = local.bootstrap_repo_url
    auth {
      type     = "SECRETS_MANAGER"
      resource = local.codebuild_git_auth_arn
    }

    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = false
    }
    buildspec = "bootstrap/buildspec.yml"
  }

  vpc_config {
    vpc_id             = local.vpc_id
    subnets            = local.subnet_ids
    security_group_ids = [module.security-group.sg_id]
  }

  tags = local.module_tags

  environment {
    compute_type                = var.compute_type_codebuild
    image                       = var.environment_image_codebuild
    type                        = var.environment_type_codebuild
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = local.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", null)
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}

resource "aws_codebuild_resource_policy" "codebuild_resource_policy" {
  resource_arn = aws_codebuild_project.codebuild_project.arn
  policy       = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = aws_codebuild_project.codebuild_project.name })
}

##############################################################################
#security greoup for codebuild project
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name              = "${local.codebuild_project_identifier}_sg"
  description       = "security group for codebuild project ${local.codebuild_project_identifier}_sg"
  vpc_id            = local.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = local.module_tags
}

################################################################################
#iam_role module for codebuild project
module "codebuild_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "codebuild_project_${local.codebuild_project_identifier}_role"
  aws_service = ["codebuild.amazonaws.com"]
  tags        = local.module_tags
  #inline_policy
  inline_policy = local.codebuild_inline_policy
}

# EventBridge rule - created BEFORE the CodeBuild project
resource "aws_cloudwatch_event_rule" "codebuild_create_project" {
  name        = "codebuild-create-project-${var.cluster_name}"
  description = "EventBridge rule to capture successful CodeBuild CreateProject events for eks-bootstrap-${var.cluster_name}"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["codebuild.amazonaws.com"]
      eventName   = ["CreateProject"]
      requestParameters = {
        name = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${local.codebuild_project_identifier}"]
      }
    }
  })

  tags = local.module_tags
}

resource "aws_cloudwatch_event_target" "codebuild_create_project_target" {
  rule      = aws_cloudwatch_event_rule.codebuild_create_project.name
  target_id = "CodeBuildCreateProjectTarget"
  arn       = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${local.codebuild_project_identifier}"
  role_arn  = aws_iam_role.eventbridge_codebuild_role.arn
}

resource "aws_iam_role_policy" "eventbridge_codebuild_policy" {
  name = "eventbridge-codebuild-policy-${var.cluster_name}"
  role = aws_iam_role.eventbridge_codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild"
        ]
        Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${local.codebuild_project_identifier}"
      }
    ]
  })
}

# IAM role for EventBridge to trigger CodeBuild
resource "aws_iam_role" "eventbridge_codebuild_role" {
  name = "eventbridge-codebuild-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = local.module_tags
}
