#
# Filename    : examples/alerts/main.tf
# Description : Example usage of the Key Vault Monitoring module
#

module "kv_monitoring" {
  source = "../.."

  resource_group_name               = var.resource_group_name
  action_group_resource_group_name  = var.action_group_resource_group_name
  action_group                      = var.action_group
  key_vault_names                   = var.key_vault_names
  availability_threshold            = var.availability_threshold
  service_api_latency_threshold     = var.service_api_latency_threshold
  service_api_hit_threshold         = var.service_api_hit_threshold
  service_api_result_threshold      = var.service_api_result_threshold
  saturation_shoebox_threshold      = var.saturation_shoebox_threshold
  enable_diagnostic_settings        = var.enable_diagnostic_settings
  eventhub_namespace_name           = var.eventhub_namespace_name
  eventhub_name                     = var.eventhub_name
  eventhub_authorization_rule_name  = var.eventhub_authorization_rule_name
  log_analytics_workspace_name      = var.log_analytics_workspace_name
  log_analytics_resource_group_name = var.log_analytics_resource_group_name
  eventhub_resource_group_name      = var.eventhub_resource_group_name
  eventhub_subscription_id          = var.eventhub_subscription_id
  log_analytics_subscription_id     = var.log_analytics_subscription_id
  tags                              = var.tags
}
