module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.app_id
  Environment        = var.environment
  DataClassification = var.data_classification
  CRIS               = var.cris
  Notify             = var.notify
  Owner              = var.owner
  Compliance         = var.compliance
  Order              = var.order
}

#####################################################
# Creating SSM-Document in YAML Format
#####################################################
module "fmecore-install-document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_fmecore_install_document_name
  ssm_document_type    = "Command"
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/windows/ssm-install-configure-fme-core-windows.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}

module "arcgis-server-install-document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_arcgis_server_install_document_name
  ssm_document_type    = "Command"
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/windows/ssm-configure-arcgis-server-windows.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}

module "fmeflow-automation-document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_fmeflow_automation_document_name
  ssm_document_type    = "Automation"
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/windows/ssm-install-arcgis-fme-core-automation.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}

module "fmeengine-install-document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_fmeengine_install_document_name
  ssm_document_type    = "Command"
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/windows/ssm-install-configure-fme-engine-windows.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}

module "arcgis-fme-engine-automation-document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_arcgis_fme_engine_automation_document_name
  ssm_document_type    = "Automation"
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/windows/ssm-install-arcgis-fme-engine-automation.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}
