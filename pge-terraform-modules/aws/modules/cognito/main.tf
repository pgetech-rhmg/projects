/*
 * # AWS Cognito identity pool.
 * Terraform module which creates SAF2.0 Cognito identity pool in AWS.
*/

#
#  Filename    : aws/modules/cognito/main.tf
#  Date        : 30 july 2024
#  Author      : PGE
#  Description : AWS Cognito identity pool Creation
#


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  namespace   = "ccoe-tf-developers"
}

# Define the Cognito Identity Pool
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  openid_connect_provider_arns     = var.openid_connect_provider_arns
  saml_provider_arns               = var.saml_provider_arns
  allow_classic_flow               = var.allow_classic_flow
  tags                             = local.module_tags

}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

# # IAM Role for Authenticated Users
resource "aws_iam_role" "authenticated" {
  name = var.name

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  description           = var.description
  path                  = var.path
  force_detach_policies = var.force_detach_policies
  permissions_boundary  = var.permission_boundary
  max_session_duration  = var.max_session_duration
  tags                  = local.module_tags

}



# Attach IAM role policy to IAM role

resource "aws_iam_role_policy" "role_policy" {
  count  = length(var.inline_policy)
  name   = "${var.name}-Inline-${count.index + 1}"
  policy = element(var.inline_policy, count.index)
  role   = aws_iam_role.authenticated.id
}

# Attach IAM Roles to Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn


  }
}

