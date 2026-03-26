#Variables for resource policy
variable "glue_resource_policy" {
  description = "The policy to be applied to the aws glue data catalog."
  type        = string
}

variable "glue_enable_hybrid" {
  description = " Indicates that you are using both methods to grant cross-account. Valid values are TRUE and FALSE. Note the terraform will not perform drift detetction on this field as its not return on read."
  type        = string
  default     = null
  validation {
    condition     = contains(["TRUE", "FALSE"], var.glue_enable_hybrid)
    error_message = "valid values for enable hybrid are TRUE,FALSE"
  }
}