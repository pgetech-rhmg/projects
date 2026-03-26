#variables for aws_codebuild_report_group
variable "codebuild_rg_name" {
  description = "The name of Report Group"
  type        = string
}

variable "codebuild_rg_type" {
  description = "The type of the Report Group"
  type        = string
  validation {
    condition     = var.codebuild_rg_type == "TEST" || var.codebuild_rg_type == "CODE_COVERAGE"
    error_message = "Valid values are TEST and CODE_COVERAGE."
  }
}

variable "codebuild_rg_delete_reports" {
  description = "If true, deletes any reports that belong to a report group before deleting the report group"
  type        = bool
  default     = false
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

#aws_codebuild_report_group - export_config
variable "codebuild_rg_export_type" {
  description = "The export configuration type"
  type        = string
  validation {
    condition     = var.codebuild_rg_export_type == "S3" || var.codebuild_rg_export_type == "NO_EXPORT"
    error_message = "Valid values are S3 and NO_EXPORT."
  }
}

#aws_codebuild_report_group - s3_destination
variable "codebuild_rg_bucket" {
  description = "The name of the S3 bucket where the raw data of a report are exported"
  type        = string
}

variable "codebuild_rg_kms" {
  description = "The encryption key for the report's encrypted raw data. The KMS key ARN"
  type        = string
}

variable "codebuild_rg_packaging" {
  description = "The type of build output artifact to create"
  type        = string
  default     = "NONE"
  validation {
    condition     = var.codebuild_rg_packaging == "NONE" || var.codebuild_rg_packaging == "ZIP"
    error_message = "Valid values are: NONE (default) and ZIP."
  }
}

variable "codebuild_rg_path" {
  description = "The path to the exported report's raw data results"
  type        = string
  default     = null
}

#variables for aws_codebuild_resource_policy
variable "codebuild_resource_policy" {
  description = "Policy file"
  type        = string
  default     = "{}"
  validation {
    condition     = can(jsondecode(var.codebuild_resource_policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON policy."
  }
}