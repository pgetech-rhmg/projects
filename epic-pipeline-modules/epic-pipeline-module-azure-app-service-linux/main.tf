resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  os_type  = "Linux"
  sku_name = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {

    always_on = true

    dynamic "application_stack" {
      for_each = var.runtime == "node" ? [1] : []
      content {
        node_version = var.node_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version = var.dotnet_version
      }
    }
  }

  app_settings = local.merged_app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

