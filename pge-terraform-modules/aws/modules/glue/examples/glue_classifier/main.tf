/*
* # AWS Glue Classifier with usage example.
* Terraform module which creates SAF2.0 Glue Classifier in AWS.
*/
#
# Filename    : modules/glue/examples/glue_classifier/main.tf
# Date        : 09 September 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue classifier.

locals {
  name = "${var.name}-${random_string.name.result}"
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
}

module "glue_classifier" {
  source = "../../../glue/modules/glue-classifier"

  classifier_name = local.name
  csv_classifier  = var.csv_classifier

}