

# -----------------------------
# Render JSON templates
# -----------------------------
locals {
  hostingFileServer = base64encode(templatefile("${path.module}/templates/11.5/arcgis-server-fileserver.json.tpl", {
    run_as_user            = var.run_as_user
    hosting_fs_directories = jsonencode(var.hosting_fs_directories)
    hosting_fs_shares      = jsonencode(var.hosting_fs_shares)
  }))

  hostingServer = base64encode(templatefile("${path.module}/templates/11.5/arcgis-server.json.tpl", {
    esri_version                           = var.esri_version
    run_as_user                            = var.run_as_user
    hosting_archives                       = var.hosting_archives
    hosting_setups                         = var.hosting_setups
    hosting_hostname                       = var.hosting_hostname
    hosting_install_dir                    = var.hosting_install_dir
    hosting_admin_username                 = var.hosting_admin_username
    hosting_admin_password                 = local.hosting_admin_password
    hosting_authorization_file             = var.hosting_authorization_file
    hosting_log_dir                        = var.hosting_log_dir
    hosting_directories_root               = var.hosting_directories_root
    hosting_config_store_type              = var.hosting_config_store_type
    hosting_config_store_connection_string = var.hosting_config_store_connection_string
    hosting_web_context_url                = var.hosting_web_context_url
    hosting_keystore_file_path             = var.hosting_keystore_file_path
    hosting_keystore_file_password         = local.hosting_keystore_file_password
    hosting_cert_alias                     = var.hosting_cert_alias
    hosting_root_cert                      = var.hosting_root_cert
    hosting_root_cert_alias                = var.hosting_root_cert_alias
    hosting_wa_name                        = var.hosting_wa_name
  }))

  hosting_ssm_document_content = templatefile("${path.module}/ssm/hostingConfig.json.tpl", {
    hostingFileServer      = local.hostingFileServer
    hostingServer          = local.hostingServer
    s3_bucket              = var.s3_bucket
    hosting_certs_dir      = var.hosting_certs_dir
    hosting_pfx_cert_name  = var.hosting_pfx_cert_name
    hosting_root_cert_name = var.hosting_root_cert_name
    hosting_authorization_file    = var.hosting_authorization_file
    hosting_license_dir    = var.hosting_license_dir
    hosting_license_name   = var.hosting_license_name
    esri_version           = var.esri_version
    s3_region              = var.s3_region
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_hosting_ssm_document_content = templatefile("${path.module}/ssm/hostingConfig.json.tpl", {
    hostingFileServer = local.hostingFileServer
    hostingServer     = local.hostingServer

    # Mask sensitive fields
    hosting_admin_password         = "REDACTED"
    hosting_keystore_file_password = "REDACTED"

    s3_bucket              = var.s3_bucket
    hosting_certs_dir      = var.hosting_certs_dir
    hosting_pfx_cert_name  = var.hosting_pfx_cert_name
    hosting_root_cert_name = var.hosting_root_cert_name
    hosting_authorization_file    = var.hosting_authorization_file
    hosting_license_dir    = var.hosting_license_dir
    hosting_license_name   = var.hosting_license_name
    esri_version           = var.esri_version
    s3_region              = var.s3_region
  })
}

# Write debug JSON file locally
resource "local_file" "hosting_ssm_debug" {
  content  = local.debug_hosting_ssm_document_content
  filename = "${path.module}/debug_hosting_ssm.json"
}



# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "hosting_ssm" {
  name          = "arcgis-server-11.5-configure"
  document_type = "Command"
  content       = local.hosting_ssm_document_content
}

#resource "aws_ssm_association" "run_hostingConfig" {
#  name = aws_ssm_document.hosting_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.hosting_instance_id]
#  }
#
#  parameters = {
#    hostingFileServer = local.hostingFileServer
#    hostingServer     = local.hostingServer
#  }
#
#  wait_for_success_timeout_seconds = 7200
#
#}


