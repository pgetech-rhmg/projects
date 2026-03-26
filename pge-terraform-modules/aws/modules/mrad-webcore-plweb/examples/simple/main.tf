module "pl_webapp" {
  count  = var.create_webapp_pipeline ? 1 : 0
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  # target_workspace is used to construct the path to the SSM Parameters
  # Example: target_workspace = predevinfra
  #          /webcore/webapp/predevinfra/bucket
  #          /webcore/webapp/predevinfra/cloudfront_id
  target      = var.target_workspace
  suffix      = var.suffix
  repo_name   = var.webapp_repo_name
  repo_org    = var.webapp_repo_org
  repo_branch = var.webapp_repo_branch
  tags        = module.tags.tags
  pilot       = false
}

module "pl_viewer" {
  count  = var.create_viewer_pipeline ? 1 : 0
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  target      = var.target_workspace
  suffix      = var.suffix
  repo_name   = var.viewer_repo_name
  repo_org    = var.viewer_repo_org
  repo_branch = var.viewer_repo_branch
  tags        = module.tags.tags
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
