/*
 * # AWS Transfer family workfloiw module.
 * Terraform module which creates SAF2.0 aws_transfer_workflow in AWS.
*/
#
#  Filename    : aws/modules/transfer-family/modules/transfer-workflow/main.tf
#  Date        : 13 September 2022
#  Author      : TCS
#  Description : Transfer family workflow Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_transfer_workflow" "transfer_workflow" {
  description = coalesce(var.description, "Transfer Workflow - Managed by Terraform")

  dynamic "on_exception_steps" {
    #The 'on_exception_steps' block is optional, can iterate multiple times if multiple values are passed for the variable 'on_exception_steps'.
    for_each = var.on_exception_steps
    content {
      type = on_exception_steps.value.type
      dynamic "copy_step_details" {
        # The below optional block will only run if valid values are provided for 'copy_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(on_exception_steps.value, "copy_step_details", {}) != {} ? [lookup(on_exception_steps.value, "copy_step_details", {})] : []
        content {
          dynamic "destination_file_location" {
            # The below optional block will only run if valid values are provided for 'destination_file_location' in the form of a'map' else this block will be skipped .
            for_each = lookup(copy_step_details.value, "destination_file_location", {}) != {} ? [lookup(copy_step_details.value, "destination_file_location", {})] : []
            content {

              dynamic "efs_file_location" {
                # The below optional block will only run if valid values are provided for 'efs_file_location' in the form of a'map' else this block will be skipped .
                for_each = lookup(destination_file_location.value, "efs_file_location", {}) != {} ? [lookup(destination_file_location.value, "efs_file_location", {})] : []
                content {
                  file_system_id = lookup(efs_file_location.value, "file_system_id", null)
                  path           = lookup(efs_file_location.value, "path", null)
                }
              }

              dynamic "s3_file_location" {
                # The below optional block will only run if valid values are provided for 's3_file_location' in the form of a'map' else this block will be skipped .
                for_each = lookup(destination_file_location.value, "s3_file_location", {}) != {} ? [lookup(destination_file_location.value, "s3_file_location", {})] : []
                content {
                  bucket = lookup(s3_file_location.value, "bucket", null)
                  key    = lookup(s3_file_location.value, "key", null)
                }
              }
            }
          }
          name                 = lookup(copy_step_details.value, "name", null)
          overwrite_existing   = lookup(copy_step_details.value, "overwrite_existing", "FALSE")
          source_file_location = lookup(copy_step_details.value, "source_file_location", null)
        }
      }

      dynamic "custom_step_details" {
        # The below optional block will only run if valid values are provided for 'custom_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(on_exception_steps.value, "custom_step_details", {}) != {} ? [lookup(on_exception_steps.value, "custom_step_details", {})] : []
        content {
          name                 = lookup(custom_step_details.value, "name", null)
          source_file_location = lookup(custom_step_details.value, "source_file_location", null)
          target               = lookup(custom_step_details.value, "target", null)
          timeout_seconds      = lookup(custom_step_details.value, "timeout_seconds", null)
        }
      }

      dynamic "delete_step_details" {
        # The below optional block will only run if valid values are provided for 'delete_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(on_exception_steps.value, "delete_step_details", {}) != {} ? [lookup(on_exception_steps.value, "delete_step_details", {})] : []
        content {
          name                 = lookup(delete_step_details.value, "name", null)
          source_file_location = lookup(delete_step_details.value, "source_file_location", null)
        }
      }

      dynamic "tag_step_details" {
        # The below optional block will only run if valid values are provided for 'tag_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(on_exception_steps.value, "tag_step_details", {}) != {} ? [lookup(on_exception_steps.value, "tag_step_details", {})] : []
        content {
          name                 = lookup(tag_step_details.value, "name", null)
          source_file_location = lookup(tag_step_details.value, "source_file_location", null)
          dynamic "tags" {
            for_each = lookup(tag_step_details.value, "tags", {})
            content {
              key   = tags.value.key
              value = tags.value.value
            }
          }
        }
      }
    }
  }

  dynamic "steps" {
    #The 'steps' block, can iterate multiple times if multiple values are passed for the variable 'steps'.
    for_each = var.steps
    content {
      type = steps.value.type
      dynamic "copy_step_details" {
        # The below optional block will only run if valid values are provided for 'copy_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(steps.value, "copy_step_details", {}) != {} ? [lookup(steps.value, "copy_step_details", {})] : []
        content {
          dynamic "destination_file_location" {
            # The below optional block will only run if valid values are provided for 'destination_file_location' in the form of a'map' else this block will be skipped .
            for_each = lookup(copy_step_details.value, "destination_file_location", {}) != {} ? [lookup(copy_step_details.value, "destination_file_location", {})] : []
            content {

              dynamic "efs_file_location" {
                # The below optional block will only run if valid values are provided for 'efs_file_location' in the form of a'map' else this block will be skipped .
                for_each = lookup(destination_file_location.value, "efs_file_location", {}) != {} ? [lookup(destination_file_location.value, "efs_file_location", {})] : []
                content {
                  file_system_id = lookup(efs_file_location.value, "file_system_id", null)
                  path           = lookup(efs_file_location.value, "path", null)
                }
              }

              dynamic "s3_file_location" {
                # The below optional block will only run if valid values are provided for 's3_file_location' in the form of a'map' else this block will be skipped .
                for_each = lookup(destination_file_location.value, "s3_file_location", {}) != {} ? [lookup(destination_file_location.value, "s3_file_location", {})] : []
                content {
                  bucket = lookup(s3_file_location.value, "bucket", null)
                  key    = lookup(s3_file_location.value, "key", null)
                }
              }
            }
          }
          name                 = lookup(copy_step_details.value, "name", null)
          overwrite_existing   = lookup(copy_step_details.value, "overwrite_existing", "FALSE")
          source_file_location = lookup(copy_step_details.value, "source_file_location", null)
        }
      }

      dynamic "custom_step_details" {
        # The below optional block will only run if valid values are provided for 'custom_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(steps.value, "custom_step_details", {}) != {} ? [lookup(steps.value, "custom_step_details", {})] : []
        content {
          name                 = lookup(custom_step_details.value, "name", null)
          source_file_location = lookup(custom_step_details.value, "source_file_location", null)
          target               = lookup(custom_step_details.value, "target", null)
          timeout_seconds      = lookup(custom_step_details.value, "timeout_seconds", null)
        }
      }

      dynamic "delete_step_details" {
        # The below optional block will only run if valid values are provided for 'delete_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(steps.value, "delete_step_details", {}) != {} ? [lookup(steps.value, "delete_step_details", {})] : []
        content {
          name                 = lookup(delete_step_details.value, "name", null)
          source_file_location = lookup(delete_step_details.value, "source_file_location", null)
        }
      }

      dynamic "tag_step_details" {
        # The below optional block will only run if valid values are provided for 'tag_step_details' in the form of a'map' else this block will be skipped .
        for_each = lookup(steps.value, "tag_step_details", {}) != {} ? [lookup(steps.value, "tag_step_details", {})] : []
        content {
          name                 = lookup(tag_step_details.value, "name", null)
          source_file_location = lookup(tag_step_details.value, "source_file_location", null)
          dynamic "tags" {
            for_each = lookup(tag_step_details.value, "tags", {})
            content {
              key   = tags.value.key
              value = tags.value.value
            }
          }
        }
      }
    }
  }
  tags = local.module_tags
}