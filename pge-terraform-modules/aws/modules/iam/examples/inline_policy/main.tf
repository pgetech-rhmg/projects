/*
 * # AWS IAM Policy module
 * Terraform module which creates SAF2.0 IAM Policy in AWS
*/
#
# Filename    : modules/iam/examples/inline_policy
# Date        : 22 Nov 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam inline policy creation test 
#

locals {
  name               = var.name
  path               = var.path
  description        = var.description
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order 
  optional_tags      = var.optional_tags
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


#########################################
# Create Inline Policy
#########################################

module "iam_policy" {
  source      = "../../modules/iam_policy"
  name        = local.name
  path        = local.path
  description = local.description

  policy = [
    <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
  ]

  tags = merge(module.tags.tags, local.optional_tags)
}