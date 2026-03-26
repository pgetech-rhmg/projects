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

variable "private_dns_enabled" {
  type        = bool
  description = "Whether or not to associate a private hosted zone with the specified VPC"
  default     = null
}

variable "subnet_ids" {
  type        = list(any)
  description = "The ID of one or more subnets in which to create a network interface for the endpoint"
  default     = null
  validation {
    condition = alltrue([
      for i in var.subnet_ids : can(regex("^subnet-([a-zA-Z0-9])+(.*)$", i))
    ])
    error_message = "Subnet_ids required and the allowed format of 'subnet_ids' is subnet-#########."
  }
}

variable "security_group_ids" {
  type        = list(any)
  description = "The ID of one or more security groups to associate with the network interface"
  default     = null
  validation {
    condition = alltrue([
      for i in var.security_group_ids : can(regex("^sg-([a-zA-Z0-9])+(.*)$", i))
    ])
    error_message = "Security_group_ids required and the allowed format of 'security_group_ids' is sg-#########."
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