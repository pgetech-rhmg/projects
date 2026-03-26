# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variable for Glue Connection

variable "glue_connection_name" {
  description = "The name of the connection."
  type        = string
}

variable "glue_connection_type" {
  description = "The type of the connection. Supported are: CUSTOM, JDBC, KAFKA, MARKETPLACE, MONGODB, and NETWORK."
  type        = string
  validation {
    condition = anytrue([
      var.glue_connection_type == "CUSTOM",
      var.glue_connection_type == "JDBC",
      var.glue_connection_type == "KAFKA",
      var.glue_connection_type == "MARKETPLACE",
      var.glue_connection_type == "MONGODB",
    var.glue_connection_type == "NETWORK"])
    error_message = "Error! values for glue_connection_type should be CUSTOM, JDBC, KAFKA, MARKETPLACE, MONGODB or NETWORK."
  }
}

variable "glue_connection_properties" {
  description = "A map of key-value pairs used as parameters for this connection."
  type        = map(string)
  default     = {}
}

variable "glue_connection_description" {
  description = "Description of the connection."
  type        = string
  default     = null
}

variable "glue_connection_match_criteria" {
  description = "A list of criteria that can be used in selecting this connection."
  type        = list(string)
  default     = []
}

variable "glue_connection_catalog_id" {
  description = "The ID of the Data Catalog in which to create the connection. If none is supplied, the AWS account ID is used by default."
  type        = string
  default     = null
}

variable "glue_connection_physical_connection_requirements" {
  description = "A map of physical connection requirements, such as VPC and SecurityGroup. Defined below."
  type        = list(any)
  default     = []
}