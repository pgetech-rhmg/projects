variable "service_name" {
  type        = string
  description = "The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which the endpoint will be used"
  validation {
    condition     = can(regex("^vpc-\\w+", var.vpc_id))
    error_message = "VPC-ID is required and the allowed format of vpc-id is vpc-#################."
  }
}

variable "auto_accept" {
  type        = string
  description = "Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account)"
  default     = null
}

variable "policy" {
  type        = string
  default     = "{}"
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform."

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for VPC endpoint."
  }
}

variable "route_table_ids" {
  type        = list(any)
  description = "One or more route table IDs"
  default     = null
  validation {
    condition = alltrue([
      for i in var.route_table_ids : can(regex("^rtb-([a-zA-Z0-9])+(.*)$", i))
    ])
    error_message = "Route-table-id is required and the allowed format of 'route_table_ids' is rtb-#################."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}