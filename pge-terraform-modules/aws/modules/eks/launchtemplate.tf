################################################################################
# User Data
################################################################################

module "user_data" {
  source = "./user-data"
  count  = local.auto_mode_enabled ? 0 : 1

  create   = var.create
  ami_type = try(var.eks_managed_node_groups[var.selected_nodegroup].ami_type, "")

  cluster_name        = aws_eks_cluster.eks_cluster.name
  cluster_endpoint    = aws_eks_cluster.eks_cluster.endpoint
  cluster_auth_base64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data

  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  enable_bootstrap_user_data = try(var.eks_managed_node_groups[var.selected_nodegroup].enable_bootstrap_user_data, false)
  pre_bootstrap_user_data    = try(var.eks_managed_node_groups[var.selected_nodegroup].pre_bootstrap_user_data, "")
  post_bootstrap_user_data   = try(var.eks_managed_node_groups[var.selected_nodegroup].post_bootstrap_user_data, "")
  bootstrap_extra_args       = try(var.eks_managed_node_groups[var.selected_nodegroup].bootstrap_extra_args, "")

  cloudinit_pre_nodeadm  = try(var.eks_managed_node_groups[var.selected_nodegroup].cloudinit_pre_nodeadm, [])
  cloudinit_post_nodeadm = try(var.eks_managed_node_groups[var.selected_nodegroup].cloudinit_post_nodeadm, [])
}

################################################################################
# Launch template
################################################################################

locals {
  launch_template_name = coalesce(var.launch_template_name, "${var.name}-eks-node-group")
}

resource "aws_launch_template" "this" {


  dynamic "block_device_mappings" {
    for_each = try(var.eks_managed_node_groups.launch_template_nodegroup.block_device_mappings, {})

    content {
      device_name = block_device_mappings.value.device_name

      dynamic "ebs" {
        for_each = try([block_device_mappings.value.ebs], [])

        content {
          delete_on_termination = ebs.value.delete_on_termination
          volume_size           = ebs.value.volume_size

        }
      }

    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      interface_type               = lookup(network_interfaces.value, "interface_type", null)
      ipv4_addresses               = try(network_interfaces.value.ipv4_addresses, [])
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = try(network_interfaces.value.ipv6_addresses, [])
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null)
      subnet_id                    = try(network_interfaces.value.subnet_id, null)
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }


  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []

    content {
      core_count       = try(cpu_options.value.core_count, null)
      threads_per_core = try(cpu_options.value.threads_per_core, null)
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }

  default_version         = var.launch_template_default_version
  description             = var.launch_template_description
  disable_api_stop        = true
  disable_api_termination = true
  ebs_optimized           = true



  kernel_id = var.kernel_id

  metadata_options {

    http_endpoint = "enabled"
    #the following two configuration are fixing https://github.com/aws/containers-roadmap/issues/1060 
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  name        = var.launch_template_use_name_prefix ? null : local.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${local.launch_template_name}-" : null
  ram_disk_id = null

  update_default_version = var.update_launch_template_default_version
  user_data              = !local.auto_mode_enabled ? module.user_data[0].user_data : null
  vpc_security_group_ids = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]

  tags = local.module_tags
  lifecycle {
    create_before_destroy = true
  }
}
