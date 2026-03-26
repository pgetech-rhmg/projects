variable "name" {
    description = "The name of the EMR Serverless application"
    type        = string
}

variable "release_label" {
  description = "The EMR release label, e.g., emr-6.6.0"
  type        = string
  default     = null

  validation {
    condition = (
      var.release_label == null || 
      can(regex("^emr-[0-9]+\\.[0-9]+\\.[0-9]+$", var.release_label))
    )
    error_message = "release_label must be null or follow the format 'emr-x.y.z', e.g., emr-6.6.0"
  }
}

variable "release_label_prefix" {
  description = "Release label prefix used to lookup a release label"
  type        = string
  default     = "emr-6"

  validation {
    condition     = can(regex("^emr-[0-9]+$", var.release_label_prefix))
    error_message = "The release_label_prefix must start with 'emr-' followed by a number, e.g., 'emr-6'."
  }
}

variable "type" {
  description = "The type of application, e.g., SPARK or HIVE."
  type        = string
  default = "SPARK"

  validation {
    condition     = contains(["SPARK", "HIVE"], upper(var.type))
    error_message = "The type must be either 'SPARK' or 'HIVE'."
  }
}

variable "region" {
  description = "Region where this resource will be managed. Defaults to the region set in the provider configuration."
  type        = string
  default     = null

  validation {
    condition     = var.region == null || can(regex("^(us|eu|ap|sa|ca|me|af)-[a-z]+-\\d$", var.region))
    error_message = "Region must be null or a valid AWS region like us-west-2, eu-central-1, ap-southeast-1, etc."
  }
}

variable "architecture" {
  description = "The CPU architecture type, e.g., X86_64 or ARM64."
  type        = string
  default = "X86_64"
  
  validation {
    condition     = var.architecture == "X86_64" || var.architecture == "ARM64"
    error_message = "Architecture must be either 'X86_64' or 'ARM64'."
  }
}

variable "auto_start_configuration" {
  description = "Configuration for auto-starting the application"
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "auto_stop_configuration" {
  description = "Configuration for auto-stopping the application"
  type = object({
    enabled = optional(bool)
    idle_timeout_minutes = optional(number)
  })
  default = null
}

variable "image_configuration" {
    description = "custom image configuration block."
    type        = object({
      image_uri = optional(string)
    })
    default = null
}

variable "initial_capacity" {
  description = "Initial capacity configuration for EMR Serverless"
  type = map(object({
    initial_capacity_type = string
    initial_capacity_config = optional(object({
      worker_count = number
      worker_configuration = optional(object({
        cpu    = string
        memory = string
        disk   = optional(string)
      }))
    }))
  }))
  default = null
}

variable "interactive_configuration" {
  description = "Configuration for interactive workloads in EMR Serverless, including Livy and Studio endpoints."
  type = object({
    livy_endpoint_enabled = optional(bool)
    studio_enabled        = optional(bool)
  })
  default = null
}

variable "maximum_capacity" {
  description = "Map of maximum capacity configurations for EMR Serverless applications"
  type = object({
    cpu    = string
    memory = string
    disk   = optional(number)
  })
  default = null
}

variable "monitoring_configuration" {
  description = "The monitoring configuration for the application"
  type = object({
    cloudwatch_logging_configuration = optional(object({
      enabled                = bool
      log_group_name         = optional(string)
      log_stream_name_prefix = optional(string)
      encryption_key_arn     = optional(string)
      log_types = optional(list(object({
        name   = string
        values = list(string)
      })))
    }))
    managed_persistence_monitoring_configuration = optional(object({
      enabled            = optional(bool)
      encryption_key_arn = optional(string)
    }))
    prometheus_monitoring_configuration = optional(object({ #Only supported in EMR 7.1.0 and later versions.
      remote_write_url = optional(string)
    }))
    s3_monitoring_configuration = optional(object({
      log_uri            = optional(string)
      encryption_key_arn = optional(string)
    }))
  })
  default = null
}


variable "network_configuration" {
    description = "network configuration for EMR serverless."
    type        = object({
      subnet_ids = optional(list(string))
      security_group_ids = optional(list(string))
    })
    default = null
}

variable "scheduler_configuration" {
  description = "Scheduler configuration for batch and streaming jobs running on this application. Supported with release labels emr-7.0.0 and above."
  type = object({
    max_concurrent_runs   = optional(number)
    queue_timeout_minutes = optional(number)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}
