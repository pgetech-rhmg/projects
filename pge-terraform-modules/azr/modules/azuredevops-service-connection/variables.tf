# Azure DevOps Service Connections Module Variables

variable "project_id" {
  description = "ID of the Azure DevOps project"
  type        = string
}

variable "authorize_all_pipelines" {
  description = "Authorize all pipelines to use the service connections"
  type        = bool
  default     = false
}

# Azure Service Connection Variables (using MI2)
variable "create_azure_connection" {
  description = "Create Azure service connection using managed identity (temporarily disabled due to OIDC configuration issue)"
  type        = bool
  default     = false
}

variable "azure_connection_name" {
  description = "Name of the Azure service connection"
  type        = string
  default     = "Azure-Connection-MI"
}

variable "azure_connection_description" {
  description = "Description of the Azure service connection"
  type        = string
  default     = "Service connection to Azure using Managed Identity"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID (GUID only, not full resource ID)"
  type        = string
}

variable "subscription_name" {
  description = "Azure subscription name"
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the managed identity (MI2)"
  type        = string
  default     = ""
}

variable "managed_identity_id" {
  description = "Full resource ID of the managed identity (MI2) for creating federated credential"
  type        = string
  default     = ""
}

variable "create_federated_credential" {
  description = "Whether to create the federated credential (set to true explicitly, not based on computed values)"
  type        = bool
  default     = true
}

variable "managed_identity_resource_group" {
  description = "Resource group name containing the managed identity (MI2)"
  type        = string
  default     = ""
}

# GitHub Service Connection Variables (using PAT or SP1)
variable "create_github_connection" {
  description = "Create GitHub service connection using PAT"
  type        = bool
  default     = false
}

variable "github_connection_name" {
  description = "Name of the GitHub service connection"
  type        = string
  default     = "GitHub-Connection"
}

variable "github_connection_description" {
  description = "Description of the GitHub service connection"
  type        = string
  default     = "Service connection to GitHub"
}

variable "github_pat" {
  description = "GitHub Personal Access Token (sensitive) - deprecated, use OIDC instead"
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_github_oidc" {
  description = "Use GitHub OIDC (OAuth) instead of PAT for secure connection"
  type        = bool
  default     = true
}

variable "github_oauth_config_id" {
  description = "GitHub OAuth configuration ID registered in ADO organization"
  type        = string
  # OAuth config: GitHub-OIDC-PGE (from Org Settings → OAuth configurations)
  default = "170e544c-cae5-4f78-8a19-26a52d6502d7"
}

variable "authorize_all_repos" {
  description = "Grant service connection access to all repositories in the GitHub organization"
  type        = bool
  default     = false
}

# GitHub App Connection Variables
variable "create_github_app_connection" {
  description = "Create GitHub service connection using OAuth/GitHub App"
  type        = bool
  default     = false
}

variable "github_app_connection_name" {
  description = "Name of the GitHub App service connection"
  type        = string
  default     = "GitHub-App-Connection"
}

variable "github_app_connection_description" {
  description = "Description of the GitHub App service connection"
  type        = string
  default     = "Service connection to GitHub using OAuth"
}

# ============================================================================
# SONARQUBE SERVICE CONNECTION VARIABLES
# ============================================================================

variable "create_sonarqube_connection" {
  description = "Create SonarQube service connection for code quality analysis"
  type        = bool
  default     = false
}

variable "sonarqube_connection_name" {
  description = "Name of the SonarQube service connection"
  type        = string
  default     = "SonarQube"
}

variable "sonarqube_url" {
  description = "SonarQube server URL"
  type        = string
  default     = "https://sonarqube.nonprod.pge.com"
}

variable "sonarqube_token" {
  description = "SonarQube authentication token (project token or user token)"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# JFROG ARTIFACTORY SERVICE CONNECTION VARIABLES
# ============================================================================

variable "create_jfrog_connection" {
  description = "Create JFrog Artifactory service connection for artifact management"
  type        = bool
  default     = false
}

variable "jfrog_connection_name" {
  description = "Name of the JFrog Artifactory service connection"
  type        = string
  default     = "Artifactory"
}

variable "jfrog_url" {
  description = "JFrog Artifactory server URL"
  type        = string
  default     = "https://jfrog.nonprod.pge.com"
}

variable "jfrog_username" {
  description = "JFrog Artifactory username (service account)"
  type        = string
  default     = ""
}

variable "jfrog_access_token" {
  description = "JFrog Artifactory access token or API key"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# CUSTOM SERVICE CONNECTIONS
# ============================================================================

variable "custom_service_connections" {
  description = "Map of custom service connections to create"
  type = map(object({
    name        = string
    description = string
    server_url  = string
    username    = string
    password    = string
  }))
  default = {}
  # Note: Cannot mark as sensitive because it's used in for_each
  # Individual password values are still handled securely
}
