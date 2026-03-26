variable "name" {
  type        = string
  description = "Name of the canary"
}

variable "runtime_version" {
  type        = string
  description = "Runtime version"
}

variable "take_screenshot" {
  type        = bool
  description = "If screenshot should be taken"
}

variable "api_hostname" {
  type        = string
  description = "hostname to test"
}

variable "api_path" {
  description = "The path for the API call , ex: /path?param=value."
  type        = string
}

variable "frequency" {
  type        = string
  description = "frequency of tests in minutes"
}

variable "reports-bucket" {
  type        = string
  description = "Name of the bucket storing canary results"
}

variable "execution_role_arn" {
  type        = string
  description = "Role to execute the canaries"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs in which to execute the canary"
}

variable "security_group_id" {
  type        = string
  description = "Security Groups used by the canary"
}




#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}