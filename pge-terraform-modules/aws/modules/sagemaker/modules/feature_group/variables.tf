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

# variables for feature group
variable "feature_group_name" {
  description = "The name of the Feature Group. The name must be unique within an AWS Region in an AWS account."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,100}$", var.feature_group_name))
    error_message = "Allowed alphanumeric characters: a-z, A-Z, 0-9, and - (hyphen)."
  }
  validation {
    condition     = anytrue([length(var.feature_group_name) <= 63])
    error_message = "Maximum of 63 alphanumeric characters. Can include hyphens (-), but not spaces. Must be unique within your account in an AWS Region."
  }
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM execution role used to persist data into the Offline Store if an offline_store_config is provided."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.role_arn))
    ])
    error_message = "Role arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "feature_definition" {
  description = "A list of Feature names and types. See Feature Definition Below."
  type        = list(any)
  default     = []

  validation {
    condition     = alltrue([for va in var.feature_definition : !contains(["is_deleted", "write_time", "api_invocation_time"], lookup(va, "feature_name"))])
    error_message = "Error! feature_name do not accept these values is_deleted, write_time and api_invocation_time "
  }

  validation {
    condition     = alltrue([for va in var.feature_definition : contains(["String", "Fractional", "Integer"], lookup(va, "feature_type"))])
    error_message = "Error! enter a valid value for feature_type are String, Fractional and Integer"
  }
}

variable "description" {
  description = " A free-form description of a Feature Group."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The Amazon Key Management Service (KMS) key ARN for server-side encryption."
  type        = string

}

variable "offline_store_config" {
  description = "The Offline Feature Store Configuration. See Offline Store Config Below."
  #As per Terraform registry data type 'map(any)' should contain elements of the same type, for the block 'offline_store_config'
  #the variable 'offline_store_config' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null
}

variable "online_store_config" {
  description = "The Online Feature Store Configuration. See Online Store Config Below."
  #As per Terraform registry data type 'map(any)' should contain elements of the same type, for the block 'online_store_config'
  #the variable 'online_store_config' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null
}

variable "feature_name" {
  description = <<-DOC
    record_identifier_feature_name:
     The name of the Feature whose value uniquely identifies a Record defined in the Feature Store. Only the latest record per identifier value will be stored in the Online Store
    event_time_feature_name:
     The name of the feature that stores the EventTime of a Record in a Feature Group.
    DOC

  type = object({
    record_identifier_feature_name = string
    event_time_feature_name        = string

  })
  validation {
    condition     = var.feature_name.record_identifier_feature_name == var.feature_name.event_time_feature_name ? false : true
    error_message = "Error! required identifier feature name  is not equal to event time feature name "
  }
}