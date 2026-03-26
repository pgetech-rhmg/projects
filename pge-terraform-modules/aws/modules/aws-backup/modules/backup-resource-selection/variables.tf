
#### IAM role ####

variable "iam_role_arn" {
  description = "The ARN of the IAM role that AWS Backup uses to authenticate when restoring and backing up the target resource."
  type        = string
  validation {
    condition     = (length(var.iam_role_arn) > 0)
    error_message = "IAM role ARN can't be empty."
  }
}

#### Backup resource selection variables ####

variable "backup_selection_name" {
  description = "The display name of a resource selection document."
  type        = string
  validation {
    condition     = (length(var.backup_selection_name) > 0)
    error_message = "Resource selection name can't be empty."
  }
}

variable "plan_id" {
  description = "The backup plan ID to be associated with the selection of resources."
  type        = string
  validation {
    condition     = (length(var.plan_id) > 0)
    error_message = "The backup plan ID can't be empty."
  }
}

variable "backup_resources" {
  description = "An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan."
  type        = list(string)
  default     = []
}

variable "not_resources" {
  description = "An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to exclude from a backup plan."
  type        = list(string)
  default     = []
}

variable "selection_tags" {
  description = "An array of tag condition objects used to filter resources based on tags for assigning to a backup plan"
  type        = any
  default     = []
}

variable "string_equals" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    value : string
    }
    )
  )
  default = []
}

variable "string_not_equals" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    value : string
    }
    )
  )
  default = []
}

variable "string_like" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    value : string
    }
    )
  )
  default = []
}

variable "string_not_like" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    value : string
    }
    )
  )
  default = []
}