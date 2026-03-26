#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for event_subscription
variable "event_enabled" {
  type        = bool
  description = "Whether the event subscription should be enabled."
  default     = null
}

variable "event_categories" {
  type        = list(string)
  description = "List of event categories to listen for, see DescribeEventCategories for a canonical list."
  default     = null
}

variable "event_name" {
  type        = string
  description = "Name of event subscription."
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic arn to send events on."
}

variable "source_ids" {
  type        = list(string)
  description = "Ids of sources to listen to."
}

variable "source_type" {
  type        = string
  description = "Type of source for events. Valid values: replication-instance or replication-task"
  default     = null
  validation {
    condition     = contains(["replication-instance", "replication-task"], var.source_type)
    error_message = "Valid values for source_type are (replication-instance or replication-task)."
  }
}

variable "timeouts_create" {
  description = " Used for Creating Instances"
  type        = string
  default     = "40m"
}

variable "timeouts_delete" {
  description = "Used for destroying databases"
  type        = string
  default     = "80m"
}

variable "timeouts_update" {
  description = "Used for Database modifications"
  type        = string
  default     = "80m"
}