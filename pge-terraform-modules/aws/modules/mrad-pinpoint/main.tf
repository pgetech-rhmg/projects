/*
 * # PG&E Mrad Pinpoint Module
 *  MRAD specific Pinpoint module to provision SAF compliant resources
*/
#
# Filename    : modules/mrad-pinpoint/main.tf
# Date        : 20 Feb 2025
# Author      : MRAD (mrad@pge.com)
# Description : This terraform module provisions MRAD compatible Pinpoint project and custom configurations
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

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0" 
  # only required for local dev since both values are predefined in TFC
  account_num = var.account_num
  aws_role    = var.aws_role
}

resource "aws_pinpoint_app" "main" {
  name = var.app_name
  tags = module.mrad-common.tags
}

resource "aws_pinpoint_sms_channel" "main" {
  count          = var.enable_sms ? 1 : 0 #create only if enabled
  application_id = aws_pinpoint_app.main.id
  enabled        = var.enable_sms
}

resource "aws_pinpoint_email_channel" "main" {
  count          = var.enable_email ? 1 : 0 #create only if enabled
  application_id = aws_pinpoint_app.main.id
  from_address   = var.email_from
  identity       = var.email_identity
  enabled        = var.enable_email
}

resource "aws_pinpoint_apns_channel" "main" {
  count          = var.enable_push ? 1 : 0 #create only if enabled
  application_id = aws_pinpoint_app.main.id
  bundle_id      = var.apns_bundle_id
  team_id        = var.apns_team_id
  token_key      = var.apns_token_key
  token_key_id   = var.apns_token_key_id
  enabled        = var.enable_push
}

resource "aws_pinpoint_apns_sandbox_channel" "sandbox" {
  count          = (var.account_num == "712640766496") ? 0 : 1
  application_id = aws_pinpoint_app.main.id
  bundle_id      = var.apns_bundle_id
  team_id        = var.apns_team_id
  token_key      = var.apns_token_key
  token_key_id   = var.apns_token_key_id
  enabled        = var.enable_push
}
