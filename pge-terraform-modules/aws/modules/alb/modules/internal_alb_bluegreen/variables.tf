####################################### variables of lb ######################################

variable "alb_name" {
  description = "Name of the alb on AWS"
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
}

variable "subnets" {
  description = "A list of private subnet IDs to attach to the LB if it is INTERNAL." ##
  type        = list(string)

  validation {
    condition = alltrue([
      for subnet in var.subnets : can(regex("^subnet-\\w+", subnet))
    ])
    error_message = "Error! Subnetsis required and allowed format of the subnets is subnet-#################."
  }
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "Name of the s3 bucket to store alb logs on AWS"
  type        = string
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default: 60."
  type        = number
  default     = 60

  validation {
    condition = anytrue([
    can(regex("^[0-9]+$", var.idle_timeout))])
    error_message = "Error! value for idle_timeout should be a number."
  }
}

variable "enable_waf_fail_open" {
  description = "Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF."
  type        = bool
  default     = true
}

variable "customer_owned_ipv4_pool" {
  description = "The ID of the customer owned ipv4 pool to use for this load balancer."
  type        = string
  default     = null

  validation {
    condition = anytrue([
      can(cidrnetmask(var.customer_owned_ipv4_pool)),
      var.customer_owned_ipv4_pool == null
    ])
    error_message = "Error! Enter a valid value for customer owned ipv4."
  }
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. Defaults to ipv4"
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.ip_address_type == null,
      var.ip_address_type == "ipv4",
    var.ip_address_type == "dualstack"])
    error_message = "Error! values for ip_address_type should be ipv4 and dualstack ."
  }
}

variable "desync_mitigation_mode" {
  description = "Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync."
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.desync_mitigation_mode == null,
      var.desync_mitigation_mode == "monitor",
      var.desync_mitigation_mode == "defensive",
    var.desync_mitigation_mode == "strictest"])
    error_message = "Error! values for desync_mitigation_mode should be monitor, defensive and strictest ."
  }
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in the load balancer. Defaults to true."
  type        = bool
  default     = true
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

####################################### variables of listener ######################################
variable "lb_listener_http" {
  description = "A list of maps describing HTTP listeners for ALB."
  type        = any
  default     = []
}

variable "lb_listener_https" {
  description = "A list of maps describing HTTPS listeners for ALB."
  type        = any
  default     = []
}

####################################### variables of listener certificate ######################################
variable "certificate_arn" {
  description = "The ARN of the certificate to attach to the listener."
  type        = list(map(string))
  default     = []

  validation {
    condition = alltrue([
      for i in var.certificate_arn : can(regex("^arn:aws:acm:\\w+(?:-\\w+)+:[[:digit:]]{12}:certificate/+(.*)$", i.certificate_arn))
    ])
    error_message = "Error! Enter a valid certificate arn."
  }
}

####################################### variables of listener rule ######################################
variable "lb_listener_rule_http" {
  description = "A list of maps describing the listener rules for ALB."
  type        = any
  default     = []
}

variable "lb_listener_rule_https" {
  description = "A list of maps describing the listener rules for ALB."
  type        = any
  default     = []
}

####################################### variables of target group ######################################
variable "lb_target_group" {
  description = "A list of maps containing key/value pairs for the target groups to be created for ALB."
  type        = any
  default     = []
}

variable "vpc_id" {
  description = "Identifier of the VPC in which to create the target group."
  type        = string

  validation {
    condition     = can(regex("^(vpc-).+[a-z0-9]$", var.vpc_id))
    error_message = "Error! Enter a valid vpc id."
  }
}
