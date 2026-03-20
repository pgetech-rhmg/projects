locals {
  ado_org     = "pgetech"
  ado_project = "EPIC-Pipeline"
  ado_repo    = "EPIC-Pipeline"

  principal_org_id   = "o-7vgpdbu22o"
  bucket_name_html   = ""

  tags = {
    AppID              = "2102"
    Environment        = "Dev"
    DataClassification = "Internal"
    CRIS               = "Low"
    Notify             = "rhmg@pge.com"
    Owner              = "rhmg"
    Compliance         = "None"
    Order              = 8115205
  }
}

data "aws_caller_identity" "current" {}

############################################
# Optional OIDC Provider
############################################

resource "aws_iam_openid_connect_provider" "ado" {
  count = var.create_oidc_provider ? 1 : 0

  url = "https://vstoken.dev.azure.com/${local.ado_org}"

  client_id_list = [
    "api://AzureADTokenExchange"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

############################################
# Trust Policy
############################################

data "aws_iam_policy_document" "trust" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = var.create_oidc_provider ? [aws_iam_openid_connect_provider.ado[0].arn] : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/vstoken.dev.azure.com/${local.ado_org}"]
    }

    condition {
      test     = "StringEquals"
      variable = "vstoken.dev.azure.com/${local.ado_org}:aud"
      values   = ["api://AzureADTokenExchange"]
    }

    condition {
      test     = "StringLike"
      variable = "vstoken.dev.azure.com/${local.ado_org}:sub"
      values   = ["repo:${local.ado_project}/${local.ado_repo}:*"]
    }
  }
}

############################################
# Role
############################################

resource "aws_iam_role" "epic" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600
  tags               = local.tags
}

############################################
# Permissions
############################################

data "aws_iam_policy_document" "permissions" {

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = ["*"]
    # resources = [
    #   "arn:aws:s3:::${var.bucket_name}",
    #   "arn:aws:s3:::${var.bucket_name}/*"
    # ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "epic" {
  name   = "${var.role_name}-Policy"
  policy = data.aws_iam_policy_document.permissions.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.epic.name
  policy_arn = aws_iam_policy.epic.arn
}

