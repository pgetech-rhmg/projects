resource "aws_ssm_parameter" "this" {
  name            = local.effective_name
  description     = var.description
  type            = var.type
  value           = var.value
  tier            = var.tier
  data_type       = var.data_type
  key_id          = local.is_secure ? var.kms_key_id : null
  allowed_pattern = var.allowed_pattern
  overwrite       = var.overwrite

  tags = var.tags

  lifecycle {
    precondition {
      condition     = local.is_secure ? (var.kms_key_id != null && length(var.kms_key_id) > 0) : true
      error_message = "kms_key_id must be provided when type is SecureString (SAF Item #2)."
    }

    precondition {
      condition     = !local.is_high_classification
      error_message = "Parameter Store is not approved for Confidential / Restricted / Privileged data per SAF — use epic-pipeline-module-aws-secretmanager instead."
    }
  }
}
