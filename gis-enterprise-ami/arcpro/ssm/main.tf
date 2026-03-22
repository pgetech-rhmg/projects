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
module "ssm_arcpro_install_document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_arcpro_install_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = templatefile("${path.module}/templates/arcgis-pro-install.yml.tpl", {

    ArcProLicenseFile  = var.arcgis_pro_license_file
    PortalLicenseURL   = var.portal_license_url
    PortalList         = var.portal_list

  })

  tags = module.tags.tags
}

module "ssm_arcpro_patch_install_document" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_arcpro_patch_install_document_name
  ssm_document_type    = var.ssm_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/arcgis-pro-patch-install.yml")

  tags = module.tags.tags
}
