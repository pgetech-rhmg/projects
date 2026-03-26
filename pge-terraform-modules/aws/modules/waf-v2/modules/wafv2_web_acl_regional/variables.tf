# Variables for webacl
variable "webacl_name" {
  description = "A friendly name for the WebACL. "
  type        = string
}

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
    scope_down_statement = optional(object({
      ip_set_reference_statement = optional(object({
        arn = string
        ip_set_forwarded_ip_config = optional(object({
          fallback_behavior = string
          header_name       = string
          position          = string
        }))
      }))
      geo_match_statement = optional(object({
        country_codes = list(string)
        forwarded_ip_config = optional(object({
          fallback_behavior = string
          header_name       = string
        }))
      }))
    }))
  }))
  default = []
}

variable "rule_visibility_enable_cloudwatch_metrics" {
  description = "Whether the associated resource sends metrics to CloudWatch."
  type        = bool
  default     = true
  validation {
    condition = anytrue([
      var.rule_visibility_enable_cloudwatch_metrics == true,
      var.rule_visibility_enable_cloudwatch_metrics == false
    ])
    error_message = "Allowed values for the variable 'rule_visibility_enable_cloudwatch_metrics' are : 'true' or 'false'."
  }
}

variable "rule_visibility_enable_sampled_requests" {
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules."
  type        = bool
  default     = true
  validation {
    condition = anytrue([
      var.rule_visibility_enable_sampled_requests == true,
      var.rule_visibility_enable_sampled_requests == false
    ])
    error_message = "Allowed values for the variable 'rule_visibility_enable_sampled_requests' are : 'true' or 'false'."
  }
}

# Variables for aws_wafv2_web_acl_logging_configuration

variable "log_destination_arn" {
  description = "arn for capturing logs from WebACL."
  type        = string
}

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

# Variables for aws_wafv2_web_acl_association

variable "resource_arn_to_associate_with_web_acl" {
  description = "The Amazon Resource Name (ARN) of the resource to associate with the web ACL. This must be an ARN of an Application Load Balancer or an Amazon API Gateway stage."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.resource_arn_to_associate_with_web_acl == null,
      can(regex("^arn:aws:elasticloadbalancing:\\w+(?:-\\w+)+:[[:digit:]]{12}:loadbalancer/([a-zA-Z0-9])+(.*)$", var.resource_arn_to_associate_with_web_acl))
    ])
    error_message = "ALB ARN is required and allowed format of the ARN is arn:aws:elasticloadbalancing:<region>:<account-id>:loadbalancer/<loadbalancer-type>/<loadbalancer-name>/<loadbalancer-id>."
  }
}

variable "enable_webacl_resource_association" {
  description = "Specifies if web acl association is to be enabled or not. The Boolean value to be enabled while associating waf with an Application Load Balancer or an Amazon API Gateway stage."
  type        = bool
  default     = false
  validation {
    condition = anytrue([
      var.enable_webacl_resource_association == true,
      var.enable_webacl_resource_association == false
    ])
    error_message = "Allowed values for the variable 'enable_webacl_resource_association' are : 'true' or 'false'."
  }
}

# Variables for IP reference Set

variable "ipset_reference_rules" {
  description = "List of ipset reference WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules."
  type        = list(any)
  default     = []
}

# Variables for Geo match statement

variable "geo_match_statement_rules" {
  description = "List of geo match statement WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules."
  type        = list(any)
  default     = []
}

# Variables for Label match statement

variable "label_match_statement_rules" {
  description = "List of label match statement WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules."
  type        = list(any)
  default     = []
}

# Variables for byte_match

variable "byte_match_rule" {
  description = "Rule statement that defines a string match search for AWS WAF to apply to web requests. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules"
  type        = list(any)
  default     = []
}

# Variables for xss_match

variable "xss_match_rule" {
  description = "Rule statement that defines a string match search for AWS WAF to apply to web requests. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules."
  type        = list(any)
  default     = []
}

# Variables for Rate Based Rule

variable "rate_based_rules" {
  description = "List of rate based WAF rules. For more details refer: https://registry.terraform.io/providers/hashicorp/aws/4.0.0/docs/resources/wafv2_web_acl#rules."
  type        = list(any)
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