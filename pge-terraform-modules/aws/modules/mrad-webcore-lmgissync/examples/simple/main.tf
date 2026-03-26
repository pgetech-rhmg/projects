# required for sumologic provider
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "lmgissync" {
  count  = var.create_lmgissync ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    github      = github
    sumologic   = sumologic
  }

  prefix         = var.prefix
  git_branch     = var.git_branch
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
