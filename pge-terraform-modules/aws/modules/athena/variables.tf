variable "athena_workgroup_name" {
  type        = string
  description = "Name of the Athena Workgroup to be created."
}

variable "output_location" {
  type        = string
  description = "S3 path where Athena query results will be stored (e.g., s3://bucket/prefix/)."
}

variable "publish_cloudwatch_metrics_enabled" {
  type        = bool
  default     = true
  description = "Enables publishing of Athena Workgroup metrics to CloudWatch."
}

variable "enforce_workgroup_configuration" {
  type        = bool
  default     = true
  description = "If true, enforces Workgroup settings and prevents client overrides."
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional KMS key ARN used to encrypt Athena query results."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Athena Workgroup, typically merged from PG&E standard tags."
}
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

