/*
* # AWS Sagemaker notebook instance lifecycle configuration example
* # Terraform module example usage for Sagemaker notebook instance lifecycle configuration 
*/
#  Filename    : aws/modules/sagemaker/examples/sagemaker_notebook_instance_lifecycle_configuration/main.tf
#  Date        : 21 Sep 2022
#  Author      : TCS
#  Description : The terraform module example for notebook instance lifecycle configuration

locals {
  name = "${var.name}-${random_string.name.result}"
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

# This will pull the sagemaker_notebook_instance_lifecycle_configuration module
module "lifecycle_configuration" {
  source = "../../modules/notebook_instance_lifecycle_configuration"

  name      = local.name
  on_create = base64encode(var.on_create)
  on_start  = base64encode(var.on_start)
}