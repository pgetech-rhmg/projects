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
module "ssm_fme_form_install_document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_fme_form_install_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm/install-configure-fme-form.yml")

  tags = merge(module.tags.tags, var.optional_tags)
}
