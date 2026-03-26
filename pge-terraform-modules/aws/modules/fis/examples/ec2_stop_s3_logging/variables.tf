variable "policy_name" {
  description = "Name of the IAM managed policy for this FIS example."
  type        = string
}

variable "fis_role_name" {
  description = "Name of an existing IAM role to use for FIS experiments. If empty, a new role will be created automatically."
  type        = string
  default     = ""
}

variable "inline_policy" {
  description = "List of inline IAM policies in JSON format to attach to the FIS role. If empty, the default FIS policy from the root module will be used."
  type        = list(string)
  default     = []
}

variable "policy_description" {
  description = "Description of the IAM managed policy for this FIS example."
  type        = string
}

variable "policy_content" {
  description = "Content of the IAM managed policy in JSON format."
  type        = string
}

variable "optional_tags" {
  description = "Optional tags to merge with the default required tags for this example."
  type        = map(string)
  default     = {}
}

variable "fis_experiment_name" {
  description = "Name for the Fault Injection experiment, used for easier identification withing FIS."
  type        = string
}

variable "description" {
  description = "Description of the FIS experiment template that explains the purpose of this S3 logging example."
  type        = string
}

variable "stop_condition" {
  description = "List of stop conditions that will halt the FIS experiment if triggered during this S3 logging example."
  type = list(object({
    source = string
    value  = string
  }))
}

# Variable for actions in the FIS experiment template
variable "action" {
  description = "List of fault injection actions to perform during this S3 logging FIS experiment example."
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

variable "experiment_options" {
  description = "Configuration options for this S3 logging FIS experiment, including account targeting and target resolution behavior."
  type = object({
    account_targeting            = string
    empty_target_resolution_mode = string
  })
}

# Variables for tags


variable "LogGroupNamePrefix" {
  description = "Prefix for CloudWatch Log Group names used in this example."
  type        = string
}

variable "name" {
  description = "Name of the FIS experiment template for this S3 logging example."
  type        = string
}

variable "aws_service" {
  description = "List of AWS services that the IAM role will assume. Defaults to ['fis.amazonaws.com'] if not specified."
  type        = list(string)
  default     = null
}

variable "AppID" {
  description = "Application ID from AMPS system in format APP-####. Identifies the application this FIS experiment belongs to."
  type        = number
}

variable "Environment" {
  type        = string
  description = "Environment in which the FIS experiment resources are provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Data classification level for this FIS experiment. One of: Public, Internal, Confidential, Restricted, Privileged."
}

variable "Compliance" {
  type        = list(string)
  description = "List of compliance requirements for this FIS experiment assets (SOX, HIPAA, etc.). Note: NERC workloads are not deployed to cloud."
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score for this FIS experiment. Valid values: High, Medium, Low."
}

variable "Notify" {
  type        = list(string)
  description = "List of contacts to notify for FIS experiment system failures or maintenance. Should be group names or email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List of three owners of this FIS experiment system: AMPS Director, Client Owner, and IT Lead in format LANID1_LANID2_LANID3."
}

variable "Order" {
  description = "Order number tag to be associated with FIS experiment AWS resources."
  type        = number
}

variable "aws_role" {
  description = "The name of the AWS IAM role to assume."
  type        = string
}


# variables for logs

variable "log_type" {
  description = "Type of logging to use (s3 or cloudwatch)."
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Base name for the S3 bucket. Required if log_type is set to 's3'."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group to use for FIS experiment logs. Required when log_type is set to 'cloudwatch'."
  type        = string
  default     = ""
}

variable "log_schema_version" {
  description = "Version of the log schema for FIS experiment logs. Supported values: 1 or 2."
  type        = number
}

# Variable for S3 logging configuration
variable "s3_logging" {
  description = "Configuration object for S3 logging in this example, including the prefix for log file organization."
  type = object({
    prefix = string
  })
  default = {
    prefix = ""
  }
}

variable "account_num" {
  description = "AWS account ID where this FIS experiment will be deployed."
  type        = string
  default     = ""
}

# Variable for the AWS region
variable "aws_region" {
  description = "AWS region where this FIS experiment will be deployed."
  type        = string
  default     = ""
}