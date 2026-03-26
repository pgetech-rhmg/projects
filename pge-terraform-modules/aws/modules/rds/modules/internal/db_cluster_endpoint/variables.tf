variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "cluster_identifier" {
  description = "The cluster identifier."
  type        = string
}
variable "cluster_endpoint_identifier" {
  description = "The identifier to use for the new endpoint(only lowercase alphanumeric and hyphens allowed). This parameter is stored as a lowercase string."
  type        = string
}

variable "custom_endpoint_type" {
  description = "The type of the endpoint. One of: READER, ANY ."
  type        = string
}

variable "static_members" {
  description = "(Optional) List of DB instance identifiers that are part of the custom endpoint group. Conflicts with excluded_members."
  type        = list(string)
  default     = []
}

variable "excluded_members" {
  description = "(Optional) List of DB instance identifiers that aren't part of the custom endpoint group. All other eligible instances are reachable through the custom endpoint. Only relevant if the list of static members is empty. Conflicts with static_members."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags."
  type        = map(string)
  default     = {}
}
# validate the tags passed
module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}
