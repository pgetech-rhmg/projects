variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variables for Tags
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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
#########################################################################################################

##### aws_cloudfront_origin_access_identity###
variable "comment_cf_oai" {
  description = "comment for origin access identity"
  type        = string
}

##### aws_cloudfront_distribution###
variable "comment_cfd" {
  description = "comment for cloudfront distribution"
  type        = string
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type        = string
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  type        = bool
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2"
  type        = string
}

variable "custom_error_response" {
  description = "Custom error response to be used for cloudfront distribution."
  type        = any
}

variable "forwarded_values" {
  description = "The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers"
  type        = any
}

variable "df_cache_behavior_allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
  type        = list(string)
}

variable "df_cache_behavior_cached_methods" {
  description = " Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
}

variable "df_cache_behavior_target_origin_id" {
  description = "The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior"
  type        = string
}

variable "df_cache_behavior_viewer_protocol_policy" {
  description = "specifies the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern."
  type        = string
}

variable "geo_restriction" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)"
  type        = any
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
}

variable "event_type" {
  description = "The specific event to trigger this function."
  type        = string
}

variable "origin_id" {
  description = "A unique identifier for the origin."
  type        = string
}

#cf_monitoring_subscription
variable "realtime_metrics_subscription_status" {
  description = "A subscription configuration for additional CloudWatch metrics"
  type        = string
}

#aws_cloudfront_realtime_log_config
variable "realtime_log_config_name" {
  description = "The unique name to identify this real-time log configuration"
  type        = string
}

variable "realtime_log_config_sampling_rate" {
  description = "The sampling rate for this real-time log configuration"
  type        = number
}

variable "realtime_log_config_fields" {
  description = "The fields that are included in each real-time log record"
  type        = list(string)
}

variable "realtime_log_config_stream_type" {
  description = "The type of data stream where real-time log data is sent"
  type        = string
}

#variables for cloudfront_function
variable "cf_function_name" {
  description = "Unique name for your CloudFront Function"
  type        = string
}

#aws_cloudfront_key_group
variable "key_group_name" {
  description = "A name to identify the key group"
  type        = string
}

#aws_cloudfront_public_key
variable "public_key_comment" {
  description = "An optional comment about the public key"
  type        = string
}

#aws_cloudfront_field_level_encryption_profile
variable "encryption_profile_name" {
  description = "The name of the Field Level Encryption Profile"
  type        = string
}

variable "encryption_profile_provider_id" {
  description = "The provider associated with the public key being used for encryption"
  type        = string
}

variable "encryption_profile_items" {
  description = "The list of field patterns in a field-level encryption content type profile specify the fields that you want to be encrypted"
  type        = list(string)
}

#aws_cloudfront_field_level_encryption_config
variable "encryption_config_content_type" {
  description = "The content type for a field-level encryption content type-profile mapping"
  type        = string
}

variable "encryption_config_format" {
  description = "The format for a field-level encryption content type-profile mapping"
  type        = string
}

variable "encryption_config_forward_when_content_type_is_unknown" {
  description = "specifies what to do when an unknown content type is provided for the profile"
  type        = bool
}

variable "encryption_config_forward_when_query_arg_profile_is_unknown" {
  description = "Flag to set if you want a request to be forwarded to the origin even if the profile specified by the field-level encryption query argument, fle-profile, is unknown"
  type        = bool
}

#aws_kinesis_firehose_delivery_stream
variable "kinesis_firehose_delivery_stream_destination" {
  description = "This is the destination to where the data is delivered."
  type        = string
}

variable "aws_kinesis_firehose_delivery_stream_name" {
  description = "Name of the aws kinesis firehose delivery stream used for waf v2 logging."
  type        = string
}

##s3 target origin
variable "s3_policy_origin" {
  description = "Policy template file in json format "
  type        = string
}

variable "log_policy" {
  description = "Policy template file in json format "
  type        = string
}

#variables for aws_iam_role for aws_cloudfront_realtime_log_config
variable "role_name" {
  description = "Name of the iam role"
  type        = string
}

variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#aws_kinesis_stream
variable "kinesis_stream_name" {
  description = "A name to identify the stream"
  type        = string
}

variable "kinesis_stream_shard_count" {
  description = "The number of shards that the stream will use"
  type        = number
}

variable "kinesis_stream_retention_period" {
  description = "Length of time data records are accessible after they are added to the stream"
  type        = number
}

variable "kinesis_stream_shard_level_metrics" {
  description = "A list of shard-level CloudWatch metrics which can be enabled for the stream"
  type        = list(string)
}

variable "kinesis_stream_mode" {
  description = "Specifies the capacity mode of the stream. "
  type        = string
}

#origin_S3_bucket_name
variable "origin_bucket_name" {
  description = "Name of the S3 bucket for the origin"
  type        = string
}

#log_bucket_name
variable "log_bucket_name" {
  description = "Name of the S3 bucket for the logging"
  type        = string
}

variable "log_bucket_acl" {
  description = "S3 bucket acl"
  type        = string
}

# aws_cloudfront_cache_policy
variable "cache_policy" {
  description = "A list of string to provide values for the resource cache policy"
  type        = any
}

# aws_cloudfront_response_headers_policy
variable "response_headers_policy" {
  description = "A list of string to provide values for the resource response headers policy"
  type        = any
}

#cloudfront_origin_request_policy
variable "origin_request_policy" {
  description = "A list of string to provide values for the resource request policy."
  type        = any
}

# Variables for WAF WebAcl
variable "webacl_name" {
  description = "A friendly name of the WebACL."
  type        = string
}

variable "webacl_description" {
  description = "A description for the WebACL."
  type        = string
}

variable "request_default_action" {
  description = "The action to perform if none of the rules contained in the WebACL match."
  type        = string
}

variable "managed_rules" {
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  description = "List of Managed WAF rules."
}

# Variables for aws_wafv2_web_acl_logging_configuration
variable "redacted_fields" {
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  type        = any
}

variable "cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether the associated resource sends metrics to CloudWatch."
}

variable "sampled_requests_enabled" {
  type        = bool
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules."
}

variable "metric_name" {
  type        = string
  description = "A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example All and Default_Action."
}

# Variable for S3_bucket kinesis logging
variable "waf_v2_logging_kinesis_s3_bucket_name" {
  description = "Name of the S3 bucket for kinesis stream to store the waf v2 logs."
  type        = string
}

# Variables for iam role
variable "kinesis_iam_role_name" {
  description = "Name of the kinesis iam role"
  type        = string
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the aws_accounts variable is not provided."
  type        = list(string)
}

#Variables for Kms
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}