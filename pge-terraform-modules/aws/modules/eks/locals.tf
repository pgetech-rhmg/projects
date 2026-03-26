module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  account_id             = data.aws_caller_identity.current.account_id
  default_policy_arns    = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
  eks_arns               = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonSSMFullAccess", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  namespace              = "ccoe-tf-developers"
  module_tags            = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id, })
  kms_key_arn            = var.aws_kms_key_arn != null ? var.aws_kms_key_arn : module.kms[0].key_arn
  acm_domain_name        = "main-${var.cluster_name}.${var.hosted_zone}"
  promethus_domain_name  = "prometheus-${var.cluster_name}.${var.hosted_zone}"
  grafana_domain_name    = "grafana-${var.cluster_name}.${var.hosted_zone}"
  argocd_domain_name     = "argocd-${var.cluster_name}.${var.hosted_zone}"
  opencostui_domain_name = "opencost-${var.cluster_name}.${var.hosted_zone}"
}

### Default tags for eks cluster and managed node groups###

locals {
  launch_template_id = var.create && var.create_launch_template ? try(aws_launch_template.this.id, null) : var.launch_template_id
  # Change order to allow users to set version priority before using defaults
  launch_template_version = coalesce(var.launch_template_version, try(aws_launch_template.this.default_version, "$Default"))
}


locals {
  # Cluster Admins
  cluster_admins = {
    for i, admin in var.access_entries.clusteradmins :
    "clusteradmin_${i + 1}" => {
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}"
      type              = "STANDARD"
      kubernetes_groups = ["cluster-admins"]
      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Cluster Editors
  cluster_editors = {
    for i, editor in var.access_entries.clustereditors :
    "clustereditor_${i + 1}" => {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${editor.role}"
      type          = "STANDARD"
      policy_associations = {
        clustereditor = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = editor.namespaces
            type       = "namespace"
          }
        }
      }
    }
  }

  # Cluster Viewers
  cluster_viewers = {
    for i, viewer in var.access_entries.clusterviewers :
    "clusterviewer_${i + 1}" => {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${viewer.role}"
      type          = "STANDARD"
      policy_associations = {
        clustereditor = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = viewer.namespaces
            type       = "cluster"
          }
        }
      }
    }
  }

  # Combine all roles into a single local variable
  combined_roles = merge(local.cluster_admins, local.cluster_editors, local.cluster_viewers)
}
