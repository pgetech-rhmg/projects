output "neptune_cluster_endpoint_arn" {
  description = "The Neptune Cluster Endpoint Amazon Resource Name (ARN)."
  value       = aws_neptune_cluster_endpoint.neptune_cluster_endpoint.arn
}

output "neptune_cluster_endpoint" {
  description = "The DNS address of the endpoint."
  value       = aws_neptune_cluster_endpoint.neptune_cluster_endpoint.endpoint
}

output "neptune_cluster_endpoint_id" {
  description = "The Neptune Cluster Endpoint Identifier"
  value       = aws_neptune_cluster_endpoint.neptune_cluster_endpoint.id
}

output "neptune_cluster_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_neptune_cluster_endpoint.neptune_cluster_endpoint.tags_all
}

output "neptune_cluster_endpoint_all" {
  description = "A map of aws neptune cluster endpoint"
  value       = aws_neptune_cluster_endpoint.neptune_cluster_endpoint
}