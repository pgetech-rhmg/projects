data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "queries" {
  count  = var.create_queries ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    aws.default = aws
    aws.r53     = aws.tfcr53
    github      = github
    sumologic   = sumologic
  }

  region         = "us-west-2"
  suffix         = var.suffix
  prefix         = var.prefix
  git_branch     = var.queries_repo_branch
  workspace_name = var.workspace_name
  tags           = local.tags
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
