# ============================================================================
# App Service Module
# ============================================================================
# Creates an Azure App Service (Linux or Windows)
# Supports multiple runtimes: .NET, Python, Java, Node.js, etc.
# Can be deployed on ASE or public App Service Plan
# ============================================================================
# NOTE: azurerm ~> 3.0 supports dotnet_version up to 8.0
# For .NET 9.0+, upgrade to azurerm ~> 4.0
# ============================================================================

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  # HTTPS only
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

  # Site configuration
  site_config {
    # Runtime configuration based on language
    # NOTE: azurerm ~> 3.0 supports dotnet up to 8.0, nodejs, python, java
    dynamic "application_stack" {
      for_each = var.runtime == "dotnet" ? [1] : []
      content {
        dotnet_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "python" ? [1] : []
      content {
        python_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "nodejs" ? [1] : []
      content {
        node_version = var.runtime_version
      }
    }

    dynamic "application_stack" {
      for_each = var.runtime == "java" ? [1] : []
      content {
        java_version        = var.runtime_version
        java_server         = "TOMCAT"
        java_server_version = "10.0"
      }
    }

    # Common settings
    always_on          = true
    http2_enabled      = true
    websockets_enabled = true

    # Health check - v4.x requires both path and eviction time to be set together
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_path != null ? 5 : null
  }

  # App settings
  app_settings = merge(
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "DEPLOYMENT_SOURCE_URL"               = ""
      "SCM_TYPE"                            = "None"
    },
    # Application Insights settings (if provided)
    var.application_insights_connection_string != "" ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
      "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
      "APPINSIGHTS_PROFILERFEATURE_VERSION"        = "1.0.0"
      "DiagnosticServices_EXTENSION_VERSION"       = "~3"
    } : {},
    # Legacy instrumentation key (for older SDKs)
    var.application_insights_instrumentation_key != "" ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = var.application_insights_instrumentation_key
    } : {},
    var.app_settings
  )

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags = local.module_tags

  lifecycle {
    ignore_changes = all
  }
}
