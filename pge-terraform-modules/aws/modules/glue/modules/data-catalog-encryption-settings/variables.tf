#Variables for glue data catalog encryption settings
variable "connection_password_aws_kms_key_id" {
  description = "A KMS key ARN that is used to encrypt the connection password. If connection password protection is enabled, the caller of CreateConnection and UpdateConnection needs at least kms:Encrypt permission on the specified AWS KMS key, to encrypt passwords before storing them in the Data Catalog."
  type        = string
  validation {
    condition     = can(regex("arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.connection_password_aws_kms_key_id))
    error_message = "Error! Enter a valid connection password aws kms key id."
  }
}

variable "encryption_at_rest_sse_aws_kms_key_id" {
  description = "The ARN of the AWS KMS key to use for encryption at rest."
  type        = string
  validation {
    condition     = can(regex("arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.encryption_at_rest_sse_aws_kms_key_id))
    error_message = "Error! Enter a valid encryption at rest sse aws kms key id."
  }
}

variable "catalog_id" {
  description = "The ID of the Data Catalog to set the security configuration for. If none is provided, the AWS account ID is used by default."
  type        = string
  default     = null
}