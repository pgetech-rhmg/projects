/*
*# AWS GLUE with usage example
*Terraform module which creates SAF2.0 Glue Resource Policy resources in AWS. 
*/
#
# Filename    : modules/glue/examples/glue_resource_policy/main.tf
# Date        : 22 Auguest 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue resource policy.

module "glue_resource_policy" {
  source = "../../../glue/modules/glue_resource_policy"

  glue_resource_policy = templatefile("${path.module}/resource_policy.json", { account_num = var.account_num, aws_region = var.aws_region, role_name = var.role_name })
  glue_enable_hybrid   = var.glue_enable_hybrid
}

