variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

#variables for Tags
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

##### Network Configuration #####

variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

variable "subnet_id2_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 2"
}

variable "subnet_id3_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 3"
}

##### variables for the EMR #####

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the EMR Serverless application"
  type        = string
}

variable "release_label_prefix" {
  description = "Release label prefix used to lookup a release label"
  type        = string
}

variable "type" {
  description = "The type of application, e.g., SPARK or HIVE."
  type        = string
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
}

variable "interactive_configuration" {
  description = "Configuration for interactive workloads in EMR Serverless, including Livy and Studio endpoints."
  type = object({
    livy_endpoint_enabled = optional(bool)
    studio_enabled        = optional(bool)
  })
  default = {}
}

variable "maximum_capacity" {
  description = "Map of maximum capacity configurations for EMR Serverless applications"
  type = object({
    cpu    = string
    memory = string
    disk   = optional(number)
  })
}

variable "monitoring_configuration" {
  description = "The monitoring configuration for the application"
  type = object({
    cloudwatch_logging_configuration = optional(object({
      enabled                = optional(bool)
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
    prometheus_monitoring_configuration = optional(object({
      remote_write_url = optional(string)
    }))
    s3_monitoring_configuration = optional(object({
      log_uri            = optional(string)
      encryption_key_arn = optional(string)
    }))
  })
  default = null
}
