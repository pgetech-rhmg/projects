# Variable for tags
variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for stack
variable "name" {
  description = "Unique name for the AppStream stack."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "description" {
  description = "Description for the AppStream stack."
  type        = string
  default     = null
}

variable "display_name" {
  description = "Stack name to display."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,100}$", var.display_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "feedback_url" {
  description = "URL that users are redirected to after they click the Send Feedback link. If no URL is specified, no Send Feedback link is displayed."
  type        = string
  default     = null
}

variable "redirect_url" {
  description = "URL that users are redirected to after their streaming session ends."
  type        = string
  default     = null
}

variable "embed_host_domains" {
  description = "Domains where AppStream 2.0 streaming sessions can be embedded in an iframe. You must approve the domains that you want to host embedded AppStream 2.0 streaming sessions."
  type        = list(string)
  default     = null
}

variable "user_settings" {
  description = "Configuration block for the actions that are enabled or disabled for users during their streaming sessions."
  type        = list(any)
  default     = []
  validation {
    condition     = alltrue([for ki, vi in var.user_settings : contains(["CLIPBOARD_COPY_FROM_LOCAL_DEVICE", "CLIPBOARD_COPY_TO_LOCAL_DEVICE", "DOMAIN_PASSWORD_SIGNIN", "DOMAIN_SMART_CARD_SIGNIN", "FILE_DOWNLOAD", "FILE_UPLOAD", "PRINTING_TO_LOCAL_DEVICE"], vi) if ki == "action"])
    error_message = "Allowed values for action: CLIPBOARD_COPY_FROM_LOCAL_DEVICE, CLIPBOARD_COPY_TO_LOCAL_DEVICE, DOMAIN_PASSWORD_SIGNIN, DOMAIN_SMART_CARD_SIGNIN, FILE_DOWNLOAD, FILE_UPLOAD, PRINTING_TO_LOCAL_DEVICE."
  }

  validation {
    condition     = alltrue([for ki, vi in var.user_settings : contains(["ENABLED", "DISABLED"], vi) if ki == "permission"])
    error_message = "Valid values for permission are ENABLED and DISABLED."
  }
}

variable "storage_connectors" {
  description = "Type of storage connector."
  type        = list(any)
  default     = []
}

variable "application_settings" {
  description = "Settings for application settings persistence."
  type        = list(any)
  default     = []
}

variable "access_endpoints" {
  description = "Set of configuration blocks defining the interface VPC endpoints. Users of the stack can connect to AppStream 2.0 only through the specified endpoints."
  type        = list(any)
  default     = []
  validation {
    condition     = alltrue([for ki, vi in var.access_endpoints : contains(["STREAMING"], vi) if ki == "endpoint_type"])
    error_message = "Valid value for endpoint_type is STREAMING."
  }
}