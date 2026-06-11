locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  effective_configuration_set_name = coalesce(
    var.custom_configuration_set_name,
    "pge-epic-${var.app_name}-${var.environment}-ses"
  )

  manage_event_destination = var.event_destination != null
}
