variable "name" {
  description = "Name of the canary which is going to be sent as part of the notification when the canary fails and the alarm triggers."
  type        = string
}

variable "runtime_version" {
  description = "Runtime version of the canary. Details: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Library_nodejs_puppeteer.html"
  type        = string

}

variable "take_screenshot" {
  description = "If screenshot should be taken"
  type        = bool
  default     = false
}

variable "api_hostname" {
  description = "The host name of the API, ex: mydomain.internal."
  type        = string
}

variable "api_path" {
  description = "The path for the API call , ex: /path?param=value."
  type        = string
}


variable "frequency" {
  description = "The frequency in minutes at which the canary should be run. The minimum is two minutes."
  type        = string
}

variable "alert_sns_topic" {
  description = "The SNS topic to which the cloud watch alarm notification is sent."
  type        = string
}



variable "alarm_description" {
  description = "The description for the alarm."
  type        = string
  default     = null
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
  type        = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
}

variable "threshold" {
  description = "The value against which the specified statistic is compared."
  type        = number
}

variable "metric_name" {
  description = "The name for the alarm's associated metric. See docs for supported metrics."
  type        = string
  default     = null
}

variable "namespace" {
  description = "The namespace for the alarm's associated metric. See docs for the list of namespaces. See docs for supported metrics."
  type        = string
  default     = null
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  type        = string
  default     = null
}
variable "statistic" {
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
  type        = string
  default     = null
}
variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  type        = number
  default     = null
}

/*********************************Security Group*******************************************************/


variable "cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
}

variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
}

variable "security_group_ingress_rules" {
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
  description = "Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule."
}

variable "security_group_egress_rules" {
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
  description = "Configuration block for for nested security groups egress rules. Can be specified multiple times for each egress rule."
}

variable "bucket_name" {
  type        = string
  description = "s3 bucket name"
}

variable "versioning" {
  type        = string
  default     = "Disabled"
  description = "Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned."
}


variable "description" {
  description = "The description of the policy"
  type        = string
  default     = ""
}


variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  default     = []
}

variable "policy_name" {
  description = "The name of the policy"
  type        = string
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "optional_tags" {
  description = "Optional_tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}