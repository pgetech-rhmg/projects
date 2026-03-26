variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "KMS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "encryption_type" {
  description = "The encryption type to use. The only acceptable values are NONE or KMS. The default value is NONE."
  type        = string
  default     = "NONE"
}

#Variables for tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#common variable for name
variable "name" {
  description = "A common name for resources."
  type        = string
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

}

variable "shard_level_metrics" {
  description = " A list of shard-level CloudWatch metrics which can be enabled for the stream. See Monitoring with CloudWatch for more. Note that the value ALL should not be used; instead you should provide an explicit list of metrics you wish to enable."
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}