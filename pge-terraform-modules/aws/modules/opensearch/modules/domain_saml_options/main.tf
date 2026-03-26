/*
* # AWS Opensearch domain_saml_options module
* Terraform module which creates domain_saml_options for Opensearch Domain 
*/
#Filename     : aws/modules/opensearch/modules/domain_saml_options/main.tf 
#Date         : 23 Apr 2024
#Author      : PGE
#Description  : Terraform module for creation of SAML options for opensearch Domain

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_opensearch_domain_saml_options" "saml" {
  domain_name = var.domain_name

  dynamic "saml_options" {
    for_each = try(var.saml_options, {})

    content {
      enabled                 = try(saml_options.value.saml_enabled, false)
      master_backend_role     = try(saml_options.value.master_backend_role, null)
      master_user_name        = try(saml_options.value.master_user_name, null)
      session_timeout_minutes = try(saml_options.value.session_timeout_minutes, 60)
      subject_key             = try(saml_options.value.subject_key, null)
      roles_key               = try(saml_options.value.roles_key, null)

      dynamic "idp" {
        for_each = try(saml_options.value.idp, {})

        content {
          entity_id        = try(idp.value["entity_id"], null)
          metadata_content = var.metadata_content_file
        }
      }
    }
  }
}