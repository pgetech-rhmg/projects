/*
 * # AWS Sagemaker Model Package Group Policy example
*/
#
#  Filename    : aws/modules/sagemaker/examples/model_package_group_policy/main.tf
#  Date        : 02 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates model package group policy

# This will pull the model_package_group_policy module
module "model_package_group_policy" {
  source = "../../modules/model_package_group_policy"

  model_package_group_name            = var.model_package_group_name
  model_package_group_resource_policy = templatefile("${path.module}/model_package_group_policy.json", { account_num = var.account_num, aws_region = var.aws_region, name = var.model_package_group_name })
}