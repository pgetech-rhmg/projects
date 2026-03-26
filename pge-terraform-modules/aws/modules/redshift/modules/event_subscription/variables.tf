#Variables for Event Subscription
variable "event_subscription_name" {
  description = "The name of the Redshift event subscription."
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to send events to."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:sns:\\w+(?:-\\w+)+:[[:digit:]]{12}:([a-zA-Z0-9])+(.*)$", var.sns_topic_arn))
    error_message = "The sns topic arn is required and the allowed format of 'sns topic arn' is arn:aws:sns:<region>:<account-id>:<sns-topic-name>."
  }
}

variable "redshift_source" {
  description = <<-DOC
    source_ids:
       A list of identifiers of the event sources for which events will be returned. If not specified, then all sources are included in the response. If specified, a source_type must also be specified.
    source_type:
      The type of source that will be generating the events. Valid options are cluster,cluster-parameter-group,cluster-security-group,cluster-snapshot,scheduled-action. If not set, all sources will be subscribed to.
  DOC
  type = object({
    source_ids  = list(string)
    source_type = string
  })
  default = {
    source_ids  = null
    source_type = null
  }
  validation {
    condition = anytrue([
      var.redshift_source.source_type == null,
      var.redshift_source.source_type == "cluster",
      var.redshift_source.source_type == "cluster-parameter-group",
      var.redshift_source.source_type == "cluster-security-group",
      var.redshift_source.source_type == "cluster-snapshot",
    var.redshift_source.source_type == "scheduled-action"])
    error_message = "Error! values for source_type should be cluster,cluster-parameter-group,cluster-security-group,cluster-snapshot,scheduled-action."
  }
  validation {
    condition     = var.redshift_source.source_ids != null ? var.redshift_source.source_type != null : var.redshift_source.source_type == null
    error_message = "If 'source_ids' is specified, a 'source_type' must also be specified."
  }
}

variable "severity" {
  description = "The event severity to be published by the notification subscription."
  type        = string
  default     = "INFO"
  validation {
    condition = anytrue([
      var.severity == "INFO",
    var.severity == "ERROR"])
    error_message = "Error! values for severity are INFO & ERROR."
  }
}

variable "event_categories" {
  description = "A list of event categories for a SourceType that you want to subscribe to."
  type        = list(string)
  default     = null
  validation {
    condition = alltrue([
      for i in var.event_categories : contains(["configuration", "management", "monitoring", "security", "pending"], i)
    ])
    error_message = "Error! values for event categories should be configuration,management,monitoring,security,pending."
  }
}

variable "enabled" {
  description = "A boolean flag to enable/disable the subscription.Defaults to true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}  