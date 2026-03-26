##################################################################
#
#  Filename    : aws/modules/lm-lambda/data.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
data "aws_ssm_parameter" "subnets" {
  for_each = toset(var.subnets)
  name     = each.value
}

data "aws_ecr_image" "placeholder_image" {
  repository_name = "lm-lambda-placeholder"
  image_tag       = "latest"
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc
}
