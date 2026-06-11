locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  effective_trail_name = coalesce(
    var.custom_trail_name,
    "pge-epic-${var.app_name}-${var.environment}"
  )

  manage_cloudwatch_logs = var.cloudwatch_logs_group_arn != null && var.cloudwatch_logs_role_arn != null

  data_classification    = try(var.tags["DataClassification"], "")
  is_high_classification = contains(["Confidential", "Restricted", "Privileged"], local.data_classification)
}
