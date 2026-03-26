/*
 * # AWS eks cluster with  managed node group creation
 * This module will create eks and  managed groups.
*/
# Filename     : eks-modules/aws/modules/eks/modules/kubernetes-addons/main.tf
#  Date        : 26 july 2022
#  Author      : TekYantra
#  Description : kubernetes-addons creation

module "eks_cloudwatch_dashboard_and_alerts" {
  count                = var.create_eks_dashboard ? 1 : 0
  source               = "../internal/dashboard-alerts"
  aws_region           = var.aws_region
  cluster_dimensions   = var.cluster_dimensions
  pod_dimensions       = var.pod_dimensions
  create_eks_dashboard = var.create_eks_dashboard
  namespace_dimensions = var.namespace_dimensions
  service_dimensions   = var.service_dimensions
  sns-topic            = var.sns-topic
  eks_cluster_id       = var.eks_cluster_id
  tags                 = var.tags
}

#New Approach for addon roles
module "custom_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_custom_role ? 1 : 0

  name                      = "${var.cluster_name}-${var.custom_identity}"
  attach_custom_policy      = false
  source_policy_documents   = var.custom_identity_source_policy_documents
  override_policy_documents = var.custom_identity_override_policy_documents
  additional_policy_arns    = var.custom_identity_additional_policy_arns
  trust_policy_conditions   = var.custom_identity_trust_policy_conditions
  associations              = var.custom_identity_associations

  tags = var.tags
}

module "cluster-autoscaler-role" {
  source = "../internal/addons/roles"
  count  = var.create_cluster_autoscaler_resources ? 1 : 0

  name                                = "${var.cluster_name}-ca"
  create_cluster_autoscaler_resources = var.create_cluster_autoscaler_resources
  cluster_autoscaler_cluster_names    = var.cluster_autoscaler_cluster_names
  attach_cluster_autoscaler_policy    = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "cluster-autoscaler-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags
}

module "aws-for-fluentbit-role" {
  source = "../internal/addons/roles"
  count  = var.create_aws_for_fluentbit_resources ? 1 : 0

  name                               = "${var.cluster_name}-fluentbit-role"
  create_aws_for_fluentbit_resources = var.create_aws_for_fluentbit_resources
  cluster_name                       = var.cluster_name
  attach_aws_for_fluentbit_policy    = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-for-fluentbit-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags
}


module "ebs-csi-pod-identity" {
  source = "../internal/addons/roles"
  count  = var.create_ebs_csi_resources ? 1 : 0

  name                      = "${var.cluster_name}-aws-ebs-csi"
  create_ebs_csi_resources  = var.create_ebs_csi_resources
  attach_aws_ebs_csi_policy = true
  cluster_name              = var.cluster_name
  encrypt_ebs_csi           = var.encrypt_ebs_csi

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "ebs-csi-driver-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags

}

module "aws_efs_csi_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_efs_csi_resources ? 1 : 0

  name                      = "${var.cluster_name}-efs-csi-role"
  create_efs_csi_resources  = var.create_efs_csi_resources
  attach_aws_efs_csi_policy = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "efs-csi-controller-sa"
    cluster_name    = var.cluster_name
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }

    tags = var.tags
  }
}

module "external_secrets_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_external_secrets_resources ? 1 : 0

  name                                  = "${var.cluster_name}-external-secrets"
  create_external_secrets_resources     = var.create_external_secrets_resources
  attach_external_secrets_policy        = true
  external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/*"]
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:*"]
  external_secrets_kms_key_arns         = var.external_secrets_kms_key_arns
  external_secrets_create_permission    = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "external-secrets"
    service_account = "external-secrets-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags
}

module "aws_lb_controller_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_lb_controller_resources ? 1 : 0

  name                            = "${var.cluster_name}-aws-lbc"
  create_lb_controller_resources  = true
  attach_aws_lb_controller_policy = true
  cluster_name                    = var.cluster_name

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-load-balancer-controller-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags
}

module "aws_vpc_cni_ipv4_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_vpc_cni_resources ? 1 : 0

  name                      = "${var.cluster_name}-aws-vpc-cni-ipv4"
  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-node"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  tags = var.tags
}

module "karpenter" {
  source = "../internal/addons/karpenter"
  count  = var.create_karpenter_resources ? 1 : 0

  cluster_name                    = var.cluster_name
  enable_v1_permissions           = true
  namespace                       = "karpenter"
  enable_pod_identity             = true
  create_pod_identity_association = true
  node_iam_role_name              = "${var.cluster_name}-karpenter-node"
  iam_role_name                   = "${var.cluster_name}-karpentercontroller"
  queue_name                      = "karpenter-${var.cluster_name}"

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

module "external_dns_pod_identity" {
  source = "../internal/addons/roles"
  count  = var.create_external_dns_resources ? 1 : 0

  name                       = "${var.cluster_name}-external-dns-role"
  create_external_dns_role   = true
  attach_external_dns_policy = true
  cluster_name               = var.cluster_name

  # Pod Identity Associations
  association_defaults = {

    namespace       = "external-dns"
    service_account = "external-dns-sa"
  }

  associations = {
    ex-one = {
      cluster_name = var.cluster_name
    }
  }

  domain_env        = var.domain_env
  route53_zone_arns = var.route53_zone_arns

  tags = var.tags
}

module "grafana_loki" {
  source = "../internal/addons/grafana-loki"
  count  = var.create_loki_resources ? 1 : 0

  cluster_name          = var.cluster_name
  loki_role_name        = "${var.cluster_name}-loki-role"
  loki_role_description = "IAM role for Grafana Loki to access S3 buckets"
  namespace             = "monitoring"
  enable_pod_identity   = true
  bucket_name_chunks    = "${var.cluster_name}-loki-chunks"
  bucket_name_ruler     = "${var.cluster_name}-loki-ruler"

  tags = var.tags
}

module "grafana_mimir" {
  source = "../internal/addons/grafana-mimir"
  count  = var.create_mimir_resources ? 1 : 0

  cluster_name           = var.cluster_name
  mimir_role_name        = "${var.cluster_name}-mimir-role"
  mimir_role_description = "IAM role for Grafana Mimir to access S3 buckets"
  namespace              = "monitoring"
  enable_pod_identity    = true
  bucket_name_blocks     = "${var.cluster_name}-mimir-blocks"
  bucket_name_ruler      = "${var.cluster_name}-mimir-ruler"

  tags = var.tags
}

module "grafana_tempo" {
  source = "../internal/addons/grafana-tempo"
  count  = var.create_tempo_resources ? 1 : 0

  cluster_name           = var.cluster_name
  tempo_role_name        = "${var.cluster_name}-tempo-role"
  tempo_role_description = "IAM role for Grafana Tempo to access S3 buckets"
  namespace              = "monitoring"
  enable_pod_identity    = true
  bucket_name_traces     = "${var.cluster_name}-tempo-traces"

  tags = var.tags
}