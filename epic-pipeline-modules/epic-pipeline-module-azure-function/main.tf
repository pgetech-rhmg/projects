resource "azurerm_service_plan" "this" {
  name                = local.plan_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  os_type  = "Linux"
  sku_name = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  service_plan_id     = azurerm_service_plan.this.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  https_only                 = var.https_only
  functions_extension_version = var.functions_extension_version

  site_config {

    dynamic "application_stack" {
      for_each = var.runtime == "node" ? [1] : []
      content {
        node_version = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version              = local.effective_runtime_version
        use_dotnet_isolated_runtime = true
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "python" ? [1] : []
      content {
        python_version = local.effective_runtime_version
      }
    }
  }

  app_settings = local.merged_app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
