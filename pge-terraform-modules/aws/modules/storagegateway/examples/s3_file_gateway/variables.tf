variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "kms_role" {
  description = "AWS kms role to assume"
  type        = string
}

#variables for Tags
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
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
# varaibles cloudwatch logs
variable "logs_name" {
  description = "To identify the log group name"
  type        = string
}

# variables for s3 file system
variable "name" {
  description = "Name of the gateway."
  type        = string
}

variable "gateway_timezone" {
  description = "Time zone for the gateway. The time zone is of the format 'GMT', 'GMT-hr:mm', or 'GMT+hr:mm'. For example, GMT-4:00 indicates the time is 4 hours behind GMT. The time zone is used, for example, for scheduling snapshots and your gateway's maintenance schedule."
  type        = string
}

variable "gateway_type" {
  description = "Type of the gateway. The default value is STORED."
  type        = string
}

variable "gateway_vpc_endpoint" {
  description = "VPC endpoint address to be used when activating your gateway. This should be used when your instance is in a private subnet. Requires HTTP access from client computer running terraform."
  type        = string
}

variable "day_of_month" {
  description = "The day of the month component of the maintenance start time represented as an ordinal number from 1 to 28, where 1 represents the first day of the month and 28 represents the last day of the month."
  type        = number
}

variable "day_of_week" {
  description = "The day of the week component of the maintenance start time week represented as an ordinal number from 0 to 6, where 0 represents Sunday and 6 Saturday."
  type        = number
}

variable "hour_of_day" {
  description = "The hour component of the maintenance start time represented as hh, where hh is the hour (00 to 23). The hour of the day is in the time zone of the gateway."
  type        = number
}

variable "minute_of_hour" {
  description = "The minute component of the maintenance start time represented as mm, where mm is the minute (00 to 59). The minute of the hour is in the time zone of the gateway."
  type        = number
}

# variables for cache
variable "disk_node" {
  description = "Device node of the local disk to retrieve."
  type        = string
}

# variables for secrets manager
variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
}

variable "ssm_parameter_activation_key" {
  description = "enter the value of activation key stored in ssm parameter"
  type        = string
}

# variables for nfs_file_share
variable "client_list" {
  description = "The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Set to ['0.0.0.0/0'] to not limit access. Minimum 1 item. Maximum 100 items."
  type        = list(any)
}

variable "cache_stale_timeout_in_seconds" {
  description = "Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 300 to 2,592,000 seconds (5 minutes to 30 days)."
  type        = number
}

variable "directory_mode" {
  description = "The Unix directory mode in the string form nnnn."
  type        = string
}

variable "file_mode" {
  description = "The Unix file mode in the string form nnnn."
  type        = string
}

variable "group_id" {
  description = "The default group ID for the file share (unless the files have another group ID specified)."
  type        = number
}

variable "owner_id" {
  description = "he default owner ID for the file share (unless the files have another owner ID specified)."
  type        = number
}

variable "aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "timeouts" {
  description = <<-DOC
  {
    create : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    update : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    delete : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 15m"
  }
  DOC
  type = object({
    create = string
    update = string
    delete = string
  })
}