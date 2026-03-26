#
# Filename    : modules/mrad-webcore-queries/main.tf
# Date        : 2024-04-16
# Author      : ENGAGE (engageteam@pge.onmicrosoft.com)
# Description : This terraform module creates an instance of Engage-Queries
#

module "queries_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.0"
  name    = "/aws/ecs/${local.queries_resource_name}"
  tags    = var.tags
}

module "queries_sumo" {
  source           = "app.terraform.io/pgetech/mrad-sumo/aws"
  version          = "0.0.11"
  http_source_name = "sumo-${local.queries_resource_name}"
  aws_account      = local.envname
  aws_role         = "MRAD_Ops"
  tags             = var.tags
  filter_pattern   = ""
  log_group_name   = module.queries_logs.cloudwatch_log_group_name
  # disambiguator below needs to be unique per-account, therefore include the Lambda short name
  disambiguator    = "${local.queries_resource_name}"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = local.git_branch
}
