output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = try(aws_eks_cluster.eks_cluster.id, "")
}

output "cluster_all" {
  description = "all eks cluster attribute output"
  value       = aws_eks_cluster.eks_cluster
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = try(aws_eks_cluster.eks_cluster.endpoint, "")
}


output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(aws_eks_cluster.eks_cluster.version, null)
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(aws_eks_cluster.eks_cluster.platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(aws_eks_cluster.eks_cluster.status, null)
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id, null)
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate used for the ingress-nginx controller"
  value       = try(module.acm_public_certificate.acm_certificate_arn, "")
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.eks_cluster.certificate_authority[0].data, "")
}

output "node_group" {
  description = "node groups"
  value       = aws_eks_node_group.eks-nodegroup[*]
}

################################################################################
# EKS Addons
################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = merge(aws_eks_addon.this, aws_eks_addon.before_compute)
}

# Output the configuration (optional, for visualization)
output "generated_roles_config" {
  description = "generated_roles_config"
  value       = local.combined_roles
}

output "acm_public_certificate_arn" {
  description = "ACM Public Certificate"
  value       = module.acm_public_certificate.acm_certificate_arn
}

output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(module.user_data.user_data, null)
}

################################################################################
# KMS Key
################################################################################

output "kms_key_arn" {
  description = "ARN of the KMS key used for EKS cluster encryption"
  value       = local.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key created by this module (null if using externally provided key)"
  value       = var.aws_kms_key_arn == null ? module.kms[0].key_id : null
}