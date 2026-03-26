# required for sumologic provider
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "lmgisseed" {
  count  = var.create_lmgisseed ? 1 : 0
  source = "../../"

  providers = {
    aws       = aws
    github    = github
    sumologic = sumologic
  }

  prefix     = var.prefix
  git_branch = "dev"
  tags       = local.tags
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
