# Variables for tags

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for workteam

variable "workteam_name" {
  description = "The name of the Workteam (must be unique)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}$", var.workteam_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "workforce_name" {
  description = "The name of the workforce."
  type        = string
}

variable "description" {
  description = "A description of the work team."
  type        = string
  default     = null
}

variable "member_definition" {
  description = <<-DOC
    cognito_member_definition:
     The Amazon Cognito user group that is part of the work team.
    oidc_member_definition:
     A list user groups that exist in your OIDC Identity Provider (IdP).One to ten groups can be used to create a single private work team.
  DOC
  type = object({
    cognito_member_definition = any
    oidc_member_definition    = any
  })
  default = {
    cognito_member_definition = {}
    oidc_member_definition    = {}
  }

  validation {
    condition     = var.member_definition.cognito_member_definition == {} && var.member_definition.oidc_member_definition == {} ? false : true
    error_message = "Error! workteam need either cognito_member_definition or oidc_member_definition."
  }

  validation {
    condition     = var.member_definition.cognito_member_definition != {} && var.member_definition.oidc_member_definition != {} ? false : true
    error_message = "Error! workteam cannot configure both cognito_member_definition and oidc_member_definition at the same time."
  }

  validation {
    condition     = var.member_definition.cognito_member_definition == {} || var.member_definition.cognito_member_definition != {} ? var.member_definition.oidc_member_definition != {} || var.member_definition.oidc_member_definition == {} : false
    error_message = "Error! when cognito_member_definition is configured oidc_member_definition should not be provided."
  }
}

variable "notification_configuration" {
  description = "Configures notification of workers regarding available or expiring work items."
  type        = map(string)
  default     = null
}