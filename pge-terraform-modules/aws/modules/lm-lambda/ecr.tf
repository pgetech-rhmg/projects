##################################################################
#
#  Filename    : aws/modules/lm-lambda/ecr.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
module "ecr" {
  source               = "app.terraform.io/pgetech/ecr/aws"
  version              = "0.1.3"
  ecr_name             = "lambda/${var.function_name}"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  tags                 = module.tags.tags
  policy               = data.aws_iam_policy_document.ecr_policy.json
}
