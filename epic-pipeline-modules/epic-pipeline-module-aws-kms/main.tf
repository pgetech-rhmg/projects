data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "default" {
  count = local.has_custom_policy ? 0 : 1

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowSecurityAdminLifecycleActions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.security_admin_role_name}"]
    }

    actions = [
      "kms:DeleteAlias",
      "kms:DisableKey",
      "kms:CancelKeyDeletion",
      "kms:EnableKey",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPrismaCloudReadWrite"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prisma_role_name}"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyFromInternet"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["kms:*"]
    resources = ["*"]

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.internal_cidr_blocks
    }

    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }

    dynamic "condition" {
      for_each = var.principal_org_id != null ? [var.principal_org_id] : []
      content {
        test     = "StringNotEquals"
        variable = "aws:PrincipalOrgID"
        values   = [condition.value]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  description                        = var.description
  key_usage                          = var.key_usage
  customer_master_key_spec           = var.customer_master_key_spec
  deletion_window_in_days            = var.deletion_window_in_days
  enable_key_rotation                = var.key_usage == "ENCRYPT_DECRYPT" && var.customer_master_key_spec == "SYMMETRIC_DEFAULT" ? var.enable_key_rotation : false
  multi_region                       = var.multi_region
  is_enabled                         = var.is_enabled
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check

  policy = local.has_custom_policy ? var.policy_json : data.aws_iam_policy_document.default[0].json

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !(var.key_usage == "ENCRYPT_DECRYPT" && var.customer_master_key_spec == "SYMMETRIC_DEFAULT" && var.enable_key_rotation == false)
      error_message = "enable_key_rotation must be true for symmetric ENCRYPT_DECRYPT keys per SAF Item #5."
    }

    precondition {
      condition     = var.bypass_policy_lockout_safety_check == false
      error_message = "bypass_policy_lockout_safety_check must remain false (SAF #29 — least-privilege management interface)."
    }
  }
}

resource "aws_kms_alias" "this" {
  name          = local.effective_alias
  target_key_id = aws_kms_key.this.key_id

  lifecycle {
    precondition {
      condition     = startswith(local.effective_alias, "alias/")
      error_message = "KMS alias name must start with 'alias/'."
    }
  }
}
