resource "azurerm_application_insights" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  application_type    = var.application_type
  workspace_id        = var.workspace_id
  retention_in_days   = var.retention_in_days
  sampling_percentage = var.sampling_percentage

  tags = var.tags
}
