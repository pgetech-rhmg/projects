###############################################################################
# EPIC — AWS IAM Role Module
#
# Tier: Tier 0 (Foundational)
#
# Responsibilities:
#   • Create a single IAM role
#   • Apply trust policy (EPIC-generated or explicit)
#   • Attach managed policies
#   • Attach optional inline policies
#
# NOTE:
#   • EPIC is responsible for generating most inputs
#   • This module enforces correctness and safety
###############################################################################

###############################################################################
# VALIDATION — HARD GUARDRAILS
###############################################################################

locals {
  use_custom_trust = var.custom_trust == true

  has_trust_definition = length(var.trusted_principals) > 0
}

# Enforce correct escape-hatch usage
resource "null_resource" "validate_custom_trust" {
  count = local.use_custom_trust && !local.has_trust_definition ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: custom_trust=true requires trusted_principals to be defined.' && exit 1"
  }
}

###############################################################################
# TRUST POLICY — GENERATED OR EXPLICIT
###############################################################################

# EPIC-generated trust policy (default path)
data "aws_iam_policy_document" "epic_trust" {
  count = local.use_custom_trust ? 0 : 1

  # NOTE:
  # EPIC injects trusted_principals even for Level 1/2 usage.
  # Users never define these directly unless using the escape hatch.

  dynamic "statement" {
    for_each = var.trusted_principals

    content {
      effect = "Allow"

      actions = [
        statement.value.type == "oidc"
          ? "sts:AssumeRoleWithWebIdentity"
          : "sts:AssumeRole"
      ]

      principals {
        type = statement.value.type == "service" ? "Service" : "Federated"

        identifiers = [
          statement.value.provider
        ]
      }

      dynamic "condition" {
        for_each = statement.value.subject != null ? [statement.value.subject] : []

        content {
          test     = "StringEquals"
          variable = "token.actions.githubusercontent.com:sub"
          values   = [condition.value]
        }
      }
    }
  }
}

# Explicit trust policy (escape hatch)
data "aws_iam_policy_document" "custom_trust" {
  count = local.use_custom_trust ? 1 : 0

  dynamic "statement" {
    for_each = var.trusted_principals

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = statement.value.type == "service" ? "Service" : "AWS"
        identifiers = compact([
          statement.value.account,
          statement.value.provider
        ])
      }
    }
  }
}

###############################################################################
# IAM ROLE
###############################################################################

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = (
    local.use_custom_trust
      ? data.aws_iam_policy_document.custom_trust[0].json
      : data.aws_iam_policy_document.epic_trust[0].json
  )

  tags = var.tags
}

###############################################################################
# MANAGED POLICY ATTACHMENTS
###############################################################################

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

###############################################################################
# INLINE POLICIES (RARE / ADVANCED)
###############################################################################

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role  = aws_iam_role.this.id
  policy = each.value
}

