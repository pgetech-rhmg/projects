locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  base_name      = "pge-epic-${var.app_name}-${var.environment}"
  cluster_name   = coalesce(var.custom_cluster_identifier, "${local.base_name}-cluster")
  parameter_name = coalesce(var.custom_db_cluster_parameter_group_name, "${local.base_name}-cluster-pg")
  instance_pg    = coalesce(var.custom_db_parameter_group_name, "${local.base_name}-instance-pg")
  subnet_name    = coalesce(var.custom_db_subnet_group_name, "${local.base_name}-subnets")
  sg_name        = coalesce(var.custom_security_group_name, "${local.base_name}-aurora-sg")

  use_serverless_v2 = length(var.serverlessv2_scaling_configuration) > 0

  manage_master_password = var.manage_master_user_password
}
