variable "api_id" {
  description = "Name of the API ID"
  type        = string
}

variable "api_stage" {
  description = "Stage of the API"
  type        = string
}

variable "api_type" {
  type        = string
  description = "API Type. Internal or Public"

  validation {
    condition     = contains(["Internal", "Public"], var.api_type)
    error_message = "Valid values for API Type are (Internal, Public). Please select on these as API Type parameter."
  }
}

variable "sub_domain_name" {
  type        = string
  description = "Sub Domain Name. Dev and Test use nonprod. QA and Prod use ss"

  validation {
    condition     = contains(["nonprod", "ss"], var.sub_domain_name)
    error_message = "Valid values for Sub Domain Name are (nonprod, ss). Please select on these as Sub Domain parameter."
  }
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}