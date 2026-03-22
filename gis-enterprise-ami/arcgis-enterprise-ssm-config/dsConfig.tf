
# -----------------------------
# Render JSON templates
# -----------------------------
locals {

  dataStore = base64encode(templatefile("${path.module}/templates/11.5/arcgis-datastore-primary.json.tpl", {
    esri_version                  = var.esri_version
    run_as_user                   = var.run_as_user
    ds_archives                   = var.ds_archives
    ds_setups                     = var.ds_setups
    ds_hostidentifier             = var.ds_hostidentifier
    ds_install_dir                = var.ds_install_dir
    hosting_admin_username        = var.hosting_admin_username
    hosting_admin_password        = local.hosting_admin_password
    hosting_server_url            = var.hosting_server_url
    ds_data_dir                   = var.ds_data_dir
    ds_relational_backup_location = var.ds_relational_backup_location
    ds_object_backup_location     = var.ds_object_backup_location
  }))

  ds_ssm_document_content = templatefile("${path.module}/ssm/dsConfig.json.tpl", {
    dataStore = local.dataStore
    s3_bucket = var.s3_bucket
  })
}

# -----------------------------
# Debug-friendly SSM document
# -----------------------------
locals {
  debug_ds_ssm_document_content = templatefile("${path.module}/ssm/dsConfig.json.tpl", {
    dataStore = local.dataStore
    s3_bucket = var.s3_bucket

    # Mask sensitive fields
    hosting_admin_password = "REDACTED"
  })
}

# Write debug JSON file locally
resource "local_file" "ds_ssm_debug" {
  content  = local.debug_ds_ssm_document_content
  filename = "${path.module}/debug_ds_ssm.json"
}




# -----------------------------
# SSM Document
# -----------------------------
resource "aws_ssm_document" "ds_ssm" {
  name          = "arcgis-datastore-11.5-configure"
  document_type = "Command"
  content       = local.ds_ssm_document_content
}

#resource "aws_ssm_association" "run_dsConfig" {
#  name = aws_ssm_document.ds_ssm.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [var.datastore_instance_id]
#  }
#
#  parameters = {
#    dataStore = local.dataStore
#  }
#
#  wait_for_success_timeout_seconds = 7200
#
#}


