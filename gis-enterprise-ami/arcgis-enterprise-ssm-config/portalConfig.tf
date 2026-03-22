


# -----------------------------
# Render JSON templates
# -----------------------------
locals {
  arcgisPortalFileServer = base64encode(templatefile("${path.module}/templates/11.5/arcgis-portal-fileserver.json.tpl", {
    esri_version          = var.esri_version
    run_as_user           = var.run_as_user
    portal_fs_directories = jsonencode(var.portal_fs_directories)
    portal_fs_shares      = jsonencode(var.portal_fs_shares)
  }))

  arcgisPortalPrimary = base64encode(templatefile("${path.module}/templates/11.5/arcgis-portal-primary.json.tpl", {
    esri_version                           = var.esri_version
    run_as_user                            = var.run_as_user
    portal_archives                        = var.portal_archives
    portal_setups                          = var.portal_setups
    portal_hostname                        = var.portal_hostname
    portal_hostidentifier                  = var.portal_hostidentifier
    portal_install_dir                     = var.portal_install_dir
    portal_admin_user                      = var.portal_admin_user
    portal_admin_password                  = local.portal_admin_password
    portal_admin_email                     = var.portal_admin_email
    portal_admin_fullname                  = var.portal_admin_fullname
    portal_admin_description               = var.portal_admin_description
    portal_security_question_index         = var.portal_security_question_index
    portal_security_question_answer        = local.portal_security_question_answer
    portal_logs_dir                        = var.portal_logs_dir
    portal_content_store_type              = var.portal_content_store_type
    portal_content_store_provider          = var.portal_content_store_provider
    portal_content_store_connection_string = var.portal_content_store_connection_string
    portal_authorization_file_path         = var.portal_authorization_file_path
    portal_user_license_type_id            = var.portal_user_license_type_id
    portal_keystore_file_path              = var.portal_keystore_file_path
    portal_keystore_file_password          = local.portal_keystore_file_password
    portal_cert_alias                      = var.portal_cert_alias
    portal_root_cert_path                  = var.portal_root_cert_path
    portal_root_cert_alias                 = var.portal_root_cert_alias
    portal_wa_name                         = var.portal_wa_name
    portal_system_properties               = jsonencode(var.portal_system_properties)
  }))

  portal_ssm_document_content = templatefile("${path.module}/ssm/portalConfig.json.tpl", {
    arcgisPortalFileServer = local.arcgisPortalFileServer
    arcgisPortalPrimary    = local.arcgisPortalPrimary
    s3_bucket              = var.s3_bucket
    portal_certs_dir       = var.portal_certs_dir
    portal_pfx_cert_name   = var.portal_pfx_cert_name
    portal_root_cert_name  = var.portal_root_cert_name
    portal_license_dir     = var.portal_license_dir
    portal_license_name    = var.portal_license_name
    esri_version           = var.esri_version
    s3_region              = var.s3_region
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_portal_ssm_document_content = templatefile("${path.module}/ssm/portalConfig.json.tpl", {
    arcgisPortalFileServer = local.arcgisPortalFileServer
    arcgisPortalPrimary    = local.arcgisPortalPrimary

    # Mask sensitive fields
    portal_admin_password           = "REDACTED"
    portal_security_question_answer = "REDACTED"
    portal_keystore_file_password   = "REDACTED"

    s3_bucket             = var.s3_bucket
    portal_certs_dir      = var.portal_certs_dir
    portal_pfx_cert_name  = var.portal_pfx_cert_name
    portal_root_cert_name = var.portal_root_cert_name
    portal_license_dir    = var.portal_license_dir
    portal_license_name   = var.portal_license_name
    esri_version          = var.esri_version
    s3_region             = var.s3_region
  })
}

# Write debug JSON file locally
resource "local_file" "portal_ssm_debug" {
  content  = local.debug_portal_ssm_document_content
  filename = "${path.module}/debug_portal_ssm.json"
}



# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "portal_ssm" {
  name          = "arcgis-portal-11.5-configure"
  document_type = "Command"
  content       = local.portal_ssm_document_content
}

#resource "aws_ssm_association" "run_portalConfig" {
#  name = aws_ssm_document.portal_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.portal_instance_id]
#  }

#  parameters = {
#    arcgisPortalFileServer = local.arcgisPortalFileServer
#    arcgisPortalPrimary    = local.arcgisPortalPrimary
#  }
#
#  wait_for_success_timeout_seconds = 7200
#
#}


