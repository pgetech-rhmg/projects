/*
 * # AWS eks cluster with  managed node group creation
 * This module will create eks and  managed groups.
*/
# Filename     : eks-modules/aws/modules/eks/modules/eks-nodegroup/main.tf
#  Date        : 26 july 2022
#  Author      : TekYantra
#  Description : eks-node group creation

################################################################################
# KMS Key for EKS Cluster Encryption
################################################################################

# Additional KMS key policy for EKS Auto Mode EBS encryption
data "aws_iam_policy_document" "kms_auto_mode" {
  count = var.aws_kms_key_arn == null && local.auto_mode_enabled ? 1 : 0

  # CreateGrant needs the condition for AWS services (EBS)
  statement {
    sid    = "Allow EKS Auto Mode to create grants for EBS encryption"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.auto[0].arn,
        aws_iam_role.eks_auto_node_role[0].arn
      ]
    }
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  # Direct KMS operations need NO condition for Auto Mode to work
  statement {
    sid    = "Allow EKS Auto Mode direct access to KMS key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.auto[0].arn,
        aws_iam_role.eks_auto_node_role[0].arn
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }
}

module "kms" {
  count   = var.aws_kms_key_arn == null ? 1 : 0
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.4"

  name     = "${var.cluster_name}-eks-encryption"
  aws_role = var.aws_role
  kms_role = var.kms_role
  policy   = local.auto_mode_enabled ? data.aws_iam_policy_document.kms_auto_mode[0].json : "{}"
  tags     = var.tags
}

################################################################################
# IAM Role for EKS Cluster
################################################################################

/* IAM Role for EKS Cluster */
module "aws_iam_role" {
  count       = !local.auto_mode_enabled ? 1 : 0
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = join("-", [var.cluster_name, "eksservice-role"]) # this is how you can gernerate unique names all the times based on the clustername
  aws_service = var.role_service                                 #default
  tags        = merge(local.module_tags, { Name = join("-", [var.cluster_name, "eksservice-role"]) })
  #AWS_Managed_Policy
  policy_arns = distinct(concat(local.default_policy_arns, var.policy_arns))
}

resource "aws_security_group_rule" "cluster_security_group_ingress_rule1" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description       = join("-", [var.cluster_name, "pge-in", "Allow unmanaged nodes to communicate with control plane (443)"])
}

module "security_group" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  name        = join("-", [var.cluster_name, "additional-sg"])
  description = "Security group for usage with VPC Endpoint"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  tags        = local.module_tags
}


#### Eks Cluster Creation ########
resource "aws_eks_cluster" "eks_cluster" {
  name                          = var.cluster_name
  version                       = var.k8s-version
  role_arn                      = local.auto_mode_enabled ? aws_iam_role.auto[0].arn : module.aws_iam_role[0].arn
  enabled_cluster_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  bootstrap_self_managed_addons = local.auto_mode_enabled ? false : var.bootstrap_self_managed_addons
  tags                          = local.module_tags

  dynamic "upgrade_policy" {
    for_each = length(var.cluster_upgrade_policy) > 0 ? [var.cluster_upgrade_policy] : []

    content {
      support_type = try(upgrade_policy.value.support_type, null)
    }
  }

  dynamic "kubernetes_network_config" {
    # service_ipv4_cidr = var.cluster_service_ipv4_cidr
    for_each = local.auto_mode_enabled ? [1] : []
    content {
      elastic_load_balancing {
        enabled = true
      }
    }
  }

  dynamic "storage_config" {
    for_each = local.auto_mode_enabled ? [1] : []

    content {
      block_storage {
        enabled = true
      }
    }
  }

  dynamic "encryption_config" {
    # Not available on Outposts
    for_each = local.enable_cluster_encryption_config ? [var.cluster_encryption_config] : []

    content {
      provider {
        key_arn = try(encryption_config.value.provider_key_arn, local.kms_key_arn)
      }
      resources = try(encryption_config.value.resources, [])
    }
  }

  dynamic "compute_config" {
    for_each = length(var.cluster_compute_config) > 0 ? [var.cluster_compute_config] : []

    content {
      enabled       = local.auto_mode_enabled
      node_pools    = local.auto_mode_enabled ? try(compute_config.value.node_pools, []) : null
      node_role_arn = local.auto_mode_enabled && length(try(compute_config.value.node_pools, [])) > 0 ? try(compute_config.value.node_role_arn, aws_iam_role.eks_auto_node_role[0].arn, null) : null
    }
  }

  vpc_config {
    security_group_ids      = [module.security_group.sg_id]
    subnet_ids              = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = false
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false # force users to use explicit access_entries
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
    update = var.cluster_update_timeout
  }
}

locals {
  partition         = data.aws_partition.current.partition
  create            = true
  auto_mode_enabled = try(var.cluster_compute_config.enabled, false)
}

