#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#variables for api_gateway_deployment
variable "deployment_rest_api_id" {
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
  default     = null
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

#variables for api_gateway_client_certificate
variable "api_gateway_client_certificate_create" {
  description = "Whether to create API Gateway Client Certificate."
  type        = bool
  default     = false
}

variable "client_certificate_description" {
  description = "The description of the client certificate."
  type        = string
  default     = null
}

#variables for api_gateway_vpc_link
variable "vpc_link_name" {
  description = "The name used to label and identify the VPC link."
  type        = string
  default     = null
}

variable "vpc_link_description" {
  description = "The description of the VPC link."
  type        = string
  default     = null
}

variable "vpc_link_target_arns" {
  description = "The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target."
  type        = list(string)
  default     = null
}

#variables aws_api_gateway_documentation_part
variable "documentation_part_properties" {
  description = "A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published."
  type        = string
  default     = null
}

variable "location_method" {
  description = " The HTTP verb of a method. The default value is * for any method."
  type        = string
  default     = null
}

variable "location_name" {
  description = " The name of the targeted API entity."
  type        = string
  default     = null
}

variable "location_path" {
  description = " The URL path of the target. The default value is / for the root resource."
  type        = string
  default     = null
}

variable "location_status_code" {
  description = " The HTTP status code of a response. The default value is * for any status code."
  type        = string
  default     = null
}

variable "location_type" {
  description = " The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST_BODY"
  type        = string
  default     = null
}

#aws_api_gateway_documentation_version
variable "documentation_version" {
  description = " The version identifier of the API documentation snapshot."
  type        = string
  default     = null
}

variable "documentation_description" {
  description = " The description of the API documentation version."
  type        = string
  default     = null
}

# variables for api_gateway_account
variable "api_gateway_account_create" {
  description = "Whether to create API Gateway gateway response."
  type        = bool
  default     = false
}

variable "account_cloudwatch_role_arn" {
  description = "The ARN of an IAM role for CloudWatch (to allow logging & monitoring)."
  type        = string
  default     = null
}

