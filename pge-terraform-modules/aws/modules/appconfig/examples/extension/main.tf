/*
 * # AWS AppConfig User module example
*/
#
#  Filename    : aws/modules/appconfig/examples/extension/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module creates an AppConfig extension

data "aws_caller_identity" "this" {}

module "extension" {
  source = "../../modules/extension"

  name        = var.name
  description = var.description

  parameter_name        = var.parameter_name
  parameter_required    = var.parameter_required
  parameter_description = var.parameter_description

  action_point       = var.action_point
  action_name        = var.action_name
  action_role        = var.action_role
  action_uri         = var.action_uri
  action_description = var.action_description

  enable_extension_association             = var.enable_extension_association
  resource_arn_to_associate_with_extension = var.resource_arn_to_associate_with_extension
}