

# -----------------------------
# Render JSON templates
# -----------------------------
locals {
  hostingFederation = base64encode(templatefile("${path.module}/templates/11_hosting-server-federation.json.tpl", {
    hosting_server_url      = var.hosting_server_url
    hosting_web_context_url = var.hosting_web_context_url
    hosting_admin_username  = var.hosting_admin_username
    hosting_admin_password  = local.hosting_admin_password
    portal_private_url      = var.portal_private_url
    portal_admin_user       = var.portal_admin_user
    portal_admin_password   = local.portal_admin_password
    portal_root_cert_path   = var.portal_root_cert_path
    portal_root_cert_alias  = var.portal_root_cert_alias
  }))

  goFederation = base64encode(templatefile("${path.module}/templates/12_go-server-federation.json.tpl", {
    go_server_url          = var.go_server_url
    go_web_context_url     = var.go_web_context_url
    go_admin_username      = var.go_admin_username
    go_admin_password      = local.go_admin_password
    portal_private_url     = var.portal_private_url
    portal_admin_user      = var.portal_admin_user
    portal_admin_password  = local.portal_admin_password
    portal_root_cert_path  = var.portal_root_cert_path
    portal_root_cert_alias = var.portal_root_cert_alias
  }))

  federation_ssm_document_content = templatefile("${path.module}/ssm/6_federationConfig.json.tpl", {
    hostingFederation = local.hostingFederation
    goFederation      = local.goFederation
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_federation_ssm_document_content = templatefile("${path.module}/ssm/6_federationConfig.json.tpl", {
    hostingFederation = local.hostingFederation
    goFederation      = local.goFederation

    # Mask sensitive fields
    hosting_admin_password = "REDACTED"
    go_admin_password      = "REDACTED"

  })
}

# Write debug JSON file locally
resource "local_file" "federation_ssm_debug" {
  content  = local.debug_federation_ssm_document_content
  filename = "${path.module}/debug_federation_ssm.json"
}



# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "federation_ssm" {
  name          = "FederationSSM"
  document_type = "Command"
  content       = local.federation_ssm_document_content
}

#resource "aws_ssm_association" "run_federationConfig" {
#  name = aws_ssm_document.federation_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.portal_instance_id]
#  }
#
#  parameters = {
#    hostingFederation = local.hostingFederation
#    goFederation      = local.goFederation
#  }
#
#  wait_for_success_timeout_seconds = 7200
#
#}


