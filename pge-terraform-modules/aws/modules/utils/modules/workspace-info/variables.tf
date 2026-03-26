#
# Filename    : modules/utils/modules/workspace-info/variables.tf
# Date        : 19 Apr 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get workspace name and id if executed in terraform cloud;
#               when executed locally, get pwd and user details
#

variable "workspace_name" {
  description = "workspace name"
  type        = string
  default     = null
}

variable "workspace_id" {
  description = "workspace id"
  type        = string
  default     = null
}
