
# ============================================================================
# OUTPUTS
# ============================================================================

output "allocated_cidr" {
  value       = local.allocated_cidr
  description = "The CIDR allocated from Infoblox via Deployment Script"
}

# Pre-calculated subnet CIDRs (calculated in PowerShell, no cidrsubnet() needed in Terraform)
output "compute_subnet_cidr" {
  value       = local.compute_subnet_cidr
  description = "Pre-calculated compute subnet CIDR (equivalent to cidrsubnet(vnet_cidr, 2, 0))"
}

output "privateendpoint_subnet_cidr" {
  value       = local.privateendpoint_subnet_cidr
  description = "Pre-calculated private endpoint subnet CIDR (equivalent to cidrsubnet(vnet_cidr, 2, 1))"
}

output "ado_agents_subnet_cidr" {
  value       = local.ado_agents_subnet_cidr
  description = "Pre-calculated ADO agents subnet CIDR (equivalent to cidrsubnet(vnet_cidr, 2, 2))"
}

output "reserved_subnet_cidr" {
  value       = local.reserved_subnet_cidr
  description = "Pre-calculated reserved subnet CIDR (equivalent to cidrsubnet(vnet_cidr, 2, 3))"
}

# DEBUG: Raw output from deployment script (helps troubleshoot parsing issues)
output "debug_raw_output" {
  value       = local.raw_output
  description = "DEBUG: Raw output from azapi deployment script resource (JSON encoded)"
  sensitive   = true
}

# DEBUG: Direct azapi output structure
output "debug_azapi_output" {
  value       = try(jsonencode(azapi_resource.deployment_script[0].output), "null")
  description = "DEBUG: Direct azapi output object"
  sensitive   = true
}

# DEBUG: Script outputs after parsing
output "debug_script_outputs_nested" {
  value       = try(jsonencode(local.script_outputs_nested), "null")
  description = "DEBUG: Nested format attempt"
  sensitive   = true
}

output "debug_script_outputs_flat" {
  value       = try(jsonencode(local.script_outputs_flat), "null")
  description = "DEBUG: Flat format attempt"
  sensitive   = true
}

output "is_placeholder" {
  value       = false # Deployment Script always gets real CIDR or fails
  description = "Always false - Deployment Script either succeeds with real CIDR or fails"
}

output "allocation_error" {
  value       = local.allocation_error_detail
  description = "Detailed error message if CIDR allocation failed"
}

output "allocation_status" {
  value = {
    success = local.allocation_success
    status  = local.script_status
    error   = local.script_error
    cidr    = local.allocated_cidr
  }
  description = "Full status of CIDR allocation including success flag and any errors"
}

output "requested_size" {
  value       = local.cidr_size
  description = "The CIDR size requested from Infoblox"
}

output "function_url" {
  value       = local.function_url
  description = "The Function App URL called by the Deployment Script (without key)"
  sensitive   = false
}

output "deployment_script_id" {
  value       = try(azapi_resource.deployment_script[0].id, "")
  description = "The Azure resource ID of the Deployment Script (for debugging)"
}

output "script_outputs" {
  value       = local.script_outputs
  description = "Full outputs from the Deployment Script"
}

output "aci_name" {
  value       = "aci-infoblox-${var.partner_name}"
  description = "Name pattern for ACI (actual name includes random suffix)"
}

output "aci_id" {
  value       = ""
  description = "Resource ID of the ACI (empty when using smart-apply.sh pre-fetch)"
}

output "aci_logs" {
  value       = "See ACI logs in Azure Portal or run: az container logs --name aci-infoblox-${var.partner_name}-* --resource-group ${azurerm_resource_group.partner_cidr.name}"
  description = "How to view ACI logs"
  sensitive   = true
}

output "partner_cidr_rg_name" {
  value       = azurerm_resource_group.partner_cidr.name
  description = "Per-partner resource group in shared subscription for CIDR allocation resources"
}