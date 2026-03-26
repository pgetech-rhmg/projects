/*
 * # PG&E Mrad ECS Module
 *  MRAD specific composite CW rules module to provision SAF compliant resources
*/
#
# Filename    : modules/mrad-cw-rules/main.tf
# Date        : 30 May 2023
# Author      : MRAD (mrad@pge.com)
# Description : This terraform module provisions a cloudwatch rule to trigger a lambda or ECS task
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  private_subnet1 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet1" : var.subnet1
  private_subnet2 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet2" : var.subnet2
  private_subnet3 = var.partner == "MRAD" ? "${var.partner}-${var.subnet_qualifier[var.aws_account]}-PrivateSubnet3" : var.subnet3
}

data "aws_subnet" "private1" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet1]
  }
}

data "aws_subnet" "private2" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet2]
  }
}

data "aws_subnet" "private3" {
  filter {
    name   = "tag:Name"
    values = [local.private_subnet3]
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  name                = "${var.name}-Rule-${var.branch}"
  schedule_expression = var.schedule
  description         = var.description
  is_enabled          = var.enabled
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "target_lambda" {
  count = var.ecs == false ? 1 : 0
  rule  = aws_cloudwatch_event_rule.rule.id
  input = var.input
  arn   = var.arn

}

resource "aws_cloudwatch_event_target" "target_ecs" {
  count = var.ecs == false ? 0 : 1
  rule  = aws_cloudwatch_event_rule.rule.id
  arn   = var.arn

  // ECS Task Inputs
  role_arn = module.aws_cloudwatch_event_iam_role[0].arn

  ecs_target {
    task_definition_arn = var.task_definition_arn
    task_count          = 1

    launch_type = "FARGATE"
    network_configuration {
      security_groups = compact(concat([var.ecs_security_group_id], var.additional_security_groups))

      subnets = [
        data.aws_subnet.private1.id,
        data.aws_subnet.private2.id,
        data.aws_subnet.private3.id
      ]
    }

  }
}

module "aws_cloudwatch_event_iam_role" {
  count       = var.ecs == false ? 0 : 1
  source      = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version     = "0.0.8"
  name        = "${var.name}-Rule-Role-${var.branch}"
  aws_service = ["events.amazonaws.com"]
  tags        = var.tags
  #inline_policy
  inline_policy = [
    data.aws_iam_policy_document.invoke_ecs_task[0].json
  ]
}

data "aws_iam_policy_document" "invoke_ecs_task" {
  count = var.ecs == false ? 0 : 1
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      "${var.task_definition_arn}*"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [var.arn]
    }
  }
}
