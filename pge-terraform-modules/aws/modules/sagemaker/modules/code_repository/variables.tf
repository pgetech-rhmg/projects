variable "code_repository_name" {
  description = "The name of the Code Repository (must be unique)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$", var.code_repository_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "repository_url" {
  description = "The URL where the Git repository is located."
  type        = string
}

variable "branch" {
  description = "The default branch for the Git repository."
  type        = string
  default     = null
}

variable "secret_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS Secrets Manager secret that contains the credentials used to access the git repository. The secret must have a staging label of AWSCURRENT and must be in the following format: {'username': UserName, 'password': Password}."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:secretsmanager:\\w+(?:-\\w+)+:[[:digit:]]{12}:secret:([a-zA-Z0-9])+(.*)$", var.secret_arn)) || var.secret_arn == null
    error_message = "The secretsmanager arn is required and the allowed format of 'secretsmanager arn' is arn:aws:secretsmanager:<region>:<account-id>:secret:<secretsmanager_name>."
  }
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}