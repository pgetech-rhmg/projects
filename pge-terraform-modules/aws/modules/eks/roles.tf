#### IAM ROLE #####

locals {
  create_auto_iam_role             = local.auto_mode_enabled
  auto_iam_role_name               = coalesce(var.iam_role_name, "${var.cluster_name}-cluster")
  auto_iam_role_policy_prefix      = "arn:${local.partition}:iam::aws:policy"
  enable_cluster_encryption_config = length(var.cluster_encryption_config) > 0
  cluster_encryption_policy_name   = coalesce(var.cluster_encryption_policy_name, "${local.auto_iam_role_name}-ClusterEncryption")

  # Standard EKS cluster
  eks_standard_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy = "${local.auto_iam_role_policy_prefix}/AmazonEKSClusterPolicy",
  } : k => v if !local.auto_mode_enabled }

  # EKS cluster with EKS auto mode enabled
  eks_auto_mode_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy       = "${local.auto_iam_role_policy_prefix}/AmazonEKSClusterPolicy"
    AmazonEKSComputePolicy       = "${local.auto_iam_role_policy_prefix}/AmazonEKSComputePolicy"
    AmazonEKSBlockStoragePolicy  = "${local.auto_iam_role_policy_prefix}/AmazonEKSBlockStoragePolicy"
    AmazonEKSLoadBalancingPolicy = "${local.auto_iam_role_policy_prefix}/AmazonEKSLoadBalancingPolicy"
    AmazonEKSNetworkingPolicy    = "${local.auto_iam_role_policy_prefix}/AmazonEKSNetworkingPolicy"
  } : k => v if local.auto_mode_enabled }

  # Security groups for pods
  eks_sgpp_iam_role_policies = { for k, v in {
    AmazonEKSVPCResourceController = "${local.auto_iam_role_policy_prefix}/AmazonEKSVPCResourceController"
  } : k => v if var.enable_security_groups_for_pods && !local.auto_mode_enabled }
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.create && var.create_auto_iam_role ? 1 : 0

  statement {
    sid = "EKSClusterAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "auto" {
  count = local.create_auto_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.auto_iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.auto_iam_role_name}${var.prefix_separator}" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "auto" {
  for_each = { for k, v in merge(
    local.eks_standard_iam_role_policies,
    local.eks_auto_mode_iam_role_policies,
    local.eks_sgpp_iam_role_policies,
  ) : k => v if local.create_auto_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.auto[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if local.create_auto_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.auto[0].name
}

# Using separate attachment due to `The "for_each" value depends on resource attributes that cannot be determined until apply`
resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = local.create_auto_iam_role && var.attach_cluster_encryption_policy && local.enable_cluster_encryption_config ? 1 : 0

  policy_arn = aws_iam_policy.cluster_encryption[0].arn
  role       = aws_iam_role.auto[0].name
}

resource "aws_iam_policy" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = local.create_auto_iam_role && var.attach_cluster_encryption_policy && local.enable_cluster_encryption_config ? 1 : 0

  name        = var.cluster_encryption_policy_use_name_prefix ? null : local.cluster_encryption_policy_name
  name_prefix = var.cluster_encryption_policy_use_name_prefix ? local.cluster_encryption_policy_name : null
  description = var.cluster_encryption_policy_description
  path        = var.cluster_encryption_policy_path

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:GenerateDataKeyWithoutPlainText",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ReEncrypt*"
        ]
        Effect   = "Allow"
        Resource = [try(var.cluster_encryption_config.provider_key_arn, local.kms_key_arn)]
      },
    ]
  })

  tags = merge(var.tags, var.cluster_encryption_policy_tags)
}

data "aws_iam_policy_document" "custom" {
  count = local.create_auto_iam_role && var.enable_auto_mode_custom_tags ? 1 : 0

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "Compute"
      actions = [
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateLaunchTemplate",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-class-name"
        values   = ["*"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-pool-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "Storage"
      actions = [
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
      ]
      resources = [
        "arn:${local.partition}:ec2:*:*:volume/*",
        "arn:${local.partition}:ec2:*:*:snapshot/*",
      ]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "Networking"
      actions   = ["ec2:CreateNetworkInterface"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:kubernetes-cni-node-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "LoadBalancer"
      actions = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateRule",
        "ec2:CreateSecurityGroup",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "ShieldProtection"
      actions   = ["shield:CreateProtection"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "ShieldTagResource"
      actions   = ["shield:TagResource"]
      resources = ["arn:${local.partition}:shield::*:protection/*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }
}

resource "aws_iam_policy" "custom" {
  count = local.create_auto_iam_role && var.enable_auto_mode_custom_tags ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.auto_iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.auto_iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  policy = data.aws_iam_policy_document.custom[0].json

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = local.create_auto_iam_role && var.enable_auto_mode_custom_tags ? 1 : 0

  policy_arn = aws_iam_policy.custom[0].arn
  role       = aws_iam_role.auto[0].name
}

################################################################################
# EKS Auto Node IAM Role
################################################################################

locals {
  create_auto_node_iam_role = local.auto_mode_enabled
  auto_node_iam_role_name   = coalesce("noderole", "${var.cluster_name}-eks-auto")
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  count = local.create_auto_node_iam_role ? 1 : 0

  statement {
    sid = "EKSAutoNodeAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_auto_node_role" {
  count = local.create_auto_node_iam_role ? 1 : 0

  name        = var.auto_node_iam_role_use_name_prefix ? null : local.auto_node_iam_role_name
  name_prefix = var.auto_node_iam_role_use_name_prefix ? "${local.auto_node_iam_role_name}-" : null
  path        = var.auto_node_iam_role_path
  description = var.auto_node_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.node_assume_role_policy[0].json
  permissions_boundary  = var.auto_node_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.auto_node_iam_role_tags)
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "eks_auto_node_role" {
  for_each = { for k, v in {
    AmazonEKSWorkerNodeMinimalPolicy    = "${local.auto_iam_role_policy_prefix}/AmazonEKSWorkerNodeMinimalPolicy",
    AmazonEC2ContainerRegistryPullOnly  = "${local.auto_iam_role_policy_prefix}/AmazonEC2ContainerRegistryPullOnly",
    AmazonEKSWorkerNodePolicy           = "${local.auto_iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    AmazonEKS_CNI_Policy                = "${local.auto_iam_role_policy_prefix}/AmazonEKS_CNI_Policy",
    AmazonEC2ContainerRegistryReadOnly  = "${local.auto_iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    AmazonSSMFullAccess                 = "${local.auto_iam_role_policy_prefix}/AmazonSSMFullAccess",
    AmazonEC2ContainerRegistryPowerUser = "${local.auto_iam_role_policy_prefix}/AmazonEC2ContainerRegistryPowerUser",
    CloudWatchAgentServerPolicy         = "${local.auto_iam_role_policy_prefix}/CloudWatchAgentServerPolicy",

  } : k => v if local.create_auto_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.eks_auto_node_role[0].name
}

resource "aws_iam_role_policy_attachment" "eks_auto_additional" {
  for_each = { for k, v in var.auto_node_iam_role_additional_policies : k => v if local.create_auto_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.eks_auto_node_role[0].name
}
