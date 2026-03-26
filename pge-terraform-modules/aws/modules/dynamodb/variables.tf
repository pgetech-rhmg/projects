# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for dynamodb table

variable "table_name" {
  description = "Dynamodb table name (space is not allowed)."
  type        = string
  validation {
    condition = alltrue([
      can(regex("([a-zA-Z0-9-_.]+)", var.table_name)),
      length(var.table_name) >= 3 && length(var.table_name) <= 255
    ])
    error_message = "Table names and index names must be between 3 and 255 characters long, and can contain only the following characters:a-z,A-Z,0-9,_(underscore),-(dash),.(dot)."
  }
}

variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity.To create global-table-replica set the 'table_billing_mode' to 'PAY_PER_REQUEST'."
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition = anytrue([
      var.table_billing_mode == "PROVISIONED",
    var.table_billing_mode == "PAY_PER_REQUEST"])
    error_message = "Error! values for table billing mode should be PROVISIONED and PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
}

variable "hash_range_key_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute"
  type        = string
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = 0
}

variable "read_capacity" {
  description = "The number of read units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = 0
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE and NEW_AND_OLD_IMAGES when the stream is enabled and value must be null when stream is disabled."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.stream_view_type == null,
      var.stream_view_type == "KEYS_ONLY",
      var.stream_view_type == "NEW_IMAGE",
      var.stream_view_type == "OLD_IMAGE",
    var.stream_view_type == "NEW_AND_OLD_IMAGES"])
    error_message = "Error! values for stream view type should be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE and NEW_AND_OLD_IMAGES when the stream is enabled and value must be null when stream is disabled."
  }
}

variable "ttl_enabled" {
  description = "Indicates whether ttl is enabled"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = null
}

variable "local_secondary_indexes" {
  description = "Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
  type        = any
  default     = []
}

variable "global_secondary_indexes" {
  description = "Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type        = any
  default     = []
}

variable "table_class" {
  description = "The storage class of the table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS."
  type        = string
  default     = "STANDARD"
  validation {
    condition = anytrue([
      var.table_class == "STANDARD",
      var.table_class == "STANDARD_INFREQUENT_ACCESS"
    ])
    error_message = "Error! values for table class should be STANDARD and STANDARD_INFREQUENT_ACCESS."
  }
}

variable "server_side_encryption_kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption. This attribute should only be specified if the key is different from the default DynamoDB CMK, alias/aws/dynamodb."
  default     = null
  type        = string
}

variable "timeouts_create" {
  description = "Used when creating the table."
  type        = string
  default     = "10m"
}

variable "timeouts_update" {
  description = "Used when updating the table configuration and reset for each individual Global Secondary Index and Replica update."
  type        = string
  default     = "60m"
}

variable "timeouts_delete" {
  description = "Used when deleting the table"
  type        = string
  default     = "10m"
}

variable "restore_source_name" {
  description = "The name of the table to restore. Must match the name of an existing table."
  type        = string
  default     = null
}

variable "restore_to_latest_time" {
  description = "If set, restores table to the most recent point-in-time recovery point."
  type        = bool
  default     = false
}

variable "restore_date_time" {
  description = "The time of the point-in-time recovery point to resolve."
  type        = number
  default     = null
}

variable "replica_kms_key_arn_us_east_1" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption for the replica."
  type        = string
  default     = null

}

variable "create_replica" {
  description = "Whether to create a replica or not"
  type        = bool
  default     = false
}