module "pl_graph" {
  count  = var.create_graph_pipeline ? 1 : 0
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  tags   = module.tags.tags
  prefix = var.prefix
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.app_id
  Environment        = local.environment
  DataClassification = local.data_classification
  CRIS               = local.cris
  Notify             = local.notify
  Owner              = local.owner
  Compliance         = local.compliance
  Order              = local.order
}
