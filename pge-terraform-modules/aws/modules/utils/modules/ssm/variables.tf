#
# Filename    : modules/utils/modules/subnet/variables.tf
# Date        : 15 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get a generic parameter from the parameter store, default appid
#

variable "name" {
  description = "parameter store variable name, the full path"
  type        = string
  default     = "/general/appid"
}
