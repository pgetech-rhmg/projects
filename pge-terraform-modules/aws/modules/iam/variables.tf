variable "name" {
  description = "The name prefix for these IAM resources"
  type        = string
}

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

variable "trusted_aws_principals" {
  description = "A list of AWS trusted principals allowed to assume this role.  Required if the aws_service variable is not provided."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.trusted_aws_principals) == length(distinct(var.trusted_aws_principals))
    error_message = "All elements of trusted_aws_principals must be unique."
  }
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.aws_service) == length(distinct(var.aws_service))
    error_message = "All elements of aws_service must be unique."
  }
}

variable "inline_policy" {
  description = "A list of strings.  Each string should contain a json string to use for this inline policy or pass as a file name in json"
  type        = list(string)
  default     = []
}

variable "policy_arns" {
  description = "A list of managed IAM policies arns to attach to the IAM role"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.policy_arns) == length(distinct(var.policy_arns))
    error_message = "All policy arns must be unique."
  }
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

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
