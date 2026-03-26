#
# Filename    : modules/utils/modules/subnet/variables.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get subnet id or cidr from the parameter store
#

variable "subnet_num" {
  description = "subnet number for which id or cidr is requested"
  type        = number
  default     = 1
}

variable "is_cidr" {
  description = "set to true if cidr is to be read"
  type        = bool
  default     = false
}
