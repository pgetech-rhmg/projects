module "pl_nlbman" {
  count  = var.create_nlbman_pipeline ? 1 : 0
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  repo_name    = "Engage-NLB-Manager"
  tags         = module.tags.tags
  repo_branch  = "dev"
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
