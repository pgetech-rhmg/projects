#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for glue schema
variable "glue_schema_name" {
  description = "The Name of the schema."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_$#.]+$", var.glue_schema_name))
    error_message = "Error! schema name can only contain alphanumeric characters and underscores (_)and dollar signs ($),hyphens (-),periods (.) or hash marks (#),"
  }
  validation {
    condition     = length(var.glue_schema_name) <= 255
    error_message = "Errror!  the length of glue schema name is lessthen are equal to 255"
  }
}

variable "glue_registry_arn" {
  description = "The ARN of the Glue Registry to create the schema in."
  type        = string
}

variable "glue_data_format" {
  description = "The data format of the schema definition. Valid values are AVRO, JSON and PROTOBUF."
  type        = string
  validation {
    condition = anytrue([
      var.glue_data_format == "AVRO",
      var.glue_data_format == "JSON",
    var.glue_data_format == "PROTOBUF"])
    error_message = "valid values for glue data format : AVRO, JSON, PROTOBUF"
  }
}

variable "glue_compatibility" {
  description = "The compatibility mode of the schema. Values values are: NONE, DISABLED, BACKWARD, BACKWARD_ALL, FORWARD, FORWARD_ALL, FULL, and FULL_ALL."
  type        = string
  validation {
    condition = anytrue([
      var.glue_compatibility == "NONE",
      var.glue_compatibility == "DISABLED",
      var.glue_compatibility == "BACKWARD",
      var.glue_compatibility == "BACKWARD_ALL",
      var.glue_compatibility == "FORWARD",
      var.glue_compatibility == "FORWARD_ALL",
      var.glue_compatibility == "FULL",
    var.glue_compatibility == "FULL_ALL"])
    error_message = "Valid values for glue compatibility: NONE, DISABLED, BACKWARD, BACKWARD_ALL, FORWARD, FORWARD_ALL, FULL, FULL_ALL."
  }
}

variable "glue_schema_definition" {
  description = "The schema definition using the data_format setting for schema_name."
  type        = string
}

variable "glue_schema_description" {
  description = "A description of the schema."
  type        = string
  default     = null
}