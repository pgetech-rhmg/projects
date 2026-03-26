variable "action_groups" {
  description = "List of action groups to create"
  type = list(object({
    name                = string
    short_name          = string
    resource_group_name = string
    location            = optional(string, "global")
    enabled             = optional(bool, true)
    email_addresses     = list(string)
  }))

  validation {
    condition     = length(var.action_groups) > 0
    error_message = "At least one action group must be defined."
  }

  validation {
    condition     = alltrue([for ag in var.action_groups : length(ag.name) > 0 && length(ag.short_name) > 0])
    error_message = "Action group name and short_name cannot be empty."
  }

  validation {
    condition     = alltrue([for ag in var.action_groups : length(ag.short_name) <= 12])
    error_message = "Action group short_name must be 12 characters or less."
  }

  validation {
    condition     = alltrue([for ag in var.action_groups : length(ag.email_addresses) > 0])
    error_message = "Each action group must have at least one email address."
  }
}

variable "tags" {
  description = "Tags to be applied to all metric alert resources"
  type        = map(string)
  default = {
    AppId              = "123456"
    Env                = "Dev"
    Owner              = "abc@pge.com"
    Compliance         = "None"
    Notify             = "abc@pge.com"
    DataClassification = "internal"
    CRIS               = "1"
    order              = "123456"
  }
}