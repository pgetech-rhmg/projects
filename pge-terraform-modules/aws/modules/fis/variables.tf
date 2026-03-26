# IAM role variables for FIS
# Variable for the name of the IAM role
variable "fis_experiment_name" {
  description = "Name for the Fault Injection experiment, used for easier identification withing FIS."
  type        = string
}

variable "fis_role_name" {
  description = "Name of an existing IAM role to use for FIS experiments. If empty, a new role will be generated with the following format 'fis-role-<fis_experiment_name>'."
  type        = string
  default     = ""
}

# Variable for AWS service(s) that the IAM role will assume
variable "aws_service" {
  description = "List of AWS services that the IAM role will assume. Defaults to ['fis.amazonaws.com'] if not specified."
  type        = list(string)
  default     = null
}

# Variable for inline policies to attach to the IAM role
variable "inline_policy" {
  description = "List of inline policy documents in JSON format to attach to the IAM role. These will be appended to the default FIS policy."
  type        = list(string)
  default     = []
}

# S3 variables for FIS
# Variable for the name of the S3 bucket
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to use for FIS experiment logs. Required when log_type is set to 's3'."
  type        = string
  default     = ""
}

# Variable to control whether to validate S3 bucket existence
variable "validate_s3_bucket" {
  description = "Whether to validate that the S3 bucket exists. Set to false when the bucket is created in the same deployment."
  type        = bool
  default     = false
}

# Variable to determine the type of logging (S3 or CloudWatch)
variable "log_type" {
  description = "Type of logging to use for FIS experiments. Valid values: 's3' or 'cloudwatch'."
  type        = string
  default     = "s3"
}

# CloudWatch variables for FIS
# Variable for the name of the CloudWatch Log Group
variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group to use for FIS experiment logs. Required when log_type is set to 'cloudwatch'."
  type        = string
  default     = ""
}

# Variable for the ARN of the CloudWatch Log Group (alternative to name)
variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group to use for FIS experiment logs. If provided, takes precedence over cloudwatch_log_group_name."
  type        = string
  default     = ""
}

# Variable for S3 logging configuration
variable "s3_logging" {
  description = "Configuration object for S3 logging, including the prefix for log file organization."
  type = object({
    prefix = string
  })
  default = {
    prefix = ""
  }
}

# Variable for the FIS experiment template description
variable "description" {
  description = "Description of the FIS experiment template that explains the purpose of the experiment."
  type        = string
  default     = ""
}

# Variable for stop conditions in the FIS experiment template
variable "stop_condition" {
  description = "List of stop conditions that will halt the FIS experiment if triggered. Each condition has a source and value."
  type = list(object({
    source = string
    value  = string
  }))
  default = []
}

# Variable for actions in the FIS experiment template
variable "action" {
  description = "List of fault injection actions to perform during the FIS experiment. Each action defines what fault to inject and on which targets."
  type = list(object({
    name        = string
    action_id   = string
    description = string
    start_after = optional(list(string), [])
    parameter   = optional(map(string), {})
    target = list(object({
      key   = string
      value = string
    }))
  }))
}


# Variable for targets in the FIS experiment template
variable "target" {
  description = "List of target resources for the FIS experiment. Defines which AWS resources will be affected by the experiment actions."
  type = list(object({
    name           = string
    resource_type  = string
    selection_mode = string

    # Optional filter block
    filter = optional(list(object({
      path   = string
      values = list(string)
    })), [])

    # Optional resource ARNs
    resource_arns = optional(list(string), [])

    # Optional parameters
    parameters = optional(map(string), null)

    # Optional resource tags
    resource_tags = optional(list(object({
      key   = string
      value = string
    })), [])
  }))
}

# Variable for the log schema version
variable "log_schema_version" {
  description = "Version of the log schema for FIS experiment logs. Supported values: 1 or 2."
  type        = number
  default     = 1
}

variable "experiment_options" {
  description = "Configuration options for the FIS experiment, including account targeting and target resolution behavior."
  type = object({
    account_targeting            = string
    empty_target_resolution_mode = string
  })
}

# Experiment report configuration
variable "experiment_report_configuration" {
  description = "Configuration for generating experiment reports after completion. Includes data sources and output destinations. Set to null to disable reports."
  type = object({
    data_sources = optional(object({
      cloudwatch_dashboard = optional(list(object({
        dashboard_arn = string
      })), [])
    }), {})
    outputs = optional(object({
      s3_configuration = optional(object({
        bucket_name = string
        prefix      = optional(string, "")
      }))
    }))
    post_experiment_duration = optional(string, "PT5M")
    pre_experiment_duration  = optional(string, "PT5M")
  })
  default = null
}

# Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
