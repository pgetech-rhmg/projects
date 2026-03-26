#variables for api_gateway_deployment
variable "rest_api_id" {
  description = "The ID of the REST API"
  type        = string
}

variable "deployment_description" {
  description = "The description of the deployment."
  type        = string
  default     = null
}

variable "deployment_triggers" {
  description = "Map of arbitrary keys and values that, when changed, will trigger a redeployment."
  type        = map(string)
  default     = null
}

variable "deployment_variables" {
  description = "Map to set on the stage managed by the stage_name argument."
  type        = map(string)
  default     = null
}

#variables for api_gateway_stage
variable "stage_name" {
  description = "The name of the stage."
  type        = string
}

variable "stage_cache_cluster_enabled" {
  description = "Specifies whether a cache cluster is enabled for the stage."
  type        = bool
  default     = false
}

variable "stage_cache_cluster_size" {
  description = "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  type        = number
  default     = null
  validation {
    condition = anytrue([
      var.stage_cache_cluster_size == null,
      var.stage_cache_cluster_size == 0.5,
      var.stage_cache_cluster_size == 1.6,
      var.stage_cache_cluster_size == 6.1,
      var.stage_cache_cluster_size == 13.5,
      var.stage_cache_cluster_size == 28.4,
      var.stage_cache_cluster_size == 58.2,
      var.stage_cache_cluster_size == 118,
    var.stage_cache_cluster_size == 237])
    error_message = "Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  }
}

variable "stage_client_certificate_id" {
  description = "The identifier of a client certificate for the stage"
  type        = string
  default     = null
}

variable "stage_description" {
  description = "The description of the stage."
  type        = string
  default     = null
}

variable "stage_documentation_version" {
  description = "The version of the associated API documentation."
  type        = string
  default     = null
}

variable "stage_variables" {
  description = "A map that defines the stage variables."
  type        = map(string)
  default     = null
}

variable "stage_xray_tracing_enabled" {
  description = "Describes Whether active tracing with X-ray is enabled."
  type        = bool
  default     = false
}

variable "access_log_settings_destination_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch Logs log group or Kinesis Data Firehose delivery stream to receive access logs."
  type        = string
  default     = null
}

variable "access_log_settings_format" {
  description = "The formatting and values recorded in the logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#api_gateway_method_settings
variable "method_settings_method_path" {
  description = "Method path defined as {resource_path}/{http_method} for an individual method override."
  type        = string
  default     = null
}

variable "settings_logging_level" {
  description = "Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = string
  default     = "INFO"
  validation {
    condition = anytrue([
      var.settings_logging_level == "OFF",
      var.settings_logging_level == "ERROR",
    var.settings_logging_level == "INFO"])
    error_message = "Valid values for logging level are  OFF, ERROR, and INFO."
  }
}

variable "settings_data_trace_enabled" {
  description = "Specifies whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = bool
  default     = false
}

variable "settings_throttling_burst_limit" {
  description = "Specifies the throttling burst limit."
  type        = number
  default     = -1
}

variable "settings_throttling_rate_limit" {
  description = "Specifies the throttling rate limit."
  type        = number
  default     = -1
}

variable "settings_caching_enabled" {
  description = "Specifies whether responses should be cached and returned for requests.A cache cluster must be enabled on the stage for responses to be cached."
  type        = bool
  default     = true
}

variable "settings_cache_ttl_in_seconds" {
  description = "Specifies the time to live (TTL), in seconds, for cached responses. The higher the TTL, the longer the response will be cached."
  type        = number
  default     = null
}

#variables for api_gateway_base_path_mapping
variable "base_path_mapping_domain_name" {
  description = "The already-registered domain name to connect the API to."
  type        = string
  default     = null
}

variable "base_path_mapping_stage_name" {
  description = "The name of a specific deployment stage to expose at the given path"
  type        = string
  default     = null
}

variable "base_path_mapping_base_path" {
  description = "Path segment that must be prepended to the path when accessing the API via this mapping."
  type        = string
  default     = null
}