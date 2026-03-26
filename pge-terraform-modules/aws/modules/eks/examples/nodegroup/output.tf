#### output file ############

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(module.eks[*].cluster_primary_security_group_id, null)
}

output "cluster_id_all" {
  description = "EKS cluster ID"
  value       = module.eks[*].cluster_id
}

output "cluster_addons" {
  value       = module.eks.cluster_addons
  description = "The status of addons"
}

output "cluster-autoscaler-role" {
  value = try(module.addon-resources.cluster-autoscaler-role)
}

output "external_secrets_pod_identity_role" {
  value = try(module.addon-resources.external_secrets_pod_identity_role)
}

output "aws_lb_controller_pod_identity_role" {
  value = try(module.addon-resources.aws_lb_controller_pod_identity_role)
}

output "custom_pod_identity_role" {
  value = try(module.addon-resources.custom_pod_identity_role)
}

output "loki_chunks_bucket_name" {
  description = "s3 bucket name"
  value       = module.addon-resources.loki_chunks_bucket_name
}

output "loki_chunks_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.addon-resources.loki_chunks_bucket_arn
}

output "loki_ruler_bucket_name" {
  description = "s3 bucket name"
  value       = module.addon-resources.loki_ruler_bucket_name
}
output "loki_ruler_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.addon-resources.loki_ruler_bucket_arn
}

output "mimir_ruler_bucket_name" {
  description = "S3 bucket name for Mimir ruler storage."
  value       = module.addon-resources.mimir_ruler_bucket_name
}
output "mimir_ruler_bucket_arn" {
  description = "S3 ARN for Mimir ruler storage."
  value       = module.addon-resources.mimir_ruler_bucket_arn
}
output "mimir_blocks_bucket_name" {
  description = "S3 bucket name for Mimir blocks storage."
  value       = module.addon-resources.mimir_blocks_bucket_name
}
output "mimir_blocks_bucket_arn" {
  description = "S3 ARN for Mimir blocks storage."
  value       = module.addon-resources.mimir_blocks_bucket_arn
}

output "traces_bucket_name" {
  description = "S3 bucket name for Tempo traces storage."
  value       = module.addon-resources.tempo_traces_bucket_name
}
output "traces_bucket_arn" {
  description = "S3 ARN for Tempo traces storage."
  value       = module.addon-resources.tempo_traces_bucket_arn
}

output "acm_public_certificate_arn" {
  description = "ACM Public Certificate"
  value       = module.eks.acm_public_certificate_arn
}

output "ebs_csi_kms_key_arn" {
  description = "ARN of the KMS key for EBS CSI driver to encrypt EBS volumes it creates"
  value       = try(module.addon-resources.ebs_csi_kms_key_arn, null)
}

output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(module.eks.user_data, "")
}