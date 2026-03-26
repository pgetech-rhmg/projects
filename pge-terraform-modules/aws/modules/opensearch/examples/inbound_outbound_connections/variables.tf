variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}
variable "local_domain" {
  description = "Local Domain Name"
  type        = string
}

variable "remote_domain" {
  description = "Remote Domain Name"
  type        = string
}

variable "outbound_connection_enabled" {
  type    = map(any)
  default = {}
}

variable "inbound_connection_enabled" {
  type    = map(any)
  default = {}
}

variable "connection_alias" {
  type = string
}