output "cluster_id" {
  description = "Aurora cluster ID."
  value       = aws_rds_cluster.this.id
}

output "cluster_identifier" {
  description = "Aurora cluster identifier."
  value       = aws_rds_cluster.this.cluster_identifier
}

output "cluster_arn" {
  description = "Aurora cluster ARN."
  value       = aws_rds_cluster.this.arn
}

output "cluster_resource_id" {
  description = "Cluster resource ID (used for IAM database authentication)."
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "cluster_endpoint" {
  description = "Writer endpoint (cluster endpoint)."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Cluster port."
  value       = aws_rds_cluster.this.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_rds_cluster.this.database_name
}

output "master_username" {
  description = "Master username."
  value       = aws_rds_cluster.this.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the AWS-managed master credential secret (when manage_master_user_password is true)."
  value       = local.manage_master_password ? try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null) : null
}

output "instance_endpoints" {
  description = "Per-instance endpoints."
  value       = [for i in aws_rds_cluster_instance.this : i.endpoint]
}

output "instance_identifiers" {
  description = "Per-instance identifiers."
  value       = [for i in aws_rds_cluster_instance.this : i.identifier]
}

output "security_group_id" {
  description = "Aurora security group ID."
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "Aurora security group ARN."
  value       = aws_security_group.this.arn
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "db_cluster_parameter_group_name" {
  description = "DB cluster parameter group name."
  value       = aws_rds_cluster_parameter_group.this.name
}

output "db_parameter_group_name" {
  description = "DB instance parameter group name."
  value       = aws_db_parameter_group.this.name
}
