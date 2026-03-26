variable "security_group_ids" {
  description = "Identifiers of the security groups for the fleet or image builder."
  type        = list(string)
}

variable "subnet_ids" {
  description = "Identifiers of the security groups for the fleet or image builder."
  type        = list(string)
}


variable "domain_arn" {
  description = "Domain ARN"
  type        = string
}