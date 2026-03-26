# required for sumologic provider
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "lmnlbman" {
  count  = var.create_lmnlbman ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    github      = github
    sumologic   = sumologic
  }

  prefix         = "engagetest"
  tags           = local.tags
  node_env       = var.node_env
  suffix         = var.suffix
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = local.app_id
  Environment        = local.environment
  DataClassification = local.data_classification
  CRIS               = local.cris
  Notify             = local.notify
  Owner              = local.owner
  Compliance         = local.compliance
}
