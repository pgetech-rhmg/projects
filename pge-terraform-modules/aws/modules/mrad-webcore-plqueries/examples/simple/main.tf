module "pl_queries" {
  count  = var.create_queries_pipeline ? 1 : 0
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  # using a minimum of parameters, leaving the rest to be
  # discovered via data resources and AWS parameters+secrets
  repo_name   = var.queries_repo_name
  repo_org    = var.queries_repo_org
  git_branch  = var.git_branch
  target      = var.target_workspace
  prefix      = lower(var.prefix)
  suffix      = lower(var.suffix)
  node_env    = var.node_env
  tags        = local.tags
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
