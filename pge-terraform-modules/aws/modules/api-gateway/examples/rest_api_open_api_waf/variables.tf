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

#variable for module api_gateway_rest_api
variable "rest_api_name" {
  description = "Name of the REST API."
  type        = string
}


variable "pVpcEndpoint" {
  description = "Vpc-endpoint for the resource policy"
  type        = string
}

#variable for api_gateway_deployment_and_stage
variable "stage_name" {
  description = "The name of the stage"
  type        = string
}

variable "stage_cache_cluster_enabled" {
  description = "Specifies whether a cache cluster is enabled for the stage."
  type        = bool
}

variable "stage_cache_cluster_size" {
  description = "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  type        = number
}

# api_gateway_method_settings
variable "method_settings_method_path" {
  description = "Method path defined as {resource_path}/{http_method} for an individual method override."
  type        = string
}

variable "settings_logging_level" {
  description = "Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = string
}

#api_gateway_api_key
variable "api_key_name" {
  description = "The name of the API key."
  type        = string
}

#variables for api_gateway_usage_plan
variable "usage_plan_name" {
  description = "The name of the usage plan."
  type        = string
}

variable "usage_plan_description" {
  description = " The description of a usage plan."
  type        = string
}

# variables for usage_plan_key
variable "usage_plan_key_type" {
  description = "The type of the API key resource. Currently, the valid key type is API_KEY."
  type        = string
}

#variable for optional_tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variable tags
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


variable "log_destination_arn" {
  description = "arn for capturing logs from WebACL."
  type        = string
}
variable "enable_waf" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = bool
  default     = true
}


############# Added variables for waf-v2 #############


# Variables for webacl

variable "web_acl_name" {
  description = "The name of the stage"
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}