# ============================================================================
# TFC Workspace Settings Module - Variables
# ============================================================================

variable "tfc_token" {
  description = "Terraform Cloud API token for authentication"
  type        = string
  sensitive   = true
}

variable "tfc_organization" {
  description = "Terraform Cloud organization name"
  type        = string
}

variable "workspace_id" {
  description = "TFC Workspace ID (not name) for configuration"
  type        = string
}

variable "workspace_name" {
  description = "TFC Workspace name for reference"
  type        = string
}

variable "enable_auto_apply_run_triggers" {
  description = "Enable auto-apply for run trigger runs"
  type        = bool
  default     = false
}

variable "source_workspace_name" {
  description = "Source workspace name for run trigger (e.g., WS2). If provided, creates run trigger from source to this workspace."
  type        = string
  default     = ""
}
