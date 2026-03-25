locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  generate_password = var.admin_password == null
}
