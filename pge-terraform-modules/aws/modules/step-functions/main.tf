/*
 * # AWS Step Functions State Machine 
 * Terraform module which creates SAF2.0 step functions state machine in AWS.
*/

#
#  Filename    : aws/modules/step_functions/main.tf
#  Date        : 14 Oct 2022
#  Author      : TCS
#  Description : Terraform module creates a step functions state machine 
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

data "external" "validate_kms" {  
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0  
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
  }

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#Provides a Step Functions state Machine resource
resource "aws_sfn_state_machine" "state_machine" {

  definition = var.state_machine_definition
  name       = var.state_machine_name
  role_arn   = var.state_machine_role_arn
  type       = var.state_machine_type
  publish    = var.publish
  tags       = local.module_tags

  #As per SAF rule #6 logging should be enabled (Ensure level is not set to OFF). 
  #So the log_destination is also required.
  logging_configuration {
    include_execution_data = var.include_execution_data
    level                  = var.level
    #The log_destination arn must end with :*
    log_destination = "${var.log_destination}:*"
  }

  encryption_configuration {
    kms_key_id                        = var.kms_key_id != " " ? var.kms_key_id : null
    type                              = var.kms_key_type
   
  }

  #Selects whether AWS X-Ray tracing is enabled.
  tracing_configuration {
    enabled = var.tracing_configuration_enabled
  }
}