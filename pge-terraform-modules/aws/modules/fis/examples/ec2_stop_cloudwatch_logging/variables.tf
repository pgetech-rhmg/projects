# Variables for tags

variable "LogGroupNamePrefix" {
  description = "Prefix for CloudWatch Log Group names created for FIS experiment logging."
  type        = string
}

variable "name" {
  description = "Name of the FIS experiment template for this CloudWatch logging example."
  type        = string
}

variable "aws_service" {
  description = "List of AWS services that the IAM role will assume trust for. Default includes fis.amazonaws.com for FIS experiments."
  type        = list(string)
  default     = null
}

variable "AppID" {
  description = "Application ID from AMPS system. Format: APP-#### (e.g., APP-1234). Required for PGE compliance."
  type        = number
}

variable "Environment" {
  type        = string
  description = "Environment where this FIS experiment will run. Valid values: Dev, Test, QA, Prod. Required for PGE compliance."
}

variable "DataClassification" {
  type        = string
  description = "Data classification level for PGE compliance. Valid values: Public, Internal, Confidential, Restricted, Privileged. Required for PGE compliance."
}

variable "Compliance" {
  type        = list(string)
  description = "List of compliance requirements that apply to this FIS experiment (e.g., SOX, HIPAA). Required for PGE compliance, but can be empty list if no specific compliance applies."
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score for PGE compliance. Valid values: High, Medium, Low. Required for PGE compliance."
}

variable "Notify" {
  type        = list(string)
  description = "List of email addresses or groups to notify for system failures or maintenance related to this FIS experiment. Required for PGE compliance."
}

variable "Owner" {
  type        = list(string)
  description = "List of three system owners as defined by AMPS: Director, Client Owner, and IT Lead. Format: LANID1_LANID2_LANID3. Required for PGE compliance."
}
variable "Order" {
  description = "Order number for tracking and billing purposes. Required for PGE compliance as a resource tag."
  type        = number
}

variable "aws_role" {
  description = "Name of the AWS IAM role to assume for FIS experiment execution in this CloudWatch logging example."
  type        = string
}

# Variables for FIS experiment

variable "policy_name" {
  description = "Name of the IAM managed policy that will be created for the FIS role."
  type        = string
}

variable "fis_role_name" {
  description = "Name of the existing IAM role to use for FIS experiments. If empty, a new role will be created."
  type        = string
  default     = ""
}

variable "inline_policy" {
  description = "List of inline IAM policies in JSON format to attach to the FIS role. When specified, these policies are used instead of the default FIS policy from the root module."
  type        = list(string)
  default     = []
}

variable "policy_description" {
  description = "Description of the IAM managed policy that will be created for the FIS role in this CloudWatch logging example."
  type        = string
}

variable "policy_content" {
  description = "Content of the IAM policy in JSON format. If empty, the default FIS policy template will be used with CloudWatch logging permissions."
  type        = string
  default     = ""
}

variable "optional_tags" {
  description = "Optional tags to merge with the required PGE compliance tags for this CloudWatch logging example."
  type        = map(string)
  default     = {}
}

# Variable for actions in the FIS experiment template
variable "fis_experiment_name" {
  description = "Name for the Fault Injection experiment, used for easier identification withing FIS."
  type        = string
}

variable "description" {
  description = "Description of the FIS experiment template demonstrating EC2 stop action with CloudWatch logging."
  type        = string
}

variable "stop_condition" {
  description = "List of stop conditions for the FIS experiment template in this CloudWatch logging example."
  type = list(object({
    source = string
    value  = string
  }))
}

variable "action" {
  description = "List of actions for the FIS experiment template demonstrating EC2 stop with CloudWatch logging."
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
  description = "Options for the FIS experiment template in this CloudWatch logging example, including account targeting and empty target resolution."
  type = object({
    account_targeting            = string
    empty_target_resolution_mode = string
  })
}

# variables for logs

variable "log_type" {
  description = "Type of logging to use for FIS experiment results. Valid values: s3, cloudwatch. This example demonstrates cloudwatch logging."
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Base name for the S3 bucket for FIS logging. Required when log_type is set to 's3', not used in this CloudWatch example."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for FIS experiment logs. Required when log_type is set to 'cloudwatch'."
  type        = string
}

variable "log_schema_version" {
  description = "Version of the log schema for FIS experiment logs. Supported values: 1 or 2."
  type        = number
  default     = 1
}

# Variable for S3 logging configuration
variable "s3_logging" {
  description = "Configuration object for S3 logging (not used in this CloudWatch logging example but required for module compatibility)."
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