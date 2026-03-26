
variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_role" {
  type = string
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "kms_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for log group"
  type        = string
  default     = null
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "LogGroupNamePrefix" {
  type        = string
  description = "To identify the log group name"
}

variable "LogMetricFilterPattern" {
  type        = string
  description = "The pattern of log metric filter "
}

variable "AlarmDescription" {
  type        = string
  description = "The description of Alarm"
}

variable "AlarmComparisonOperator" {
  type        = string
  description = "The Comparison of alarm metic operator"
}

variable "AlarmEvaluationPeriods" {
  type        = number
  description = "To evaluate the periods of alarm"
}

variable "AlarmThreshold" {
  type        = number
  description = "Value of Alarm threshold"
}

variable "AlarmPeriod" {
  type        = number
  description = " To count the period of alarm"
}

variable "AlarmUnit" {
  type        = string
  description = "Specify the unit of alarm"
}

variable "AlarmStatistic" {
  type        = string
  description = "The Statistics of alarm"
}

variable "MetricTransformationName" {
  type        = string
  description = "Name of the transformation metric"
}

variable "MetricTransformationNamespace" {
  type        = string
  description = "Namespace of the metric transformation"
}