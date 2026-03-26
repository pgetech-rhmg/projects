# Variables for glue ml transform

variable "ml_transform_name" {
  description = "The name you assign to this ML Transform. It must be unique in your account."
  type        = string
}

variable "glue_database_name" {
  description = "A database name in the AWS Glue Data Catalog."
  type        = string
}

variable "table_name" {
  description = "A table name in the AWS Glue Data Catalog."
  type        = string
}

variable "catalog_id" {
  description = "A unique identifier for the AWS Glue Data Catalog."
  type        = string
  default     = null
}

variable "connection_name" {
  description = "The name of the connection to the AWS Glue Data Catalog."
  type        = string
  default     = null
}

variable "transform_type" {
  description = "The type of machine learning transform."
  type        = string
}

variable "accuracy_cost_trade_off" {
  description = "The value that is selected when tuning your transform for a balance between accuracy and cost."
  type        = number
  default     = null
}

variable "enforce_provided_labels" {
  description = "The value to switch on or off to force the output to match the provided labels from users."
  type        = bool
  default     = null
}

variable "precision_recall_trade_off" {
  description = "The value selected when tuning your transform for a balance between precision and recall."
  type        = number
  default     = null
}

variable "primary_key_column_name" {
  description = "The name of a column that uniquely identifies rows in the source table."
  type        = string
  default     = null
}

variable "role_arn" {
  description = "The ARN of the IAM role associated with this ML Transform."
  type        = string
}

variable "description" {
  description = "Description of the ML Transform."
  type        = string
  default     = null
}

variable "glue_version" {
  description = "The version of glue to use, for example 1.0. For information about available versions."
  type        = string
  default     = null
}

variable "max_retries" {
  description = "The maximum number of times to retry this ML Transform if it fails."
  type        = number
  default     = null
}

variable "timeout" {
  description = "The ML Transform timeout in minutes. The default is 2880 minutes (48 hours)."
  type        = number
  default     = 2800
}

variable "ml_transform" {
  description = <<-DOC
    worker_type:
     The type of predefined worker that is allocated when an ML Transform runs. Accepts a value of Standard, G.1X, or G.2X.
    number_of_workers:
     The number of workers of a defined worker_type that are allocated when an ML Transform runs. Required with worker_type.
    max_capacity:
     The number of AWS Glue data processing units (DPUs) that are allocated to task runs for this transform. You can allocate from 2 to 100 DPUs; the default is 10. max_capacity is a mutually exclusive option with number_of_workers and worker_type.
    DOC
  type = object({
    worker_type       = string
    number_of_workers = number
    max_capacity      = number
  })
  default = {
    worker_type       = null
    number_of_workers = null
    max_capacity      = 10
  }
  validation {
    condition = anytrue([
      var.ml_transform.worker_type == null,
      var.ml_transform.worker_type == "Standard",
      var.ml_transform.worker_type == "G.1X",
      var.ml_transform.worker_type == "G.2X"
    ])
    error_message = "Valid values for worker_type are Standard, G.1X, G.2X."
  }

  validation {
    condition     = var.ml_transform.worker_type == "G.1X" || var.ml_transform.worker_type == "G.2X" || var.ml_transform.worker_type == "Standard" ? var.ml_transform.number_of_workers != null && var.ml_transform.max_capacity == null : var.ml_transform.number_of_workers == null
    error_message = "Error! If worker_type is G.1X, G.2X or Standard then number_of_workers should be mentioned and max_capacity should be null."
  }

  validation {
    condition     = (var.ml_transform.max_capacity == null ? true : (var.ml_transform.max_capacity >= 2 && var.ml_transform.max_capacity <= 100))
    error_message = "Max capacity can be given values between 2 and 100!"
  }
}

# Variable for tags

variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  tags    = var.tags
  version = "0.1.0"
}