module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

module "emr_serverless_hive" {
  source = "../../modules/serverless"

  name                 = "${var.name}-hive-cluster"
  release_label_prefix = var.release_label_prefix
  type                 = var.type

  initial_capacity          = var.initial_capacity
  interactive_configuration = var.interactive_configuration
  maximum_capacity          = var.maximum_capacity
  monitoring_configuration  = var.monitoring_configuration
  tags = merge(module.tags.tags, var.optional_tags)
  
}