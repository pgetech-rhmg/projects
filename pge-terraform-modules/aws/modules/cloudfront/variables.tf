# aws_cloudfront_distribution
variable "aliases" {
  description = "Aliases, or CNAMES, for the distribution"
  type        = list(string)
  default     = null
}

variable "comment_cfd" {
  description = "comment for cloudfront distribution"
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  type        = bool
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2"
  type        = string
  default     = "http2"

  validation {
    condition     = contains(["http1.1", "http2"], var.http_version)
    error_message = "Error! Valid values for type are http1.1 and http2.Please select any of these parameters."
  }
}

variable "custom_error_response" {
  description = "Custom error response to be used for cloudfront distribution."
  type        = any
  default     = []
}

variable "lambda_function_association" {
  description = "A config block that triggers a lambda function with specific actions"
  type        = any
  default     = []
}

variable "function_association" {
  description = "A config block that triggers a cloudfront function with specific actions"
  type        = any
  default     = []
}

variable "forwarded_values" {
  description = "The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers"
  type        = any
  default     = []
}

variable "df_cache_behavior_allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
  type        = list(string)
}

variable "df_cache_behavior_cached_methods" {
  description = " Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
}

variable "df_cache_behavior_cache_policy_id" {
  description = "The unique identifier of the cache policy that is attached to the cache behavior."
  type        = string
  default     = null
}

variable "df_cache_behavior_default_ttl" {
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header."
  type        = number
  default     = null
}

variable "df_cache_behavior_compress" {
  description = "Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false)."
  type        = bool
  default     = false
}

variable "df_cache_behavior_field_level_encryption_id" {
  description = "Field level encryption configuration ID"
  type        = string
  default     = null
}

variable "df_cache_behavior_target_origin_id" {
  description = "The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior"
  type        = string
}

variable "df_cache_behavior_max_ttl" {
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated."
  type        = number
  default     = null
}

variable "df_cache_behavior_min_ttl" {
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds."
  type        = number
  default     = null
}

variable "df_cache_behavior_origin_request_policy_id" {
  description = "The unique identifier of the origin request policy that is attached to the behavior"
  type        = string
  default     = null
}

variable "df_cache_behavior_realtime_log_config_arn" {
  description = "The ARN of the real-time log configuration that is attached to this cache behavior."
  type        = string
  default     = null
}

variable "df_cache_behavior_response_headers_policy_id" {
  description = "The identifier for a response headers policy."
  type        = string
  default     = null
}

variable "df_cache_behavior_smooth_streaming" {
  description = "Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior."
  type        = bool
  default     = null
}

variable "df_cache_behavior_trusted_key_groups" {
  description = "A list of key group IDs that CloudFront can use to validate signed URLs or signed cookies. "
  type        = list(string)
  default     = null
}

variable "df_cache_behavior_trusted_signers" {
  description = "List of AWS account IDs (or self) that you want to allow to create signed URLs for private content."
  type        = list(string)
  default     = null
}

variable "df_cache_behavior_viewer_protocol_policy" {
  description = "specifies the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern."
  type        = string
  validation {
    condition     = contains(["https-only", "redirect-to-https"], var.df_cache_behavior_viewer_protocol_policy)
    error_message = "Error! Valid values for type are allow-all, https-only, or redirect-to-https. Please select any of these parameters."
  }
}

variable "logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution"
  type        = any
}

variable "origin_group" {
  description = "One or more origin_group for this distribution"
  type        = any
  default     = []
}

variable "price_class" {
  description = "The price class of the CloudFront Distribution. Valid types are PriceClass_All, PriceClass_100, PriceClass_200"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = anytrue([
      var.price_class == null,
      var.price_class == "PriceClass_All",
      var.price_class == "PriceClass_200",
      var.price_class == "PriceClass_100"
    ])
    error_message = "Valid values for type are PriceClass_All, PriceClass_200, PriceClass_100.Please select any of these parameters."
  }
}

variable "web_acl_id" {
  description = "A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution."
  type        = string
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = true
}

variable "origin" {
  description = "One or more origins for this distribution"
  type        = any
}

variable "ordered_cache_behavior" {
  description = "An ordered list of cache behaviors resource for this distribution"
  type        = any
  default     = []
}

variable "geo_restriction" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)"
  type        = any
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

##################################################################################################################
# cloudfront_monitoring_subscription 

variable "cf_monitoring_subscription" {
  description = "Creates a monitoring subscription "
  type        = any
  default     = []
}

##################################################################################################################
# aws_cloudfront_realtime_log_config

variable "cf_realtime_log_config" {
  description = "Creates a realtime log config"
  type        = any
  default     = []
}
