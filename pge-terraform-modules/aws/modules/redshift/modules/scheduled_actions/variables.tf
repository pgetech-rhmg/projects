#Variables for aws_redshift_scheduled_action
variable "name" {
  description = "The scheduled action name."
  type        = string
}

variable "enable" {
  description = "Whether to enable the scheduled action."
  type        = bool
  default     = true
}

variable "schedule" {
  description = "The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *)."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^cron+", var.schedule)) || can(regex("^at+", var.schedule))
    ])
    error_message = "Error! valid values are eg: cron(0 10 ? * MON *) & at(2016-03-04T17:27:00)."
  }
}

variable "iam_role" {
  description = "The IAM role to assume to run the scheduled"
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.iam_role))
    ])
    error_message = "Role arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "cluster_identifier" {
  description = "The unique identifier for the cluster to resize."
  type        = string
}

variable "scheduled_actions" {
  description = "Map of maps containing scheduled action defintions"
  type        = any
  default     = {}
}

variable "description" {
  description = "The description of the scheduled action."
  type        = string
  default     = null
}