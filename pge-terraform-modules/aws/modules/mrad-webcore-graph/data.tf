data "aws_caller_identity" "current" {}

data "aws_vpc" "mrad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.environment_name}-VPC"]
  }
}

data "aws_subnet" "mrad1" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet1"]
  }
}

data "aws_subnet" "mrad2" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet2"]
  }
}

data "aws_subnet" "mrad3" {
  filter {
    name   = "tag:Name"
    values = ["MRAD-${local.subnet_qualifier[local.environment_name]}-PrivateSubnet3"]
  }
}

data "aws_security_group" "lambda_sgs" {
  filter {
    name   = "group-name"
    values = ["terraform-template-lambda-sg"]
  }
}

data "aws_iam_policy_document" "ecstasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "github_branch" "graph_current_branch" {
  repository = var.project_name
  branch     = var.repo_branch
}
