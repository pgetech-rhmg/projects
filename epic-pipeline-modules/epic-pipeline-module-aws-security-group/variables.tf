############################################
# Core
############################################

variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "label" {
  description = "Additional naming label"
  type        = string
}

variable "description" {
  description = "Security Group description"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC that the instance security group belongs to."
  type        = string
}


############################################
# Rules
############################################

variable "cidr_ingress_rules" {
  description = "Configuration block for ingress rules. Can be specified multiple times for each ingress rule."
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
}

variable "cidr_egress_rules" {
  description = "Configuration block for egress rules. Can be specified multiple times for each egress rule."
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule."
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
}

variable "security_group_egress_rules" {
  description = "Configuration block for for nested security groups egress rules. Can be specified multiple times for each egress rule."
  type = list(object({
    from                     = number
    to                       = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default     = []
}


############################################
# Tags
############################################

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
