output "docdb_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = aws_docdb_cluster.docdb_cluster.arn
}

output "docdb_cluster_cluster_members" {
  description = "List of DocDB Instances that are a part of this cluster."
  value       = aws_docdb_cluster.docdb_cluster.cluster_members
}

output "docdb_cluster_resource_id" {
  description = "The DocDB Cluster Resource ID."
  value       = aws_docdb_cluster.docdb_cluster.cluster_resource_id
}

output "docdb_cluster_endpoint" {
  description = "The DNS address of the DocDB instance."
  value       = aws_docdb_cluster.docdb_cluster.endpoint
}

output "docdb_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = aws_docdb_cluster.docdb_cluster.hosted_zone_id
}

output "docdb_cluster_id" {
  description = "The DocDB Cluster Identifier."
  value       = aws_docdb_cluster.docdb_cluster.id
}

output "docdb_cluster_reader_endpoint" {
  description = "A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas."
  value       = aws_docdb_cluster.docdb_cluster.reader_endpoint
}

output "docdb_cluster_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_docdb_cluster.docdb_cluster.tags_all
}
