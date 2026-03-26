variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
}

#######codebuild support resources
variable "vpc_id" {
  description = "enter the vpc id within which to run builds."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds."
  type        = list(string)
}

variable "codestar_lambda_encryption_key_id" {
  description = "The KMS key ARN for codestar notifications"
  type        = string
  default     = null
}

variable "codestar_sns_kms_key_arn" {
  description = "Enter the KMS key arn for encryption - codestar notifications"
  type        = string
  default     = null
}

###################### SNS Variables ##############################

variable "endpoint_email" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(any)
  default     = [""]
}

##################### Lambda variables End ################################

variable "policy" {
  description = "Valid JSON document representing a resource policy"
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for SNS."
  }
}

#vairables for codebuild security group
variable "cidr_egress_rules_SNS_codestar" {
  description = "egress rule for codestar"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "sg_description_codestar" {
  description = "snslambda security group"
  type        = string
  default     = "security group for snslambda"
}

variable "codepipeline_arn" {
  description = "codepipeline arn"
  type        = string
  default     = ""

}

variable "run_time" {
  description = "run_time version"
  type        = string
  default     = "python3.12"
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "codestar_environment" {
  description = "lambda environment"
  type        = string
}