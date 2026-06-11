locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  base_name              = "pge-epic-${var.app_name}-${var.environment}"
  proxy_name             = coalesce(var.custom_proxy_name, "${local.base_name}-proxy")
  has_target_db_cluster  = var.target_db_cluster_identifier != null
  has_target_db_instance = var.target_db_instance_identifier != null
}
