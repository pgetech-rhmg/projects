/*
 * # PG&E workspace-info utils sub module
 *  Terraform module to get workspace name and workspace id
*/
#
# Filename    : modules/utils/modules/workspace-info/main.tf
# Date        : 19 Apr 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : get workspace name and id if executed in terraform cloud;
#               when executed locally, get pwd and user details
#

terraform {
  required_version = ">= 1.1.0"
}

locals {
  module_path = abspath(path.module)
}

data "external" "ws" {
  program = ["${local.module_path}/getws"]
}

locals {
  ws_name = data.external.ws.result["name"]
  ws_id   = data.external.ws.result["id"]
  ws_all  = data.external.ws.result
}
