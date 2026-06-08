############################################
# App Service Plan
############################################

resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  os_type  = var.os_type
  sku_name = var.sku_name

  tags = var.tags
}

############################################
# Linux App Service
############################################

resource "azurerm_linux_web_app" "this" {
  count = local.is_linux ? 1 : 0

  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {
    always_on = local.supports_always_on

    dynamic "application_stack" {
      for_each = var.runtime == "node" ? [1] : []
      content {
        node_version = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "python" ? [1] : []
      content {
        python_version = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "java" ? [1] : []
      content {
        java_version         = local.effective_runtime_version
        java_server          = "JAVA"
        java_server_version  = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "php" ? [1] : []
      content {
        php_version = local.effective_runtime_version
      }
    }
  }

  app_settings = local.merged_app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

############################################
# Windows App Service
############################################

resource "azurerm_windows_web_app" "this" {
  count = local.is_windows ? 1 : 0

  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {
    always_on = local.supports_always_on

    dynamic "application_stack" {
      for_each = var.runtime == "node" ? [1] : []
      content {
        node_version = local.effective_runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version = "v${local.effective_runtime_version}"
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "java" ? [1] : []
      content {
        java_version              = local.effective_runtime_version
        java_embedded_server_enabled = true
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "php" ? [1] : []
      content {
        php_version = local.effective_runtime_version
      }
    }
  }

  app_settings = local.merged_app_settings

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
