data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    file("${path.module}/pge_compliance_policy.json"),
    var.custom_policy
  ]
}

resource "aws_secretsmanager_secret" "sm" {
  name        = "pge-epic-${var.app_name}-${var.environment}-secrets"
  description = var.secrets_description
  kms_key_id  = var.kms_key_id
  policy      = data.aws_iam_policy_document.combined.json

  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags

  lifecycle {
    precondition {
      condition = !(
        var.tags["DataClassification"] != "Internal" &&
        var.tags["DataClassification"] != "Public" &&
        var.kms_key_id == null
      )
      error_message = "kms_key_id is mandatory for DataClassification types other than Internal or Public."
    }
  }
}

resource "aws_secretsmanager_secret_version" "sm_secret_version" {
  count = var.secret_version_enabled && length(var.secrets) > 0 ? 1 : 0

  secret_id     = aws_secretsmanager_secret.sm.id
  secret_string = jsonencode(var.secrets)
}

resource "aws_secretsmanager_secret_rotation" "sm_secret_rotation" {
  count               = var.rotation_enabled ? 1 : 0
  secret_id           = aws_secretsmanager_secret.sm.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_after_days
  }
}

resource "aws_iam_policy" "secret_read" {
  name = "pge-epic-${var.app_name}-${var.environment}-secret-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.sm.arn
    }]
  })

  tags = var.tags
}
