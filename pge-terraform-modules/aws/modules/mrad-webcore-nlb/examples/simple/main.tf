# required for sumologic provider
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

module "nlb" {
  count  = var.create_nlb ? 1 : 0
  source = "../../"

  providers = {
    aws         = aws
    aws.r53     = aws.tfcr53
    github      = github
    sumologic   = sumologic
  }

  prefix         = "engagetest"
  repo_branch    = var.repo_branch
  suffix         = "test"
  tags           = local.tags
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

output "nlb_dns_name_rw" {
  value = module.nlb[0].nlb_dns_name_rw
}

output "nlb_dns_name_ro" {
  value = module.nlb[0].nlb_dns_name_ro
}
