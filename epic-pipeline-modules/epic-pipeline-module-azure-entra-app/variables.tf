variable "display_name" {
  type        = string
  description = "Display name of the Entra application registration"
}

variable "sign_in_audience" {
  type        = string
  description = "Which accounts the application supports"
  default     = "AzureADMyOrg"

  validation {
    condition     = contains(["AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount"], var.sign_in_audience)
    error_message = "sign_in_audience must be one of: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount"
  }
}

variable "redirect_uris" {
  type        = list(string)
  description = "Web redirect URIs for the application"
  default     = []
}

variable "enable_id_token_issuance" {
  type        = bool
  description = "Enable implicit-grant ID token issuance"
  default     = true
}

variable "enable_access_token_issuance" {
  type        = bool
  description = "Enable implicit-grant access token issuance"
  default     = false
}

variable "graph_delegated_permissions" {
  type        = list(string)
  description = "Microsoft Graph delegated (scope) permission names, e.g. [\"User.Read\", \"openid\", \"profile\", \"email\"]"
  default     = []
}

variable "graph_application_permissions" {
  type        = list(string)
  description = "Microsoft Graph application (role) permission names, e.g. [\"User.ReadWrite.All\", \"Group.ReadWrite.All\"]. Require admin consent."
  default     = []
}

variable "app_role_assignment_required" {
  type        = bool
  description = "Whether an app-role assignment is required before a user/service can sign in"
  default     = false
}

variable "secret_display_name" {
  type        = string
  description = "Display name for the client secret"
  default     = "epic-managed-secret"
}

variable "secret_rotation_days" {
  type        = number
  description = "Rotate the client secret when this many days have elapsed"
  default     = 180
}

variable "application_tags" {
  type        = list(string)
  description = "Tags applied to the application registration. Entra apps take a list of string tags, not a key/value map."
  default     = []
}
