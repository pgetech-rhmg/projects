# Azure DevOps Project Module Variables

variable "project_name" {
  description = "Name of the Azure DevOps project"
  type        = string
}

variable "project_description" {
  description = "Description of the Azure DevOps project"
  type        = string
  default     = ""
}

variable "project_visibility" {
  description = "Visibility of the project (private or public)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.project_visibility)
    error_message = "Project visibility must be either 'private' or 'public'."
  }
}

variable "version_control" {
  description = "Version control system (Git or Tfvc)"
  type        = string
  default     = "Git"
}

variable "work_item_template" {
  description = "Work item template (Agile, Basic, Scrum, CMMI)"
  type        = string
  default     = "Agile"
}

variable "enable_boards" {
  description = "Enable Azure Boards feature"
  type        = string
  default     = "enabled"
}

variable "enable_repos" {
  description = "Enable Azure Repos feature"
  type        = string
  default     = "enabled"
}

variable "enable_pipelines" {
  description = "Enable Azure Pipelines feature"
  type        = string
  default     = "enabled"
}

variable "enable_testplans" {
  description = "Enable Azure Test Plans feature"
  type        = string
  default     = "disabled"
}

variable "enable_artifacts" {
  description = "Enable Azure Artifacts feature"
  type        = string
  default     = "enabled"
}

# Managed Identity Variables (now passed from parent, not created here)
variable "managed_identity_id" {
  description = "Resource ID of the pre-created managed identity (MI2)"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID (Object ID) of the pre-created managed identity (MI2)"
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID (Application ID) of the pre-created managed identity (MI2)"
  type        = string
}

variable "managed_identity_descriptor" {
  description = "Azure DevOps identity descriptor for the managed identity (required for project permissions)"
  type        = string
  default     = ""
}

# AD Group for Team Access
variable "ad_group_object_id" {
  description = "Object ID of Azure AD group to grant team-level access to ADO project"
  type        = string
  default     = ""
}

# AD Group Descriptor for Admin Access
variable "admin_group_descriptor" {
  description = "Azure DevOps identity descriptor for Azure AD group to grant admin permissions (e.g., from 'az devops admin group list')"
  type        = string
  default     = ""
}

# Readers Group Descriptor
variable "readers_group_descriptor" {
  description = "Azure DevOps identity descriptor for Azure AD group to grant read-only permissions"
  type        = string
  default     = ""
}

# Per-Partner Security Groups from YAML Manifest
variable "read_only_groups" {
  description = "List of Azure AD group object IDs to grant read-only access (from YAML security.read_only_groups)"
  type        = list(string)
  default     = []
}

variable "read_write_groups" {
  description = "List of Azure AD group object IDs to grant contributor access (from YAML security.read_write_groups)"
  type        = list(string)
  default     = []
}

# MI1 Access Variables
variable "mi1_object_id" {
  description = "Object ID of MI1 (from subscription automation) to grant pipeline creation permissions"
  type        = string
  default     = ""
}

# GitHub Repository & Pipeline Configuration
variable "github_repo_url" {
  description = "Full URL to GitHub repository (e.g., https://github.com/owner/repo.git)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to Azure resources"
  type        = map(string)
  default     = {}
}

# NOTE: GitHub pipeline variables (github_repo_url, github_repo_branch, 
# pipeline_yaml_path, github_connection_id, enable_pipeline) are no longer
# used in this module. Pipeline creation is now handled separately at the
# ado-automation level to avoid circular dependencies.
