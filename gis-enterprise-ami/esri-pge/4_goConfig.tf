

# -----------------------------
# Render JSON templates
# -----------------------------
locals {
  goFileServer = base64encode(templatefile("${path.module}/templates/6_go-server-fileserver.json.tpl", {
    run_as_user       = var.run_as_user
    go_fs_directories = jsonencode(var.go_fs_directories)
    go_fs_shares      = jsonencode(var.go_fs_shares)
  }))

  goServer = base64encode(templatefile("${path.module}/templates/7_go-server.json.tpl", {
    esri_version                      = var.esri_version
    run_as_user                       = var.run_as_user
    go_archives                       = var.go_archives
    go_setups                         = var.go_setups
    go_hostname                       = var.go_hostname
    go_install_dir                    = var.go_install_dir
    go_admin_username                 = var.go_admin_username
    go_admin_password                 = local.go_admin_password
    go_authorization_file             = var.go_authorization_file
    go_log_dir                        = var.go_log_dir
    go_directories_root               = var.go_directories_root
    go_config_store_type              = var.go_config_store_type
    go_config_store_connection_string = var.go_config_store_connection_string
    go_web_context_url                = var.go_web_context_url
    go_keystore_file_path             = var.go_keystore_file_path
    go_keystore_file_password         = local.go_keystore_file_password
    go_cert_alias                     = var.go_cert_alias
    go_root_cert                      = var.go_root_cert
    go_root_cert_alias                = var.go_root_cert_alias
    go_wa_name                        = var.go_wa_name
  }))

  go_ssm_document_content = templatefile("${path.module}/ssm/4_goConfig.json.tpl", {
    goFileServer      = local.goFileServer
    goServer          = local.goServer
    s3_bucket         = var.s3_bucket
    go_certs_dir      = var.go_certs_dir
    go_pfx_cert_name  = var.go_pfx_cert_name
    go_root_cert_name = var.go_root_cert_name
    go_authorization_file    = var.go_authorization_file
    go_license_dir    = var.go_license_dir
    go_license_name   = var.go_license_name
    esri_version      = var.esri_version
    s3_region         = var.s3_region
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_go_ssm_document_content = templatefile("${path.module}/ssm/4_goConfig.json.tpl", {
    goFileServer = local.goFileServer
    goServer     = local.goServer

    # Mask sensitive fields
    go_admin_password         = "REDACTED"
    go_keystore_file_password = "REDACTED"

    s3_bucket         = var.s3_bucket
    go_certs_dir      = var.go_certs_dir
    go_pfx_cert_name  = var.go_pfx_cert_name
    go_root_cert_name = var.go_root_cert_name
    go_authorization_file    = var.go_authorization_file
    go_license_dir    = var.go_license_dir
    go_license_name   = var.go_license_name
    esri_version      = var.esri_version
    s3_region         = var.s3_region
  })
}

# Write debug JSON file locally
resource "local_file" "go_ssm_debug" {
  content  = local.debug_go_ssm_document_content
  filename = "${path.module}/debug_go_ssm.json"
}




# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "go_ssm" {
  name          = "GoSSM"
  document_type = "Command"
  content       = local.go_ssm_document_content
}

#resource "aws_ssm_association" "run_goConfig" {
#  name = aws_ssm_document.go_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.go_instance_id]
#  }
#
#  parameters = {
#    goFileServer = local.goFileServer
#    goServer     = local.goServer
#  }
#
# wait_for_success_timeout_seconds = 7200
#
#}


