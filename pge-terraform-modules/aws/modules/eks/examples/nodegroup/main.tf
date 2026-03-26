/*
 * # Terraform usage example which creates eks multiple node groups in AWS
 * This module will create eks managed groups for ec2 instances.
*/
# Filename     : eks-modules/aws/modules/eks/examples/eks-nodegroups/main.tf
#  Date        : 26 May 2022
#  Author      : TekYantra
#  Description : eks-node group creation

#### Cluster Locals ########
locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Order              = var.Order
  Compliance         = var.Compliance

}

#### Tags module ########
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

## EKS  Module #####
module "eks" {
  source = "../../"

  cluster_name = var.cluster_name
  cluster_addons = {
    vpc-cni = {
      before_compute       = true
      most_recent          = true
      configuration_values = var.addon_configuration_values
    }
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
  }

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  codebuild_git_auth      = var.codebuild_git_auth
  argocd_git_auth         = var.argocd_git_auth
  custom_repo_url         = var.custom_repo_url
  custom_repo_branch      = var.custom_repo_branch
  create_cloudwatch_agent = var.create_cloudwatch_agent
  # Assume role needed for cross account route53 record creation
  account_num_r53 = var.account_num_r53

  ################################################################################
  # KMS Key Configuration for Cluster Encryption (etcd/secrets)
  # Choose ONE of the following options:
  ################################################################################
  # Option 1: Let the module create a new KMS key (recommended for new clusters)
  kms_role = var.kms_role
  # aws_kms_key_arn is not set, so module will create a new key

  # Option 2: Use an existing KMS key (uncomment and provide your key ARN)
  # aws_kms_key_arn = "arn:aws:kms:us-west-2:514712703977:key/your-existing-key-id"
  # kms_role is not needed when using an existing key
  ################################################################################

  role_service                    = var.role_service
  hosted_zone                     = var.hosted_zone
  aws_r53_role                    = var.aws_r53_role
  aws_role                        = var.aws_role
  eks_managed_node_groups         = local.eks_managed_node_groups
  cluster_service_cidr            = var.cluster_service_cidr
  parameter_subnet_id1_name       = var.parameter_subnet_id1_name
  parameter_subnet_id2_name       = var.parameter_subnet_id2_name
  parameter_subnet_id3_name       = var.parameter_subnet_id3_name
  parameter_vpc_id_name           = var.parameter_vpc_id_name
  role_service_managed            = var.role_service_managed
  account_num                     = var.account_num
  k8s-version                     = var.k8s-version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  access_entries                  = var.access_entries
  tags                            = module.tags.tags
}


################################################################################
# Supporting Resources
################################################################################

resource "aws_iam_policy" "additional" {
  name        = "${module.eks.cluster_id}-${var.custom_identity}-add"
  description = "Additional test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = module.tags.tags
}

data "aws_iam_policy_document" "source" {
  statement {
    actions   = ["s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "override" {
  statement {
    effect = "Deny"

    actions   = ["s3:*"]
    resources = ["*"]
  }
}

# The below module call is used for creating IAM roles, pod identity associations, and other AWS resources that are required by your selected Kubernetes addons.
module "addon-resources" {
  source = "../../modules/kubernetes-addons"

  cluster_name                              = module.eks.cluster_id
  domain_env                                = var.domain_env
  account_num                               = var.account_num
  create_loki_resources                     = var.create_loki_resources
  create_mimir_resources                    = var.create_mimir_resources
  create_tempo_resources                    = var.create_tempo_resources
  create_cluster_autoscaler_resources       = var.create_cluster_autoscaler_resources
  create_aws_for_fluentbit_resources        = var.create_aws_for_fluentbit_resources
  create_vpc_cni_resources                  = var.create_vpc_cni_resources
  create_ebs_csi_resources                  = var.create_ebs_csi_resources
  create_efs_csi_resources                  = var.create_efs_csi_resources
  create_karpenter_resources                = var.create_karpenter_resources
  cluster_autoscaler_cluster_names          = var.cluster_autoscaler_cluster_names
  create_custom_role                        = var.create_custom_role
  custom_identity                           = var.custom_identity
  custom_identity_associations              = var.custom_identity_associations
  custom_identity_source_policy_documents   = [data.aws_iam_policy_document.source.json]
  custom_identity_override_policy_documents = [data.aws_iam_policy_document.override.json]
  custom_identity_additional_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    additional           = aws_iam_policy.additional.arn
  }

  custom_identity_trust_policy_conditions = []
  external_secrets_kms_key_arns           = var.external_secrets_kms_key_arns
  encrypt_ebs_csi                         = var.encrypt_ebs_csi
  tags                                    = module.tags.tags
  # Revisit the below as we progress new approach
  eks_cluster_id = module.eks.cluster_id
  sns-topic      = var.sns-topic
}

# module "cloudwatchalarm" {
#   source = "../../modules/app-alerts"

#   cluster_name                        = var.cluster_name
#   pod_name                            = "nginx-deployment"
#   namespace                           = "default"
#   dashboard_region                    = var.aws_region
#   create_dashboard                    = true
#   tags                                = module.tags.tags
#   sns_subscription_email_address_list = var.Notify
#   sns_topic                           = var.sns-topic
# }
