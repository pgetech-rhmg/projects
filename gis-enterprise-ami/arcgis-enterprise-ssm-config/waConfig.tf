

# -----------------------------
# Render JSON templates
# -----------------------------

locals {
  portalWa = base64encode(templatefile("${path.module}/templates/11.5/arcgis-portal-webadaptor.json.tpl", {
    tomcat_keystore_file     = var.tomcat_keystore_file
    tomcat_keystore_password = local.tomcat_keystore_password
    esri_version             = var.esri_version
    run_as_user              = var.run_as_user
    wa_archives              = var.wa_archives
    wa_setups                = var.wa_setups
    wa_webapp_dir            = var.wa_webapp_dir
    portal_private_url       = var.portal_private_url
    wa_portal_url            = var.wa_portal_url
    portal_admin_user        = var.portal_admin_user
    portal_admin_password    = local.portal_admin_password
    portal_wa_name           = var.portal_wa_name
    wa_install_dir           = var.wa_install_dir
  }))

  hostingServerWa = base64encode(templatefile("${path.module}/templates/11.5/arcgis-server-webadaptor.json.tpl", {
    tomcat_keystore_file     = var.tomcat_keystore_file
    tomcat_keystore_password = local.tomcat_keystore_password
    esri_version             = var.esri_version
    run_as_user              = var.run_as_user
    wa_archives              = var.wa_archives
    wa_setups                = var.wa_setups
    wa_webapp_dir            = var.wa_webapp_dir
    hosting_server_url       = var.hosting_server_url
    wa_hosting_server_url    = var.wa_hosting_server_url
    hosting_admin_username   = var.hosting_admin_username
    hosting_admin_password   = local.hosting_admin_password
    hosting_wa_name          = var.hosting_wa_name
    wa_install_dir           = var.wa_install_dir
  }))


  wa_ssm_document_content = templatefile("${path.module}/ssm/waConfig.json.tpl", {
    portalWa             = local.portalWa
    hostingServerWa      = local.hostingServerWa
    tomcat_keystore_file = var.tomcat_keystore_file
    s3_bucket            = var.s3_bucket
    esri_version         = var.esri_version
    s3_region            = var.s3_region
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_wa_ssm_document_content = templatefile("${path.module}/ssm/waConfig.json.tpl", {
    portalWa        = local.portalWa
    hostingServerWa = local.hostingServerWa

    # Mask sensitive fields
    portal_admin_password    = "REDACTED"
    hosting_admin_password   = "REDACTED"
    tomcat_keystore_password = "REDACTED"

    tomcat_keystore_file = var.tomcat_keystore_file
    s3_bucket            = var.s3_bucket
    esri_version         = var.esri_version
    s3_region            = var.s3_region
  })
}

# Write debug JSON file locally
resource "local_file" "wa_ssm_debug" {
  content  = local.debug_wa_ssm_document_content
  filename = "${path.module}/debug_wa_ssm.json"
}


# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "wa_ssm" {
  name          = "arcgis-webadaptor-11.5-configure"
  document_type = "Command"
  content       = local.wa_ssm_document_content
}

#resource "aws_ssm_association" "run_waConfig" {
# name = aws_ssm_document.wa_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.webadaptor_instance_id]
#  }
#
#  parameters = {
#    portalWa        = local.portalWa
#    hostingServerWa = local.hostingServerWa
#  }
#
#  wait_for_success_timeout_seconds = 7200
#
#}


