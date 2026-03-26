
##### aws_ssm_maintenance_window_task ####

variable "maintenance_window_task_name" {
  type        = string
  description = "The name of the maintenance window task"
  default     = "pge-maintenance-window-task"
}

variable "maintenance_window_task_description" {
  type        = string
  description = "The description of the maintenance window task"
  default     = "This is a PGE maintenance window task"
}

variable "maintenance_window_id" {
  description = "The Id of the maintenance window to register the task with"
  type        = string
}

variable "maintenance_window_task_type" {
  description = "The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN_COMMAND or STEP_FUNCTIONS"
  type        = string
  default     = "RUN_COMMAND"
  validation {
    condition = anytrue([
      var.maintenance_window_task_type == "AUTOMATION",
      var.maintenance_window_task_type == "LAMBDA",
      var.maintenance_window_task_type == "STEP_FUNCTIONS",
    var.maintenance_window_task_type == "RUN_COMMAND"])
    error_message = "Valid values for task_type are AUTOMATION, RUN_COMMAND, STEP_FUNCTIONS and LAMBDA."
  }
}

variable "maintenance_window_task_arn" {
  description = "The ARN of the task to execute"
  type        = string
  default     = "AWS-RunPatchBaseline"
}

variable "maintenance_window_task_priority" {
  description = "The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1"
  type        = number
  default     = 1
}

variable "maintenance_window_task_service_role_arn" {
  description = "The role that should be assumed when executing the task. If a role is not provided, Systems Manager uses your account's service-linked role. If no service-linked role for Systems Manager exists in your account, it is created for you"
  type        = string
  default     = null
}

variable "maintenance_window_task_max_concurrency" {
  description = "The maximum number of targets this task can be run for in parallel"
  type        = number
  default     = null
}

variable "maintenance_window_task_max_errors" {
  description = "The maximum number of errors allowed before this task stops being scheduled"
  type        = number
  default     = null
}

variable "maintenance_window_task_cutoff_behavior" {
  description = "The role that should be assumed when executing the task. If a role is not provided, Systems Manager uses your account's service-linked role. If no service-linked role for Systems Manager exists in your account, it is created for you"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.maintenance_window_task_cutoff_behavior == null,
      var.maintenance_window_task_cutoff_behavior == "CONTINUE_TASK",
    var.maintenance_window_task_cutoff_behavior == "CANCEL_TASK"])
    error_message = "Valid values for maintenance_window_task_cutoff_behavior are CONTINUE_TASK and CANCEL_TASK."
  }
}

variable "maintenance_windows_targets" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    values : list(string)
    }
    )
  )
  default = []
}

variable "maintenance_windows_run_command" {
  description = "The parameters for a RUN_COMMAND task type."
  type        = list(any)
  default     = []
}