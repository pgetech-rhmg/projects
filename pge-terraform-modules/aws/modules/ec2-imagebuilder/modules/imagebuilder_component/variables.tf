
variable "component_name_prefix" {
  description = "name prefix of the component"
  type        = string

}
variable "change_description" {
  default     = null
  description = "description of changes since last version"
  type        = string

}
variable "component_version" {
  description = "version of the component"
  type        = string

}
variable "component_data" {
  description = "Map of component data that can either contain file path or data URI"
  type        = map(string)
  default     = {}

}
variable "description" {
  default     = null
  description = "description of component"
  type        = string

}
variable "component_kms_key_id" {
  default     = null
  description = "KMS key to use for encryption"
  type        = string

}

variable "component_platform" {
  default     = "Linux"
  description = "platform of component(Linux or Windows)"
  type        = string

}
variable "supported_os_versions" {
  default     = null
  description = "Aset of operating system versions supported by the component. If the os information is available, a prefix match is performed against  base image os version during image recipe creation."
  type        = set(string)

}
variable "tags" {
  default     = {}
  description = "Map of tags to use for CFN stack and component"
  type        = map(string)

}