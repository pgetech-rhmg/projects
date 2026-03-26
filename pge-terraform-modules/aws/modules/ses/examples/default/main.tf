/*
 * # AWS SES module example
 * Terraform module example which creates SAF2.0 SES configuration set in AWS.
 * SES terraform resources don't support tags at this time.
 *
*/
#
# Filename    : modules/ses/examples/main.tf
# Date        : 13 October 2022
# Author      : s7aw@pge.com
# Description : SES creation main
#

#########################################
# Create SES configuration set
#########################################
module "ses" {
  source                     = "../.."
  ses_configuration_set_name = var.ses_configuration_set_name
}

