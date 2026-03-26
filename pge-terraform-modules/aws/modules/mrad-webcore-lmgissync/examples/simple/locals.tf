locals {
  app_id              = var.app_id
  environment         = var.environment
  data_classification = var.data_classification
  cris                = var.cris
  notify              = var.notify
  owner               = var.owner
  compliance          = var.compliance

  tags = merge(module.tags.tags, {
    "ProjectName" = var.project_name
    "Engage2586"  = "true"
  })
}
