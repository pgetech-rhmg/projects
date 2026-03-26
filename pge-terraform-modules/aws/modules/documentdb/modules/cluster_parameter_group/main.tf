/*
* AWS DocumentDB module
* Terraform module which creates cluster parameter group
*/
# Filename     : aws/modules/documentdb/modules/cluster_parameter_group/main.tf 
# Date         : 01 August 2022
# Author       : TCS
# Description  : The terraform module for creation of Cluster_parameter_group
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module : DocumentDB
# Description : This terraform module creates cluster_parameter_group

locals {
  namespace = "ccoe-tf-developers"
}

# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_docdb_cluster_parameter_group" "docdb_cluster_parameter_group" {
  family      = var.docdb_cluster_parameter_group_family
  name        = var.docdb_cluster_parameter_group_name
  description = coalesce(var.docdb_cluster_parameter_group_description, format("%s cluster parameter group - Managed by Terraform", var.docdb_cluster_parameter_group_name))

  # Hardcoded values as per SAF rule #3
  parameter {
    name  = "audit_logs"
    value = "enabled"
  }

  # Hardcoded values as per SAF rule #6
  parameter {
    name  = "tls"
    value = "enabled"

    /*apply_method cannot be immediate for static parameter
      When you change a static parameter and save the cluster parameter group, 
      the parameter change takes effect after you manually reboot the DB instance. */
    apply_method = "pending-reboot"
  }

  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value

      #If the user is not giving any value for the argument 'apply_method', then the argument takes the default value 'pending-reboot'
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
    }
  }

  tags = local.module_tags
}