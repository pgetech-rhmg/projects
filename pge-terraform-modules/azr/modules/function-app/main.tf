/*
* # Azure Function App Module
* Terraform module which creates SAF2.0 Azure Function App with support for multiple runtimes
*/

#  Filename    : azr/modules/function-app/main.tf
#  Date        : 4 March 2026
#  Author      : PGE
#  Description : Creates an Azure Function App with support for multiple runtimes
#  Can be deployed on ASE (Isolated) or standard App Service Plan



# Storage account for Function App (created if not provided externally)
resource "azurerm_storage_account" "function_storage" {
  count = var.storage_account_name == "" ? 1 : 0

  name                     = "stfunc${replace(var.function_app_name, "-", "")}${substr(md5(var.function_app_name), 0, 6)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

locals {
  # Use provided storage or created storage
  storage_account_name = var.storage_account_name != "" ? var.storage_account_name : azurerm_storage_account.function_storage[0].name
  storage_account_key  = var.storage_account_access_key != "" ? var.storage_account_access_key : azurerm_storage_account.function_storage[0].primary_access_key

  # Runtime stack mapping for application_stack
  dotnet_version     = var.runtime == "dotnet" ? var.runtime_version : null
  node_version       = var.runtime == "nodejs" ? var.runtime_version : null
  python_version     = var.runtime == "python" ? var.runtime_version : null
  java_version       = var.runtime == "java" ? var.runtime_version : null
  powershell_version = var.runtime == "powershell" ? var.runtime_version : null

  # Determine if using dotnet-isolated or in-process
  use_dotnet_isolated = var.runtime == "dotnet" && tonumber(split(".", var.runtime_version)[0]) >= 6
}

# Linux Function App
resource "azurerm_linux_function_app" "function" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  storage_account_name       = local.storage_account_name
  storage_account_access_key = local.storage_account_key

  https_only = var.enable_https_only

  # Required for apps running in App Service Environment (ASE) - azurerm v4.x
  vnet_image_pull_enabled = true

  # Identity - use dynamic block to handle cases where managed_identity_ids is empty
  # When UserAssigned is specified but no IDs provided, fall back to SystemAssigned only
  dynamic "identity" {
    for_each = length(var.managed_identity_ids) > 0 ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.managed_identity_ids
    }
  }

  # Fallback: SystemAssigned only when no managed identity IDs provided
  dynamic "identity" {
    for_each = length(var.managed_identity_ids) == 0 ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  site_config {
    always_on = true

    # Runtime configuration
    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version              = var.runtime_version
        use_dotnet_isolated_runtime = local.use_dotnet_isolated
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "nodejs" ? [1] : []
      content {
        node_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "python" ? [1] : []
      content {
        python_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "java" ? [1] : []
      content {
        java_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "powershell" ? [1] : []
      content {
        powershell_core_version = var.runtime_version
      }
    }
  }

  app_settings = merge(
    {
      "FUNCTIONS_EXTENSION_VERSION"    = var.functions_extension_version
      "FUNCTIONS_WORKER_RUNTIME"       = var.runtime == "nodejs" ? "node" : var.runtime
      "WEBSITE_RUN_FROM_PACKAGE"       = "1"
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    },
    # Application Insights settings (if provided)
    var.application_insights_connection_string != "" ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    } : {},
    # Legacy instrumentation key (for older SDKs)
    var.application_insights_instrumentation_key != "" ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = var.application_insights_instrumentation_key
    } : {},
    var.app_settings
  )

  tags = merge(
    var.tags,
    {
      "managed_by"    = "terraform"
      "resource_type" = "function-app"
    }
  )

  lifecycle {
    ignore_changes = all
  }
}
