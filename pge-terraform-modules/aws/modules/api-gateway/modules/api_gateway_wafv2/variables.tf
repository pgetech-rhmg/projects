# Variables for webacl

variable "webacl_description" {
  description = "A description for the WebACL. "
  type        = string
  default     = null
}

variable "request_default_action" {
  description = "The action to perform if none of the rules contained in the WebACL match."
  type        = string
  validation {
    condition     = contains(["allow", "block"], var.request_default_action)
    error_message = "Valid values for default_action are (allow,block)."
  }
}

variable "cloudwatch_metrics_enabled" {
  description = "A boolean indicating whether the associated resource sends metrics to CloudWatch"
  type        = bool
  validation {
    condition = anytrue([
      var.cloudwatch_metrics_enabled == true,
      var.cloudwatch_metrics_enabled == false
    ])
    error_message = "Allowed values for the variable 'cloudwatch_metrics_enabled' are : 'true' or 'false'."
  }
}

variable "metric_name" {
  description = "A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF for example All and Default_Action."
  type        = string
  validation {
    condition = anytrue([
      var.metric_name == null,
      can(regex("\\w+(?:-\\w+)+([a-zA-Z0-9])+(.*)$", var.metric_name))
    ])
    error_message = "The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example All and Default_Action."
  }
}

variable "custom_response_body" {
  description = <<-DOC
     key:
     Unique key identifying the custom response body. This is referenced by the custom_response_body_key argument in the Custom Response block.
     content:
     Payload of the custom response.
    content_type:
     Type of content in the payload that you are defining in the content argument. Valid values are TEXT_PLAIN, TEXT_HTML, or APPLICATION_JSON.
     DOC
  type = list(object({
    key          = string
    content      = string
    content_type = string
  }))
  default = []
}

variable "sampled_requests_enabled" {
  description = "A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules."
  type        = bool
  validation {
    condition = anytrue([
      var.sampled_requests_enabled == true,
      var.sampled_requests_enabled == false
    ])
    error_message = "Allowed values for the variable 'sampled_requests_enabled' are : 'true' or 'false'."
  }
}

variable "managed_rules" {
  description = "List of Managed WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules."
  type = list(object({
    name            = string
    priority        = number
    override_action = string
    excluded_rules  = list(string)
  }))
  default = []
}




# Variables for aws_wafv2_web_acl_logging_configuration


variable "logging_filter" {
  description = "A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  type        = any
  default     = {}
}

variable "redacted_fields" {
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  type        = any
  default     = []
}

# Variables for Tags

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# variables for aws_wafv2_web_acl_association

# Output for api_gateway_stage
variable "api_gateway_stage_arn" {
  description = "The Amazon Resource Name (ARN) for API Gateway Stage"
  type        = string
}

variable "enable_waf" {
  description = "to enable during deployment Stage"
  type        = bool
  default     = true
}


variable "log_destination_arn" {
  description = "arn for capturing logs from WebACL."
  type        = string
}

variable "web_acl_name" {
  description = "The name of the stage"
  type        = string
}

variable "key" {
  description = "this is to define key value"
  type        = string
  default     = "sample"
}


variable "content" {
  description = "conetent value"
  type        = string
  default     = "abcdefg"
}


variable "content_type" {
  description = "content_type value "
  type        = string
  default     = "TEXT_PLAIN"
}