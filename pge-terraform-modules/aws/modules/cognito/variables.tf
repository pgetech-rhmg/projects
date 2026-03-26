variable "identity_pool_name" {
  description = "The name of the identity pool"
  type        = string
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins or not"
  type        = bool
  default     = false
}

variable "openid_connect_provider_arns" {
  description = "A list of OpenID Connect provider ARNs"
  type        = list(string)
  default     = []

}

variable "saml_provider_arns" {
  description = "A list of SAML provider ARNs"
  type        = list(string)
  default     = []
}



variable "allow_classic_flow" {
  description = "Whether the identity pool allows the classic flow or not"
  type        = bool
  default     = false
}

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

#### IAM  Variables ####
variable "description" {
  description = "Description of the role"
  type        = string
  default     = "IAM Role created by pge_team = ccoe-tf-developers"
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "path" {
  description = "The path to the role in IAM"
  type        = string
  default     = "/"
}
variable "name" {
  description = "The name prefix for these IAM resources"
  type        = string
}

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  type        = number
  default     = 3600
}

variable "permission_boundary" {
  description = "IAM policy ARN limiting the maximum access this role can have"
  type        = string
  default     = ""
}

variable "inline_policy" {
  description = "A list of strings.  Each string should contain a json string to use for this inline policy or pass as a file name in json"
  type        = list(string)
  default     = []
}
