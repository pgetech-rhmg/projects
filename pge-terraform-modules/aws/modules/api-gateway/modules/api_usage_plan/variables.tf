#variables for api_gateway_usage_plan
variable "usage_plan_name" {
  description = "The name of the usage plan."
  type        = string
  default     = null
}

variable "usage_plan_description" {
  description = " The description of a usage plan."
  type        = string
  default     = null
}

variable "usage_plan_product_code" {
  description = "The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace."
  type        = string
  default     = null
}

variable "api_stages" {
  description = "The associated API stages of the usage plan."
  type        = any
  default     = []
}

variable "api_quota_settings" {
  description = "The quota settings of the usage plan."
  type        = any
  default     = []
}

variable "api_throttle_settings" {
  description = "The throttling limits of the usage plan."
  type        = any
  default     = []
}

# variables for usage_plan_key
variable "usage_plan_key_type" {
  description = "The type of the API key resource. Currently, the valid key type is API_KEY."
  type        = string
  default     = null
}

variable "usage_plan_key_id" {
  description = "The identifier of the API key resource."
  type        = string
}

#Tags for usage_plan
variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}