# The `cluster_service_cidr` is required when `create == true`
# This is a hacky way to make that logic work, otherwise Terraform always wants a value
# and supplying any old value like `""` or `null` is not valid and will silently
# fail to join nodes to the cluster
resource "null_resource" "validate_cluster_service_cidr" {
  lifecycle {
    precondition {
      # The length 6 is currently arbitrary, but it's a safe bet that the CIDR will be longer than that
      # The main point is that a value needs to be provided when `create = true`
      condition     = var.create ? length(var.cluster_service_cidr) > 6 : true
      error_message = "`cluster_service_cidr` is required when `create = true`."
    }
  }
}

locals {
  is_al2023 = startswith(var.ami_type, "AL2023_")

  # Converts AMI type into user data template path
  ami_type_to_user_data_path = {

    AL2023_x86_64_STANDARD = "${path.module}/al2023_user_data.tpl"
    AL2023_ARM_64_STANDARD = "${path.module}/al2023_user_data.tpl"
    AL2023_x86_64_NEURON   = "${path.module}/al2023_user_data.tpl"
    AL2023_x86_64_NVIDIA   = "${path.module}/al2023_user_data.tpl"
    AL2023_ARM_64_NVIDIA   = "${path.module}/al2023_user_data.tpl"

  }
  user_data_path = try(local.ami_type_to_user_data_path[var.ami_type])

  cluster_dns_ips = flatten(concat([try(cidrhost(var.cluster_service_cidr, 10), "")], var.additional_cluster_dns_ips))

  user_data = var.create ? base64encode(templatefile(local.user_data_path,
    {
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
      enable_bootstrap_user_data = var.enable_bootstrap_user_data

      # Required to bootstrap node
      cluster_name        = var.cluster_name
      cluster_endpoint    = var.cluster_endpoint
      cluster_auth_base64 = var.cluster_auth_base64

      cluster_service_cidr = var.cluster_service_cidr
      cluster_ip_family    = var.cluster_ip_family

      # Bottlerocket
      cluster_dns_ips = "[${join(", ", formatlist("\"%s\"", local.cluster_dns_ips))}]"

      # Optional
      bootstrap_extra_args     = var.bootstrap_extra_args
      pre_bootstrap_user_data  = var.pre_bootstrap_user_data
      post_bootstrap_user_data = var.post_bootstrap_user_data
    }
  )) : ""

  user_data_type_to_rendered = try(coalesce(
    local.is_al2023 ? try(data.cloudinit_config.al2023_eks_managed_node_group[0].rendered, local.user_data) : null,
    local.user_data,
  ), "")
}

locals {
  nodeadm_cloudinit = var.enable_bootstrap_user_data ? concat(
    var.cloudinit_pre_nodeadm,
    [{
      content_type = "application/node.eks.aws"
      content      = base64decode(local.user_data)
    }],
    var.cloudinit_post_nodeadm
  ) : var.cloudinit_pre_nodeadm
}

data "cloudinit_config" "al2023_eks_managed_node_group" {
  count = var.create && local.is_al2023 && length(local.nodeadm_cloudinit) > 0 ? 1 : 0

  base64_encode = true
  gzip          = false
  boundary      = "MIMEBOUNDARY"

  dynamic "part" {
    # Using the index is fine in this context since any change in user data will be a replacement
    for_each = { for i, v in local.nodeadm_cloudinit : i => v }

    content {
      content      = part.value.content
      content_type = try(part.value.content_type, null)
      filename     = try(part.value.filename, null)
      merge_type   = try(part.value.merge_type, null)
    }
  }
}