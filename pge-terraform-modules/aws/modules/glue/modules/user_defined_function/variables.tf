variable "name" {
  description = "The name of the function."
  type        = string
}

variable "catalog_id" {
  description = "ID of the Glue Catalog to create the function in. If omitted, this defaults to the AWS Account ID"
  type        = string
  default     = null
}

variable "database_name" {
  description = "The name of the Database to create the Function."
  type        = string
}

variable "class_name" {
  description = "The Java class that contains the function code."
  type        = string
}

variable "owner_name" {
  description = "The owner of the function."
  type        = string
}

variable "owner_type" {
  description = "The owner type. can be one of USER, ROLE, and GROUP"
  type        = string
  validation {
    condition     = contains(["ROLE", "USER", "GROUP"], var.owner_type)
    error_message = "Error! enter a valid value for owner_type."
  }
}

variable "resource_uris" {
  description = "The configuration block for Resource URIs"
  type        = list(map(string))
  default     = []
  validation {
    condition     = alltrue([for element in var.resource_uris : contains(["JAR", "FILE", "ARCHIVE"], element["resource_type"])])
    error_message = "Error! enter a valid value for resource_type. Valid values are JAR, FILE and ARCHIVE."
  }
  validation {
    condition     = alltrue(flatten([for val in var.resource_uris : [for k, v in val : length(v) >= 1 && length(v) <= 1024 if k == "uri"]]))
    error_message = "Error! length of uri to be in the range (1 - 1024)."
  }
}
