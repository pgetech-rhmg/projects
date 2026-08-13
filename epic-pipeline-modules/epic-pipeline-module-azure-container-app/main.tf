resource "azurerm_container_app_environment" "this" {
  name                = var.environment_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  log_analytics_workspace_id = var.log_analytics_workspace_id

  # When set, the environment is VNet-injected into this (delegated) subnet.
  # azurerm requires infrastructure_subnet_id and internal_load_balancer_enabled
  # to be specified TOGETHER — passing the LB flag (even = false) without a
  # subnet fails with "all of infrastructure_subnet_id,internal_load_balancer_enabled
  # must be specified". So only emit the LB flag when a subnet is present;
  # otherwise pass null, which Terraform treats as unset (public/Azure-managed
  # network, the default for apps that don't VNet-inject).
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.infrastructure_subnet_id != null ? var.internal_load_balancer_enabled : null

  tags = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = var.container_app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = var.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  # Registry pulled via the user-assigned identity — no admin credentials.
  dynamic "registry" {
    for_each = var.registry_server != null ? [1] : []
    content {
      server   = var.registry_server
      identity = var.user_assigned_identity_id
    }
  }

  # Secrets sourced from Key Vault via the same identity. Callers pass the
  # versionless secret ID; the platform resolves and rotates it.
  dynamic "secret" {
    for_each = { for s in var.secrets : s.name => s }
    content {
      name                = secret.value.name
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = var.user_assigned_identity_id
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = { for e in var.env : e.name => e }
        content {
          name        = env.value.name
          value       = env.value.secret_name == null ? env.value.value : null
          secret_name = env.value.secret_name
        }
      }
    }
  }

  ingress {
    external_enabled = var.ingress_external_enabled
    target_port      = var.target_port
    transport        = var.ingress_transport

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags
}
