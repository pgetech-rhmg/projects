locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  effective_alias = coalesce(
    var.custom_alias,
    "alias/pge-epic-${var.app_name}-${var.environment}-${var.purpose}"
  )

  has_custom_policy = var.policy_json != null && length(trimspace(var.policy_json)) > 0
}
