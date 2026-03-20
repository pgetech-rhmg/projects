variable "role_name" {
  type    = string
  default = "EPIC-Deployment-Role"
}

variable "create_oidc_provider" {
  type    = bool
  default = true
}

variable "bucket_name" {
  type = string
  default = ""
}
