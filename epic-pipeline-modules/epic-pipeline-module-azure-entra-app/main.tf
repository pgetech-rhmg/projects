data "azuread_client_config" "current" {}

# Resolve Microsoft Graph permission GUIDs by their human-readable names so
# callers pass e.g. "User.Read" / "Group.ReadWrite.All" instead of raw GUIDs.
data "azuread_service_principal" "msgraph" {
  client_id = local.microsoft_graph_app_id
}

resource "azuread_application" "this" {
  display_name     = var.display_name
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = var.sign_in_audience

  dynamic "web" {
    for_each = length(var.redirect_uris) > 0 || var.enable_id_token_issuance || var.enable_access_token_issuance ? [1] : []
    content {
      redirect_uris = var.redirect_uris
      implicit_grant {
        id_token_issuance_enabled     = var.enable_id_token_issuance
        access_token_issuance_enabled = var.enable_access_token_issuance
      }
    }
  }

  required_resource_access {
    resource_app_id = local.microsoft_graph_app_id

    # Delegated (scope) permissions.
    dynamic "resource_access" {
      for_each = toset(var.graph_delegated_permissions)
      content {
        id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[resource_access.value]
        type = "Scope"
      }
    }

    # Application (role) permissions.
    dynamic "resource_access" {
      for_each = toset(var.graph_application_permissions)
      content {
        id   = data.azuread_service_principal.msgraph.app_role_ids[resource_access.value]
        type = "Role"
      }
    }
  }

  tags = var.application_tags
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = var.app_role_assignment_required
}

resource "time_rotating" "secret" {
  rotation_days = var.secret_rotation_days
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  display_name   = var.secret_display_name

  rotate_when_changed = {
    rotation = time_rotating.secret.id
  }
}
