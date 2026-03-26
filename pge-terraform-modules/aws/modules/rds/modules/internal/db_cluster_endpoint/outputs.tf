output "db_cluster_static_endpoint_arn" {
  description = "Amazon Resource Name (ARN) of cluster endpoint."
  value       = element(concat(aws_rds_cluster_endpoint.static[*].arn, [""]), 0)
}
output "db_cluster_static_endpoint_id" {
  description = "The RDS Cluster Endpoint Identifier."
  value       = element(concat(aws_rds_cluster_endpoint.static[*].id, [""]), 0)
}
output "db_cluster_static_endpoint" {
  description = "A custom endpoint for the Aurora cluster."
  value       = element(concat(aws_rds_cluster_endpoint.static[*].endpoint, [""]), 0)
}
output "db_cluster_static_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = element(concat(aws_rds_cluster_endpoint.static[*].tags, [""]), 0)
}

output "db_cluster_excluded_endpoint_arn" {
  description = "Amazon Resource Name (ARN) of cluster endpoint."
  value       = element(concat(aws_rds_cluster_endpoint.excluded[*].arn, [""]), 0)
}
output "db_cluster_excluded_endpoint_id" {
  description = "The RDS Cluster Endpoint Identifier."
  value       = element(concat(aws_rds_cluster_endpoint.excluded[*].id, [""]), 0)
}
output "db_cluster_excluded_endpoint" {
  description = "A custom endpoint for the Aurora cluster."
  value       = element(concat(aws_rds_cluster_endpoint.excluded[*].endpoint, [""]), 0)
}
output "db_cluster_excluded_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = element(concat(aws_rds_cluster_endpoint.excluded[*].tags, [""]), 0)
}