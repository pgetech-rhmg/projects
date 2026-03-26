/*
 * # AWS EC2 Module
 * Terraform module which creates SAF2.0 AWS EC2 instance
*/
#
#  Filename    : modules/ec2/main.tf
#  Date        : 7 Feb 2023
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : Creation of ec2 with golden ami. EBS will be encrypted with CMEK. RootBlock Device can be encrypted with AWS managed or CMEK. 
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

locals {
  namespace             = "ccoe-tf-developers"
  default_policy_arns   = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
  default_service       = ["ec2.amazonaws.com"]
  monitoring            = true
  name                  = var.name
  instance_profile_role = var.instance_profile_role != null ? var.instance_profile_role : module.aws_iam_role[0].name
  module_tags           = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}
data "aws_iam_role" "pge_linux_role" {
  name = local.instance_profile_role
}

locals {
  is_ebs_kms_null = anytrue(var.ebs_block_device != null ? [for bd in var.ebs_block_device : bd["kms_key_id"] == null] : [])
  is_rbd_kms_null = anytrue(var.root_block_device != null ? [for bd in var.root_block_device : bd["kms_key_id"] == null] : [])
}

# Validate that either subnet_id is provided or network_interface is configured
data "external" "validate_subnet_or_eni" {
  count   = var.subnet_id == null && length(var.network_interface) == 0 ? 1 : 0
  program = ["sh", "-c", ">&2 echo 'Either subnet_id must be provided or network_interface block must be configured'; exit 1"]
}

# Do not remove these data blocks, tflint will give the warning, but disregard.
data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && (local.is_ebs_kms_null || local.is_rbd_kms_null)) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "random_id" "ec2" {
  byte_length = 2
}

module "aws_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.0"
  count       = var.instance_profile_role == null ? 1 : 0
  name        = "instance_role_${local.name}_${random_id.ec2.id}"
  policy_arns = concat(local.default_policy_arns, var.policy_arns)
  aws_service = concat(local.default_service, var.aws_service)
  tags        = local.module_tags
}

resource "aws_iam_instance_profile" "this" {
  name = "instance_profile_${local.name}_${random_id.ec2.id}"
  role = local.instance_profile_role
  depends_on = [
    local.instance_profile_role

  ]
  tags = local.module_tags
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  hibernation                 = var.hibernation
  user_data_replace_on_change = var.user_data_replace_on_change

  availability_zone      = var.availability_zone
  subnet_id              = length(var.network_interface) > 0 ? null : var.subnet_id
  vpc_security_group_ids = length(var.network_interface) > 0 ? null : var.vpc_security_group_ids

  monitoring           = local.monitoring
  get_password_data    = var.get_password_data
  iam_instance_profile = aws_iam_instance_profile.this.id
  cpu_options {
    core_count       = var.cpu_core_count
    threads_per_core = var.cpu_threads_per_core
  }
  ebs_optimized = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = true
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = merge(lookup(root_block_device.value, "tags", null), local.module_tags)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = true
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      tags                  = merge(lookup(ebs_block_device.value, "tags", null), local.module_tags)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = "required"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.instance_metadata_tags
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id                 = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
          capacity_reservation_resource_group_arn = lookup(capacity_reservation_target.value, "capacity_reservation_resource_group_arn", null)
        }
      }
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", null)
    }
  }

  enclave_options {
    enabled = var.enclave_options_enabled
  }

  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  tenancy                              = var.tenancy
  host_id                              = var.host_id
  host_resource_group_arn              = var.host_resource_group_arn
  placement_group                      = var.placement_group
  placement_partition_number           = var.placement_partition_number

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  tags        = merge(local.module_tags, { Name = local.name })
  volume_tags = var.enable_volume_tags ? merge(var.volume_tags, { pge_team = local.namespace }) : null

  depends_on = [
    aws_iam_instance_profile.this,
  ]
}
