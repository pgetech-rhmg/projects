output "cluster_arn" {
  description = "The Neptune Cluster Amazon Resource Name (ARN)"
  value       = aws_neptune_cluster.neptune_cluster.arn
}

output "neptune_cluster_resource_id" {
  description = "The Neptune Cluster Resource ID"
  value       = aws_neptune_cluster.neptune_cluster.cluster_resource_id
}

output "neptune_cluster_members" {
  description = "List of Neptune Instances that are a part of this cluster"
  value       = aws_neptune_cluster.neptune_cluster.cluster_members
}

output "neptune_cluster_endpoint" {
  description = "The DNS address of the Neptune instance"
  value       = aws_neptune_cluster.neptune_cluster.endpoint
}

output "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = aws_neptune_cluster.neptune_cluster.hosted_zone_id
}

output "neptune_cluster_id" {
  description = "The Neptune Cluster Identifier"
  value       = aws_neptune_cluster.neptune_cluster.id
}

output "neptune_cluster_reader_endpoint" {
  description = "A read-only endpoint for the Neptune cluster, automatically load-balanced across replicas"
  value       = aws_neptune_cluster.neptune_cluster.reader_endpoint
}

output "neptune_cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_neptune_cluster.neptune_cluster.tags_all
}

output "neptune_cluster" {
  description = "A map of aws neptune cluster"
  value       = aws_neptune_cluster.neptune_cluster
}