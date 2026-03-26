output "eks-cloudwatch-dashboard-arn" {
  value = module.eks_cloudwatch_dashboard_and_alerts[*].eks-cloudwatch-dashboard-arn

}

# addon roles 
output "cluster-autoscaler-role" {
  value       = try(module.cluster-autoscaler-role[*].iam_role_arn)
  description = "ADDON ROLES --- cluster-autoscaler-role"
}

output "ebs-csi-pod-identity_role" {
  value       = try(module.ebs-csi-pod-identity[*].iam_role_arn)
  description = "ADDON ROLES --- ebs-csi-pod-identity role"
}

output "aws_efs_csi_pod_identity_role" {
  value       = try(module.aws_efs_csi_pod_identity[*].iam_role_arn)
  description = "ADDON ROLES --- aws_efs_csi_pod_identity role"
}

output "external_secrets_pod_identity_role" {
  value       = try(module.external_secrets_pod_identity[*].iam_role_arn)
  description = "ADDON ROLES --- external_secrets_pod_identity role"
}

output "aws_lb_controller_pod_identity_role" {
  value       = try(module.aws_lb_controller_pod_identity[*].iam_role_arn)
  description = "ADDON ROLES --- aws_lb_controller_pod_identity role"
}

output "custom_pod_identity_role" {
  value       = try(module.custom_pod_identity[*].iam_role_arn)
  description = "ADDON ROLES --- custom_pod_identity role"
}

output "loki_chunks_bucket_name" {
  description = "Grafana Loki s3 bucket name for chunks"
  value       = module.grafana_loki[*].loki_chunks_bucket_name
}

output "loki_chunks_bucket_arn" {
  description = "Grafana Loki s3 ARN for chunks"
  value       = module.grafana_loki[*].loki_chunks_bucket_arn
}

output "loki_ruler_bucket_name" {
  description = "Grafana Loki s3 bucket name for ruler"
  value       = module.grafana_loki[*].loki_ruler_bucket_name
}
output "loki_ruler_bucket_arn" {
  description = "Grafana Loki s3 ARN for ruler"
  value       = module.grafana_loki[*].loki_ruler_bucket_arn
}

output "mimir_ruler_bucket_name" {
  description = "S3 bucket name for Mimir ruler storage."
  value       = module.grafana_mimir[*].mimir_ruler_bucket_name
}

output "mimir_ruler_bucket_arn" {
  description = "S3 ARN for Mimir ruler storage."
  value       = module.grafana_mimir[*].mimir_ruler_bucket_arn
}
output "mimir_blocks_bucket_name" {
  description = "S3 bucket name for Mimir blocks storage."
  value       = module.grafana_mimir[*].mimir_blocks_bucket_name
}

output "mimir_blocks_bucket_arn" {
  description = "S3 ARN for Mimir blocks storage."
  value       = module.grafana_mimir[*].mimir_blocks_bucket_arn
}

output "tempo_traces_bucket_name" {
  description = "S3 bucket name for Tempo traces storage."
  value       = module.grafana_tempo[*].traces_bucket_name
}
output "tempo_traces_bucket_arn" {
  description = "S3 ARN for Tempo traces storage."
  value       = module.grafana_tempo[*].traces_bucket_arn
}

output "ebs_csi_kms_key_arn" {
  description = "ARN of the KMS key for EBS CSI driver to encrypt EBS volumes it creates"
  value       = try(module.ebs-csi-pod-identity[0].ebs_csi_kms_key_arn, null)
}