data "aws_subnet" "private1" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.envname]}-PrivateSubnet1"]
  }
}

data "aws_subnet" "private2" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.envname]}-PrivateSubnet2"]
  }
}

data "aws_subnet" "private3" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.envname]}-PrivateSubnet3"]
  }
}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.envname}-VPC"]
  }
}

data "aws_caller_identity" "current" {}

# per-account resources created by webcore-management
data "aws_iam_role" "ecs_task_role" {
  name = "webcore_ecs_task_role"
}

data "aws_iam_role" "ecs_exe_role" {
  name = "webcore_ecs_exe_role"
}

data "aws_security_group" "ecs_security_group" {
  name   = "webcore-ecs"
  vpc_id = data.aws_vpc.mrad_vpc.id
}

data "aws_iam_policy_document" "lb_logs_policy_doc" {
  #  Permit logs to be sent from the load balancer to the relevant S3 bucket
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.queries_resource_name}-lb-logs/*"]

    principals {
      type        = "AWS"
      identifiers = ["797873946194"] # This is AWS's account for Load Balancers, not one of ours
    }
  }

  #  Force SSL-only access, courtesy of binaryalert on Github
  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${local.queries_resource_name}-lb-logs",
      "arn:aws:s3:::${local.queries_resource_name}-lb-logs/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.subdomain
  private_zone = true
}

# Specific branch is used to get the commit hash for the ECS task definition
data "github_branch" "queries_current_branch" {
  repository = "Engage-Queries-ECS"
  branch     = local.git_branch
}

# KMS keys are created by the repository webcore-management
data "aws_kms_key" "s3" {
  key_id = "arn:aws:kms:${var.region}:${local.account_num}:alias/webcore_s3"
}

data "aws_kms_key" "ecr" {
  key_id = "arn:aws:kms:${var.region}:${local.account_num}:alias/webcore_ecr"
}
