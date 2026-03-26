/*
 * # PG&E SAF Tags Validation Module
 *  Terraform base module to validate PG&E SAF mandatory tags and values
*/
#
# Filename    : modules/validate-pge-tags/main.tf
# Date        : 07 Feb 2022
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module validates PG&E SAF mandatory tags
#

terraform {
  required_version = ">= 1.1.0"
}

locals {
  tags = {
    tags = var.tags
  }
}
