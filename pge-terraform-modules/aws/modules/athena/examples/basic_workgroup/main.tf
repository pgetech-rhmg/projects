/*
 * Athena Basic Workgroup Example
 *
 * Description:
 *   Demonstrates standalone deployment of the Athena
 *   workgroup module without Glue integration.
 *
 *   This example provisions:
 *     - S3 bucket for Athena query results
 *     - Athena workgroup
 *
 *   Intended to show the minimal, composable usage
 *   pattern of the base Athena module.
 *
 * Example Path:
 *   aws/modules/athena/examples/basic_workgroup
 *
 * Author:
 *   PG&E Cloud Engineering
 */


##################################
# TAGS (PGE STANDARD)
##################################
locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################
# S3 FOR ATHENA RESULTS
################################

module "s3_results" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.3"
  bucket_name = var.results_bucket_name
  tags        = module.tags.tags
}

################################
# ATHENA WORKGROUP
################################

module "athena" {
  source                = "../../"
  tags                  = module.tags.tags
  athena_workgroup_name = var.athena_workgroup_name
  output_location       = "s3://${module.s3_results.id}/queries/"
}
