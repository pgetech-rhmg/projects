locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  effective_name = coalesce(
    var.custom_name,
    "/pge-epic/${var.app_name}/${var.environment}/${var.parameter_name}"
  )

  is_secure              = var.type == "SecureString"
  data_classification    = try(var.tags["DataClassification"], "")
  is_high_classification = contains(["Confidential", "Restricted", "Privileged"], local.data_classification)
}
