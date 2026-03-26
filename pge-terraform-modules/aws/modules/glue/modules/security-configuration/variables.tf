# Variables for Glue Security Configuration

variable "glue_security_configuration_name" {
  description = "Name of the security configuration."
  type        = string
}

variable "glue_cloudwatch_encryption_kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue cloudwatch encryption."
  type        = string
}

variable "glue_job_bookmarks_encryption_kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue job bookmarks encryption."
  type        = string
}

variable "glue_s3_encryption_kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the KMS key to be used to encrypt the data for glue s3 encryption."
  type        = string
}