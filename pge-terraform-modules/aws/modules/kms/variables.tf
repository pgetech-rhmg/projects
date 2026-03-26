variable "aws_role" {
  type        = string
  description = "AWS role for the CMK policy to assume"
}

variable "name" {
  type        = string
  description = "The display name of the CMK alias"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource."
  validation {
    condition = (
      var.deletion_window_in_days >= 7 &&
      var.deletion_window_in_days <= 30
    )
    error_message = "Must be between 7 and 30 days, inclusive."
  }
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  sensitive   = true
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "policy" {
  type        = string
  default     = "{}"
  description = "A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform."
  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Must be valid JSON for CMK policy."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key. Defaults to false"
  type        = bool
  default     = false
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}



