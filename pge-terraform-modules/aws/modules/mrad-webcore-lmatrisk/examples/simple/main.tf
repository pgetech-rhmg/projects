# required for sumologic provider
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "lmatrisk" {
  count  = var.create_lmatrisk ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    github      = github
    sumologic   = sumologic
  }

  prefix         = var.prefix
  tags           = local.tags
  node_env       = var.node_env
  suffix         = var.suffix
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.0.5"

  AppID              = local.app_id
  Environment        = local.environment
  DataClassification = local.data_classification
  CRIS               = local.cris
  Notify             = local.notify
  Owner              = local.owner
  Compliance         = local.compliance
}

output "s3_object_hash" {
  value = module.lmatrisk[0].s3_object_hash
}
