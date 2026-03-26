/*
 * # AWS SES module
 * Terraform module which creates SAF2.0 SES configuration set in AWS.
 * SES terraform resources don't support tags at this time.
 *
*/

#
#  Filename    : modules/ses/main.tf
#  Date        : 13 October 2022
#  Author      : s7aw@pge.com
#  Description : SES terraform module creates a ses resources.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


locals {
  tls_policy = "Require"
}

resource "aws_ses_configuration_set" "default" {
  name                       = var.ses_configuration_set_name
  reputation_metrics_enabled = var.reputation_metrics_enabled
  sending_enabled            = var.sending_enabled

  delivery_options {
    tls_policy = local.tls_policy
  }

  dynamic "tracking_options" {
    for_each = length(var.custom_redirect_domain) > 0 ? [1] : []
    content {
      custom_redirect_domain = var.custom_redirect_domain
    }
  }
}