################################################################################
# Access Entry
################################################################################
locals {
  # Flatten out entries and policy associations so users can specify the policy
  # associations within a single entry
  flattened_access_entries = flatten([
    for entry_key, entry_val in local.combined_roles : [
      for pol_key, pol_val in lookup(entry_val, "policy_associations", {}) :
      merge(
        {
          principal_arn = entry_val.principal_arn
          entry_key     = entry_key
          pol_key       = pol_key
        },
        { for k, v in {
          association_policy_arn              = pol_val.policy_arn
          association_access_scope_type       = pol_val.access_scope.type
          association_access_scope_namespaces = lookup(pol_val.access_scope, "namespaces", [])
        } : k => v if !contains(["EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX"], lookup(entry_val, "type", "STANDARD")) },
      )
    ]
  ])
}

resource "aws_eks_access_entry" "eks_access_entry_codebuild" {
  principal_arn = module.bootstrap.codebuild_iam_role_arn
  cluster_name  = aws_eks_cluster.eks_cluster.name

  kubernetes_groups = ["cluster-admins"]
  type              = "STANDARD"
  tags              = local.module_tags
}

resource "aws_eks_access_policy_association" "eks_access_policy_association_codebuild" {
  principal_arn = module.bootstrap.codebuild_iam_role_arn
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "this" {
  for_each = { for k, v in local.combined_roles : k => v if true }

  cluster_name      = aws_eks_cluster.eks_cluster.name
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for k, v in local.flattened_access_entries : "${v.entry_key}_${v.pol_key}" => v if true }

  access_scope {
    namespaces = try(each.value.association_access_scope_namespaces, [])
    type       = each.value.association_access_scope_type
  }

  cluster_name = aws_eks_cluster.eks_cluster.name

  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.this,
  ]
}

## IAM role for NodeGroup  ###
module "aws_iam" {
  count       = !local.auto_mode_enabled ? 1 : 0
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = join("-", [var.cluster_name, "workernode-role"])
  aws_service = var.role_service_managed
  tags        = merge(local.module_tags, { pge_team = local.namespace }, { Name = join("-", [var.cluster_name, "workernode-role"]) })
  #AWS_Managed_Policy
  policy_arns = distinct(concat(local.eks_arns, var.policy_arns))
}

###EKS Managed node group #####
resource "aws_eks_node_group" "eks-nodegroup" {
  for_each = { for k, v in var.eks_managed_node_groups : k => v if !local.auto_mode_enabled }

  # Required
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_role_arn = local.auto_mode_enabled ? aws_iam_role.eks_auto_node_role[0].arn : module.aws_iam[0].arn
  subnet_ids    = each.value.subnet_ids

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  # EKS Managed Node Group
  node_group_name = try(each.value.name, each.key)

  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types


  dynamic "launch_template" {
    for_each = !local.auto_mode_enabled && each.value.use_custom_launch_template ? [1] : []

    content {
      id      = try(local.launch_template_id, null)
      version = try(local.launch_template_version, null)
    }
  }

  dynamic "taint" {
    for_each = { for t in coalesce(each.value.taints, []) : join(":", [t.key, coalesce(t.value, "null"), t.effect]) => t }
    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }
  labels = each.value.labels
  update_config {
    max_unavailable_percentage = 33
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }
  tags = local.module_tags
}

################################################################################
# EKS Addons
################################################################################

data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_addons : k => v if local.create }

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = coalesce(var.k8s-version, aws_eks_cluster.eks_cluster.version)
  most_recent        = try(each.value.most_recent, null)
}

resource "aws_eks_addon" "this" {
  # Not supported on outposts
  for_each = { for k, v in var.cluster_addons : k => v if !try(v.before_compute, false) && local.create }

  cluster_name = aws_eks_cluster.eks_cluster.id
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(jsonencode(each.value.configuration_values), null)
  preserve                    = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  depends_on = [aws_eks_node_group.eks-nodegroup]

  tags = merge(var.tags, local.module_tags)
}

resource "aws_eks_addon" "before_compute" {
  # Not supported on outposts
  for_each = { for k, v in var.cluster_addons : k => v if try(v.before_compute, false) && local.create }

  cluster_name = aws_eks_cluster.eks_cluster.id
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(jsonencode(each.value.configuration_values), null)
  preserve                    = try(each.value.preserve, true)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  tags = merge(var.tags, local.module_tags)
}

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"
  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name               = local.acm_domain_name
  acm_subject_alternative_names = [local.acm_domain_name, local.promethus_domain_name, local.grafana_domain_name, local.argocd_domain_name, local.opencostui_domain_name]
  tags                          = merge(local.module_tags, { Name = join("-", [var.cluster_name, "cert"]) })
}

module "bootstrap" {
  source              = "./modules/internal/bootstrap/"
  cluster_name        = aws_eks_cluster.eks_cluster.name
  cluster_endpoint    = aws_eks_cluster.eks_cluster.endpoint
  tags                = merge(var.tags, local.module_tags)
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  acm_certificate_arn = module.acm_public_certificate.acm_certificate_arn
  account_num         = var.account_num
  account_num_r53     = var.account_num_r53
  hosted_zone         = var.hosted_zone
  aws_r53_role        = var.aws_r53_role
  codebuild_git_auth  = var.codebuild_git_auth
  argocd_git_auth     = var.argocd_git_auth
  custom_repo_url     = var.custom_repo_url
  custom_repo_branch  = var.custom_repo_branch
  auto_mode_enabled   = local.auto_mode_enabled
}
