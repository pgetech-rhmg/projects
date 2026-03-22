module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#####################################################
# Creating SSM-Document in YAML Format 
#####################################################
module "ssm_configure_webadaptor" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_webadaptor_config_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm-configure-webadaptor.yml")

  tags = module.tags.tags
}

module "ssm_install_webadaptor" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_webadaptor_install_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm-install-configure-webadaptor.yml")

  tags = module.tags.tags
}