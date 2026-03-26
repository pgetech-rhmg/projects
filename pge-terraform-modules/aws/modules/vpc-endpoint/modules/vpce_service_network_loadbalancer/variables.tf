variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "network_load_balancer_arns" {
  description = "A list of network_load_balancer_arns"
  type        = list(string)
  validation {
    condition = anytrue([
      for i in var.network_load_balancer_arns :
      can(regex("^arn:aws:elasticloadbalancing:\\w+(?:-\\w+)+:[[:digit:]]{12}:loadbalancer/net/([a-zA-Z0-9])+(.*)$", i))

    ])
    error_message = "Network_load_balancer_arns is required and the allowed format of 'network_load_balancer_arns' is arn:aws:elasticloadbalancing:<region>:<account-id>:loadbalancer/net/<network-loadbalancer-id>."
  }
}

variable "allowed_principals" {
  type        = list(any)
  description = "The ARNs of one or more principals allowed to discover the endpoint service."
  default     = null
}

variable "private_dns_name" {
  type        = string
  description = "The private DNS name for the service."
  default     = null
}

variable "acceptance_required" {
  type        = bool
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner - true or false."
  validation {
    condition = anytrue([
      var.acceptance_required == true,
      var.acceptance_required == false
    ])
    error_message = "Allowed values for the variable 'acceptance_required' are : 'true' or 'false'."
  }
}
