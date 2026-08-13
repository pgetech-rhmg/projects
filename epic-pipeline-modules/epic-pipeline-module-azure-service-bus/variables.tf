variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "namespace_name" {
  type        = string
  description = "Name of the Service Bus namespace (globally unique)"
}

variable "sku" {
  type        = string
  description = "Service Bus namespace SKU. Basic supports queues only; Standard/Premium add topics."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium"
  }
}

variable "capacity" {
  type        = number
  description = "Messaging units. Only used for Premium (1/2/4/8/16); must be 0 for Basic/Standard."
  default     = 0
}

variable "queues" {
  type = list(object({
    name                                 = string
    max_delivery_count                   = optional(number, 10)
    lock_duration                        = optional(string, "PT1M")
    default_message_ttl                  = optional(string, "P14D")
    dead_lettering_on_message_expiration = optional(bool, false)
    requires_session                     = optional(bool, false)
    max_size_in_megabytes                = optional(number, 1024)
  }))
  description = "Queues to create in the namespace. Durations are ISO-8601 (e.g. PT1M = 60s, P1D = 1 day). requires_session is not supported on the Basic SKU."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
