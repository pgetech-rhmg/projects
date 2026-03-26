variable "name" {
  description = "A name to identify the stream. This is unique to the AWS account and region the Stream is created in."
  type        = string
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream. The maximum value of a stream's retention period is 8760 hours. Minimum value is 24. Default is 24."
  type        = number
  default     = 24
  validation {
    condition     = var.retention_period >= 24 && var.retention_period <= 8760
    error_message = "Error! retention period min value is 24 and max value is 8760 hrs!"
  }
}

variable "shard_level_metrics" {
  description = " A list of shard-level CloudWatch metrics which can be enabled for the stream. See Monitoring with CloudWatch for more. Note that the value ALL should not be used; instead you should provide an explicit list of metrics you wish to enable."
  type        = list(string)
  default     = ["WriteProvisionedThroughputExceeded", "ReadProvisionedThroughputExceeded", "IteratorAgeMilliseconds"]

  validation {
    condition     = alltrue([for val in var.shard_level_metrics : contains(["WriteProvisionedThroughputExceeded", "ReadProvisionedThroughputExceeded", "IteratorAgeMilliseconds", "IncomingBytes", "IncomingRecords", "OutgoingBytes", "OutgoingRecords", "GetRecords.IteratorAgeMilliseconds", "PutRecord.Success", "PutRecords.Success", "GetRecords.Success"], val)])
    error_message = "Error! provide shard-level metrics as value!"
  }

  validation {
    condition = alltrue([
      anytrue([for ki in var.shard_level_metrics : contains(["WriteProvisionedThroughputExceeded"], ki)]),
      anytrue([for vi in var.shard_level_metrics : contains(["ReadProvisionedThroughputExceeded"], vi)]),
      anytrue([for zi in var.shard_level_metrics : contains(["IteratorAgeMilliseconds"], zi)])
    ])
    error_message = "Error! shard-level metrics must have values are 'WriteProvisionedThroughputExceeded','ReadProvisionedThroughputExceeded', 'IteratorAgeMilliseconds'!"
  }

}

variable "enforce_consumer_deletion" {
  description = "A boolean that indicates all registered consumers should be deregistered from the stream so that the stream can be destroyed without error. The default value is false."
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "The encryption type to use. The only acceptable values are NONE or KMS. Default value is NONE"
  type        = string
  default     = "NONE"
}

variable "kms_key_id" {
  description = "The GUID for the customer-managed KMS key to use for encryption. You can also use a Kinesis-owned master key by specifying the alias alias/aws/kinesis."
  type        = string
  default     = null
}

variable "stream_mode" {
  description = <<-DOC
    shard_count:
        (Optional) The number of shards that the stream will use. If the stream_mode is PROVISIONED, this field is required. Amazon has guidelines for specifying the Stream size that should be referenced when creating a Kinesis stream. See Amazon Kinesis Streams for more.
    stream_mode_details:
        (Optional) Specifies the capacity mode of the stream. Must be either PROVISIONED or ON_DEMAND.
  DOC

  type = object({
    shard_count         = number
    stream_mode_details = string
  })

  default = {
    shard_count         = null
    stream_mode_details = "PROVISIONED"
  }

  validation {
    condition     = contains([var.stream_mode.stream_mode_details], "PROVISIONED") ? var.stream_mode.shard_count != null : true
    error_message = "Error! If the stream_mode is PROVISIONED, shard_count field is required!"
  }

  validation {
    condition     = contains([var.stream_mode.stream_mode_details], "ON_DEMAND") ? var.stream_mode.shard_count == null : true
    error_message = "Error! If the stream_mode is ON_DEMAND, shard_count field has to be null!"
  }

}

variable "timeouts" {
  description = "The timeouts should be in the format 120m for 120 minutes, 10s for ten seconds, or 2h for two hours."
  type        = map(string)
  default     = {}
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}