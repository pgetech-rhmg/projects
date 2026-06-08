variable "table_name" {
  description = "DynamoDB table name."
  type        = string
}

variable "billing_mode" {
  description = "Billing mode (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Valid values: PAY_PER_REQUEST, PROVISIONED."
  }
}

variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
}

variable "hash_key_type" {
  description = "Partition key attribute type (S, N, or B)."
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Sort key attribute name (optional)."
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Sort key attribute type (S, N, or B)."
  type        = string
  default     = "S"
}

variable "global_secondary_indexes" {
  description = "List of GSI definitions."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "additional_attributes" {
  description = "Additional attribute definitions required by GSIs."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "ttl_attribute" {
  description = "TTL attribute name (optional)."
  type        = string
  default     = null
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
