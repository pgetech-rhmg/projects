###############################################################################
# MODULE 1 — TAGS
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-tags.git?ref=main"

  subscription_id    = var.subscription_id
  environment        = var.environment
  appid              = var.appid
  notify             = var.notify
  owner              = var.owner
  order              = var.order
  dataclassification = var.dataclassification
  compliance         = var.compliance
  cris               = var.cris
}

###############################################################################
# MODULE 2 — APP SERVICE (PHP)
###############################################################################

module "app_service" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-app-service.git?ref=main"

  resource_group_name = var.resource_group_name
  azure_region        = var.azure_region

  service_plan_name = var.service_plan_name
  app_name          = "${var.app_name}-${var.environment}"

  runtime         = "php"
  runtime_version = var.runtime_version
  sku_name        = var.sku_name

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
  }

  tags = module.tags.tags
}
