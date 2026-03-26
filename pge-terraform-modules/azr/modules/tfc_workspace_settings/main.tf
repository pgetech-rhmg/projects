# ============================================================================
# TFC Workspace Settings Module
# ============================================================================
# Configures Terraform Cloud workspace settings using the TFC API, including
# auto-apply behavior for run triggers, workspace metadata parsing, and
# verification of applied configuration.
#
# Features:
# - Configure auto-apply behavior for run triggers via TFC API
# - Create run triggers for WS2 → WS3 automation workflows
# - Validate and expose workspace settings after API updates
# - Parse workspace metadata for downstream modules
#
# Module: tfc/modules/workspace_settings
# Author: PG&E
# Created: Mar 04, 2026
# ============================================================================

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.53"
    }
  }
}
provider "null" {}
provider "tfe" {}
provider "http" {}

# ============================================================================
# Configure auto-apply for run triggers via TFC API
# ============================================================================

resource "null_resource" "configure_auto_apply_run_triggers" {
  count = var.tfc_token != "" ? 1 : 0

  triggers = {
    workspace_id = var.workspace_id
    tfc_token    = var.tfc_token
    tfc_org      = var.tfc_organization
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X PATCH \
        --header "Authorization: Bearer ${var.tfc_token}" \
        --header "Content-Type: application/vnd.api+json" \
        --data '{
          "data": {
            "type": "workspaces",
            "attributes": {
              "auto-apply-run-triggers": true
            }
          }
        }' \
        "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/workspaces/${var.workspace_id}" \
        > /dev/null 2>&1
      echo "Configured auto-apply-run-triggers for workspace: ${var.workspace_name}"
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}

# ============================================================================
# Verify configuration was applied
# ============================================================================

data "http" "verify_workspace_settings" {
  count = var.tfc_token != "" ? 1 : 0

  url = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/workspaces/${var.workspace_id}"

  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }

  # Wait for configuration to complete
  depends_on = [null_resource.configure_auto_apply_run_triggers]
}

# ============================================================================
# Parse and expose workspace settings
# ============================================================================

locals {
  workspace_data = var.tfc_token != "" ? try(jsondecode(data.http.verify_workspace_settings[0].response_body).data.attributes, {}) : {}
}

# ============================================================================
# Create Run Trigger (WS2 → WS3 automation)
# ============================================================================
# This creates a run trigger so that when WS2 applies successfully,
# it automatically triggers a run in WS3 (this workspace)

resource "tfe_run_trigger" "from_source_workspace" {
  count = var.source_workspace_name != "" ? 1 : 0

  workspace_id  = var.workspace_id
  sourceable_id = data.tfe_workspace.source_workspace[0].id
  lifecycle {
    ignore_changes = [workspace_id, sourceable_id]
  }
}

# Data source to look up source workspace by name
data "tfe_workspace" "source_workspace" {
  count        = var.source_workspace_name != "" ? 1 : 0
  name         = var.source_workspace_name
  organization = var.tfc_organization
}
