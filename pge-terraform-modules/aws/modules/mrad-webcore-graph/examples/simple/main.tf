module "graph" {
  count  = var.create_graph ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    aws.default = aws
    aws.r53     = aws.tfcr53
    github      = github
    sumologic   = sumologic
  }

  suffix         = var.suffix
  prefix         = var.prefix
  repo_branch    = var.repo_branch
  workspace_name = var.workspace_name
  tags           = local.tags
  aws_role       = "Engage_Ops"
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

data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}
