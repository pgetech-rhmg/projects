# ============================================================================
# TFC Workspace Settings Module - Outputs
# ============================================================================

output "workspace_id" {
  value       = var.workspace_id
  description = "TFC Workspace ID"
}

output "workspace_name" {
  value       = var.workspace_name
  description = "TFC Workspace Name"
}

output "auto_apply_run_triggers_enabled" {
  value       = try(local.workspace_data["auto-apply-run-triggers"], false)
  description = "Whether auto-apply for run triggers is enabled"
}

output "execution_mode" {
  value       = try(local.workspace_data.execution_mode, "")
  description = "Workspace execution mode"
}

output "auto_apply" {
  value       = try(local.workspace_data.auto_apply, false)
  description = "Whether auto-apply is enabled for all runs"
}