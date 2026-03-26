/*
 * Athena Workgroup with New Glue Example
 *
 * Description:
 *   Demonstrates deployment of the base Athena workgroup
 *   module composed with the optional Glue submodule.
 *
 *   This example provisions:
 *     - Athena workgroup (configured with an existing S3 bucket for query results via `output_location`)
 *     - Glue database
 *     - Glue external table
 *
 *   Intended to show a complete Athena + Glue
 *   integration pattern.
 *
 * Example Path:
 *   aws/modules/athena/examples/athena_glue
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
# ATHENA WORKGROUP (BASE)
################################

module "athena" {
  source = "../../"

  athena_workgroup_name = var.athena_workgroup_name
  output_location       = var.output_location

  tags = module.tags.tags
}

################################
# GLUE (OPTIONAL LAYER)
################################

module "athena_glue" {
  source = "../../modules/glue"

  glue_database_name = var.glue_database_name
  glue_table_name    = var.glue_table_name

  data_bucket = var.data_bucket
  data_prefix = var.data_prefix

  columns = var.columns

  tags = module.tags.tags
}
