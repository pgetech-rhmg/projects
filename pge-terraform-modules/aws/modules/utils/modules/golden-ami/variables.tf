#
# Filename    : modules/utils/modules/golden-ami/variables.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the golden ami id from the parameter store
#

variable "os" {
  description = "operating system type"
  type        = string
  default     = "linux"
  validation {
    condition     = contains(["windows", "linux"], var.os)
    error_message = "OS can only be 'windows', 'linux' or 'linux-preview'"
  }
}

variable "parameter" {
  description = "Parameter store location to read"
  type        = string
  default     = null
}
