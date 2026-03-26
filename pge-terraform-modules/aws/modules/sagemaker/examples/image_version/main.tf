/*
 * # AWS Sagemaker image version example
 * # Terraform module example usage for Sagemaker image version
*/
#
#  Filename    : aws/modules/sagemaker/examples/image_version/main.tf
#  Date        : 6 september 2022
#  Author      : TCS
#  Description : The terraform module creates image version

module "sagemaker_image_version" {
  source = "../../modules/image_version"

  image_name = var.image_name
  base_image = var.base_image
}