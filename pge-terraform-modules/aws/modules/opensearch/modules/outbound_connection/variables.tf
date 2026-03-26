variable "local_domain" {
  description = "Local Domain Name"
  type        = string
}

variable "remote_domain" {
  description = "Remote domain name"
  type        = string
}

variable "connection_mode" {
  description = "Connection Type Direct or vpc_endpoint"
  type        = string
  default     = "DIRECT"
}

variable "connection_alias" {
  description = "Outbound Connection alias"
  type        = string
}