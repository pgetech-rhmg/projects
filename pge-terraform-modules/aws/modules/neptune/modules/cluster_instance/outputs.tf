#Outputs for cluster instance
output "cluster_instance_address" {
  description = "The hostname of the instance."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].address
}

output "cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of neptune instance."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].arn
}

output "cluster_instance_dbi_resource_id" {
  description = "The region-unique, immutable identifier for the neptune instance."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].dbi_resource_id
}

output "cluster_instance_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].endpoint
}

output "cluster_instance_id" {
  description = "The Instance identifier."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].id
}

output "cluster_instance_kms_key_arn" {
  description = "The ARN for the KMS encryption key if one is set to the neptune cluster."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].kms_key_arn
}

output "cluster_instance_storage_encrypted" {
  description = "Specifies whether the neptune cluster is encrypted."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].storage_encrypted
}

output "cluster_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].tags_all
}

output "cluster_instance_writer" {
  description = "Boolean indicating if this instance is writable. False indicates this instance is a read replica."
  value       = aws_neptune_cluster_instance.neptune_cluster_instance[*].writer
}

output "neptune_cluster_instance_all" {
  description = "A map of aws neptune cluster instance"
  value       = aws_neptune_cluster_instance.neptune_cluster_instance

}