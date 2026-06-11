locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  effective_log_group_name = coalesce(
    var.custom_log_group_name,
    "/pge-epic/${var.app_name}/${var.environment}/${var.log_group_name}"
  )

  manage_log_group      = var.log_group_name != null || var.custom_log_group_name != null
  manage_metric_filters = length(var.metric_filters) > 0
  manage_dashboard      = var.dashboard_body != null
  effective_dashboard   = coalesce(var.custom_dashboard_name, "pge-epic-${var.app_name}-${var.environment}")

  data_classification    = try(var.tags["DataClassification"], "")
  is_high_classification = contains(["Confidential", "Restricted", "Privileged"], local.data_classification)
}
