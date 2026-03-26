output "id" {
  description = "The Redshift Cluster ID."
  value       = aws_redshift_cluster_iam_roles.cluster_roles.id
}

output "aws_redshift_cluster_iam_roles_all" {
  description = "A map of aws redshift cluster iam roles attributes references"
  value       = aws_redshift_cluster_iam_roles.cluster_roles

}