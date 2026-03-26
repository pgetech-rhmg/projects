#
# Filename    : modules/utils/modules/vpcid/variables.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module gets the vpc id from the parameter store
#

variable "parameter" {
  description = "Parameter store location to read"
  type        = string
  default     = "/vpc/id"
}
