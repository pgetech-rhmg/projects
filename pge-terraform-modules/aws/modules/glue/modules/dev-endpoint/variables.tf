# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variable for Glue Dev Endpoint

variable "glue_dev_endpoint_name" {
  description = "The name of this endpoint. It must be unique in your account."
  type        = string
}

variable "glue_dev_endpoint_role_arn" {
  description = "The IAM role for this endpoint."
  type        = string
}

variable "glue_dev_endpoint_arguments" {
  description = "A map of arguments used to configure the endpoint."
  type        = map(string)
  default     = {}
}

variable "glue_dev_endpoint_extra_jars_s3_path" {
  description = "Path to one or more Java Jars in an S3 bucket that should be loaded in this endpoint."
  type        = string
  default     = null
}

variable "glue_dev_endpoint_extra_python_libs_s3_path" {
  description = "Path(s) to one or more Python libraries in an S3 bucket that should be loaded in this endpoint. Multiple values must be complete paths separated by a comma."
  type        = string
  default     = null
}


variable "glue_dev_endpoint_glue_version" {
  description = "Specifies the versions of Python and Apache Spark to use. Defaults to AWS Glue version 0.9."
  type        = string
  default     = null
}

variable "glue_dev_endpoint_public_key" {
  description = "The public key to be used by this endpoint for authentication."
  type        = string
  default     = null
}

variable "glue_dev_endpoint_public_keys" {
  description = "A list of public keys to be used by this endpoint for authentication."
  type        = list(string)
  default     = []
}

variable "glue_dev_endpoint_security_configuration" {
  description = "The name of the Security Configuration structure to be used with this endpoint."
  type        = string
}

variable "glue_dev_endpoint_security_group_ids" {
  description = "Security group IDs for the security groups to be used by this endpoint."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for i in var.glue_dev_endpoint_security_group_ids : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of security_group_ids, value should be in form of 'sg-xxxxxxxx'!"
  }
}

variable "glue_dev_endpoint_subnet_id" {
  description = "The subnet ID for the new endpoint to use."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^subnet-\\w+", var.glue_dev_endpoint_subnet_id))
    error_message = "The subnet id must be valid in form of 'subnet-xxxxxxx'."
  }
}

variable "dev_endpoint" {
  description = <<-DOC
    worker_type:
     The type of predefined worker that is allocated to this endpoint. Accepts a value of Standard, G.1X, or G.2X.
    number_of_workers:
     The number of workers of a defined worker type that are allocated to this endpoint. This field is available only when you choose worker type G.1X or G.2X.
    number_of_nodes:
     The number of AWS Glue Data Processing Units (DPUs) to allocate to this endpoint. Conflicts with worker_type.
    DOC

  type = object({
    worker_type       = string
    number_of_workers = number
    number_of_nodes   = number
  })

  default = {
    worker_type       = null
    number_of_workers = null
    number_of_nodes   = null
  }

  validation {
    condition = anytrue([
      var.dev_endpoint.worker_type == null,
      var.dev_endpoint.worker_type == "Standard",
      var.dev_endpoint.worker_type == "G.1X",
      var.dev_endpoint.worker_type == "G.2X"
    ])
    error_message = "Valid values for worker type are Standard,G.1X and G.2X."
  }

  validation {
    condition     = var.dev_endpoint.worker_type == "Standard" ? var.dev_endpoint.number_of_workers == null : var.dev_endpoint.worker_type == "G.1X" || var.dev_endpoint.worker_type == "G.2X" || var.dev_endpoint.worker_type == null
    error_message = "Error! If worker_type is Standard, then number_of_workers should be null."
  }

  validation {
    condition     = var.dev_endpoint.worker_type == "G.1X" || var.dev_endpoint.worker_type == "G.2X" ? var.dev_endpoint.number_of_workers != null && var.dev_endpoint.number_of_nodes == null : var.dev_endpoint.number_of_workers == null
    error_message = "Error! If worker_type is G.1X or G.2X, then number_of_workers should be mentioned."
  }

  validation {
    condition     = var.dev_endpoint.number_of_nodes != null ? var.dev_endpoint.worker_type == null : var.dev_endpoint.worker_type != null
    error_message = "Error! If number_of_nodes is mentioned, then worker_type should be null."
  }

  validation {
    condition     = var.dev_endpoint.worker_type == "G.1X" ? var.dev_endpoint.number_of_workers <= 299 : var.dev_endpoint.worker_type == "Standard" || var.dev_endpoint.worker_type == "G.2X" || var.dev_endpoint.worker_type == null
    error_message = "Error! If worker_type is G.1X, then number_of_workers should be less than or equals to 299 "
  }

  validation {
    condition     = var.dev_endpoint.worker_type == "G.2X" ? var.dev_endpoint.number_of_workers <= 149 : var.dev_endpoint.worker_type == "Standard" || var.dev_endpoint.worker_type == "G.1X" || var.dev_endpoint.worker_type == null
    error_message = "Error! If worker_type is G.2X, then number_of_workers should be less than or equals to 149 "
  }
}