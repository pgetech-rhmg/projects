/*
 * # AWS Tags Module
 *  Terraform base module for deploying and managing mandatory tags on Amazon Web Services (AWS).
*/
#
# Filename    : modules/tag/main.tf
# Date        : 22 Nov 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : This terraform module applies mandatory tags to the resources.
#

terraform {
  required_version = ">= 1.1.0"
}

locals {
  tags = {
    AppID              = "APP-${var.AppID}"
    Environment        = var.Environment
    DataClassification = var.DataClassification
    CRIS               = var.CRIS
    Notify             = join("_", var.Notify)
    Owner              = join("_", var.Owner)
    Compliance         = join("_", var.Compliance)
    Order              = var.Order
  }
}

