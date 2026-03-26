#variables for cluster endpoint
variable "neptune_cluster_identifier" {
  description = "The DB cluster identifier of the DB cluster associated with the endpoint."
  type        = string
}

variable "neptune_cluster_endpoint_identifier" {
  description = "The identifier of the endpoint."
  type        = string
}

variable "neptune_cluster_endpoint_type" {
  description = "The type of the endpoint. One of: READER, WRITER, ANY."
  type        = string
  validation {
    condition     = contains(["READER", "WRITER", "ANY"], var.neptune_cluster_endpoint_type)
    error_message = "Error! Valid values for endpoint_type are(READER, WRITER, ANY). Please select one of these!"
  }
}

variable "members" {
  description = <<-DOC
    static_members:
        (Optional) List of DB instance identifiers that are part of the custom endpoint group.
    excluded_members:
        (Optional) List of DB instance identifiers that aren't part of the custom endpoint group. All other eligible instances are reachable through the custom endpoint. Only relevant if the list of static members is empty.
  DOC

  type = object({
    static_members   = list(string)
    excluded_members = list(string)
  })

  default = {
    static_members   = []
    excluded_members = []
  }

  validation {
    condition     = length(var.members.static_members) > 0 ? length(var.members.excluded_members) == 0 : true
    error_message = "Error! excluded_members is only relevant if the list of static members is empty!"
  }
}

#variables for tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
