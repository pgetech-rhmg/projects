# variables for workforce
variable "workforce_name" {
  description = "The name of the Workforce (must be unique)."
  type        = string
}

variable "cognito_oidc" {
  description = "An object variable contains cognito_config and oidc_config to avoid the conflict between cognito and oidc configurations"
  type = object({
    cognito_config = any
    oidc_config    = any
  })
  default = {
    cognito_config = {}
    oidc_config    = {}
  }
  validation {
    condition     = var.cognito_oidc.cognito_config == {} && var.cognito_oidc.oidc_config == {} ? false : true
    error_message = "Error! workforce need either cognito_config or oidc_config."
  }
  validation {
    condition     = var.cognito_oidc.cognito_config != {} && var.cognito_oidc.oidc_config != {} ? false : true
    error_message = "Error! workforce cannot configure both cognito_config and oidc_config at the same time."
  }
  validation {
    condition     = var.cognito_oidc.cognito_config == {} || var.cognito_oidc.cognito_config != {} ? var.cognito_oidc.oidc_config != {} || var.cognito_oidc.oidc_config == {} : false
    error_message = "Error! when cognito_config is configured oidc_config should not be provided."
  }
}

variable "cidrs" {
  description = "A list of IP address ranges Used to create an allow list of IP addresses for a private workforce. By default, a workforce isn't restricted to specific IP addresses."
  type        = list(any)
  validation {
    condition     = length(var.cidrs) > 0 && length(var.cidrs) <= 10
    error_message = "Error! CIDRS ranges is minimum of 1 ipv4 and maximum of 10 ipv4."
  }
}