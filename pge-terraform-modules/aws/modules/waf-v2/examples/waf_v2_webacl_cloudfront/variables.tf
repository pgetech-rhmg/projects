#Variables used for assume_role used in terraform.tf

variable "aws_region" {
  description = "AWS region for resource creation."
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
# Variables for Tags

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

# Common variable for name

variable "name" {
  description = "A common name for resources."
  type        = string
}

# Variables for resource 'aws_wafv2_ip_set'

variable "wafv2_ip_set_description" {
  description = "A friendly description of the IP set.."
  type        = string
}

variable "wafv2_ip_set_ip_address_version" {
  description = "Specify IPV4 or IPV6. Valid values are IPV4 or IPV6."
  type        = string
}

variable "wafv2_ip_set_addresses" {
  description = "Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6."
  type        = list(string)
}

# Variables for webacl

variable "webacl_description" {
  description = "A description for the WebACL. "
  type        = string
}

variable "request_default_action" {
  description = "The action to perform if none of the rules contained in the WebACL match."
  type        = string
}

variable "cloudwatch_metrics_enabled" {
  description = "A boolean indicating whether the associated resource sends metrics to CloudWatch"
  type        = bool
}

variable "metric_name" {
  description = "A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF for example All and Default_Action."
  type        = string
}

variable "sampled_requests_enabled" {
  description = "A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules."
  type        = bool
}

# Variables for Managed Rules

variable "managed_rules" {
  description = "List of Managed WAF rules."
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
}

# Variables for iam role

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the aws_accounts variable is not provided."
  type        = list(string)
}

# Variables for kms_key

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "kms_name" {
  description = "KMS key name"
  type        = string
}

variable "kms_description" {
  description = "The description of the key as viewed in AWS console."
  default     = "Paramter Store KMS master key"
  type        = string
}

# Variables for aws_wafv2_web_acl_logging_configuration

variable "logging_filter" {
  description = "A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  type        = any
}

variable "redacted_fields" {
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  type        = any
}

variable "aws_kinesis_firehose_delivery_stream_name" {
  description = "The name for the kinesis firehose delivery stream."
  type        = string
}