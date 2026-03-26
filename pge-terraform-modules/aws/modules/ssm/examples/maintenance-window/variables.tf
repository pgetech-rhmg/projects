variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

####################################################
# Variables for Tags
####################################################

#Variables forTag
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

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

variable "Order" {
  type        = string
  description = "Order number for the asset."
}
###########################################################
# Variables for  Maintenance-Window
###########################################################

variable "scan_maintenance_window_name" {
  description = "The name of the maintenance window."
  type        = string
}

variable "scan_maintenance_window_duration" {
  description = "The duration of the maintenance windows in hours"
  type        = number
}

variable "scan_maintenance_window_cutoff" {
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution"
  type        = number
}

variable "scan_maintenance_window_schedule" {
  description = "The schedule of the Maintenance Window in the form of a cron or rate expression"
  type        = string
}

variable "scan_maintenance_window_target_resource_type" {
  description = "The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE_GROUP"
  type        = string
  validation {
    condition = anytrue([
      var.scan_maintenance_window_target_resource_type == "INSTANCE",
    var.scan_maintenance_window_target_resource_type == "RESOURCE_GROUP"])
    error_message = "Valid values for target resource types are INSTANCE and RESOURCE_GROUP."
  }
}

variable "scan_maintenance_windows_targets" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    values : list(string)
    }
    )
  )
}

###########################################################
# Variables for Maintenance-Window tasks - Run Command
###########################################################

variable "scan_maintenance_window_task_name" {
  type        = string
  description = "The name of the maintenance window task"
}

variable "scan_maintenance_window_task_arn" {
  description = "The ARN of the task to execute."
  type        = string
}

variable "scan_task_run_command_parameters" {
  description = "The parameters for the RUN_COMMAND task execution"
  type = list(object({
    name : string
    values : list(string)
    }
    )
  )
}

variable "scan_maintenance_window_task_type" {
  description = "The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN_COMMAND or STEP_FUNCTIONS"
  type        = string
}

variable "scan_task_target_key" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type        = string
  validation {
    condition = anytrue([
      var.scan_task_target_key == null,
      var.scan_task_target_key == "InstanceIds",
    var.scan_task_target_key == "WindowTargetIds"])
    error_message = "Valid values for target keys are InstanceIds and WindowTargetIds."
  }
}

variable "cloudwatch_output_enabled" {
  description = "Enables Systems Manager to send command output to CloudWatch Logs."
  type        = bool
}

variable "scan_maintenance_window_task_max_concurrency" {
  description = "The maximum number of targets this task can be run for in parallel"
  type        = number
}

variable "scan_maintenance_window_task_max_errors" {
  description = "The maximum number of errors allowed before this task stops being scheduled"
  type        = number
}

###########################################################
# Variables for Maintenance-Window tasks - Automation
###########################################################

variable "automation_maintenance_window_task_name" {
  type        = string
  description = "The name of the maintenance window task"
}

variable "automation_maintenance_window_task_arn" {
  description = "The ARN of the task to execute."
  type        = string
}

variable "automation_task_invocation_automation_parameters" {
  description = "The parameters for an AUTOMATION task type."
  type        = list(any)
}

variable "automation_maintenance_window_task_type" {
  description = "The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN_COMMAND or STEP_FUNCTIONS"
  type        = string
}

variable "automation_task_target_key" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type        = string
  validation {
    condition = anytrue([
      var.automation_task_target_key == null,
      var.automation_task_target_key == "InstanceIds",
    var.automation_task_target_key == "WindowTargetIds"])
    error_message = "Valid values for target keys are InstanceIds and WindowTargetIds."
  }
}

variable "automation_maintenance_window_task_priority" {
  description = "The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1"
  type        = number
}

variable "automation_maintenance_window_task_max_concurrency" {
  description = "The maximum number of targets this task can be run for in parallel"
  type        = number
}

variable "automation_maintenance_window_task_max_errors" {
  description = "The maximum number of errors allowed before this task stops being scheduled"
  type        = number
}

###########################################################
# Variables for Maintenance-Window tasks - Lambda
###########################################################

variable "lambda_maintenance_window_task_name" {
  type        = string
  description = "The name of the maintenance window task"
}

variable "lambda_maintenance_window_task_arn" {
  description = "The ARN of the task to execute."
  type        = string
}

variable "lambda_maintenance_window_task_type" {
  description = "The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN_COMMAND or STEP_FUNCTIONS"
  type        = string
}

variable "lambda_maintenance_window_task_priority" {
  description = "The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1"
  type        = number
}

###########################################################

#### S3 bucket ####

variable "bucket_name" {
  type        = string
  description = "s3 bucket name"
}

variable "output_s3_key_prefix" {
  description = "The Amazon S3 bucket subfolder"
  type        = string
}


### KMS ###

variable "kms_key" {
  type        = string
  description = "The KMS key to encrypt data in store."
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

### IAM role for SNS ###
variable "sns_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "sns_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}