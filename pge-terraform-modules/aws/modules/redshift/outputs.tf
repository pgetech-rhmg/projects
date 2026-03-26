output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = aws_redshift_cluster.Cluster.arn
}

output "cluster_id" {
  description = "The Redshift Cluster ID."
  value       = aws_redshift_cluster.Cluster.id
}

output "cluster_cluster_identifier" {
  description = "The Cluster Identifier."
  value       = aws_redshift_cluster.Cluster.cluster_identifier
}

output "cluster_cluster_type" {
  description = "The cluster type."
  value       = aws_redshift_cluster.Cluster.cluster_type
}

output "cluster_node_type" {
  description = "The type of nodes in the cluster."
  value       = aws_redshift_cluster.Cluster.node_type
}

output "cluster_database_name" {
  description = "The name of the default database in the Cluster."
  value       = aws_redshift_cluster.Cluster.database_name
}

output "cluster_availability_zone" {
  description = "The availability zone of the Cluster."
  value       = aws_redshift_cluster.Cluster.availability_zone
}

output "cluster_automated_snapshot_retention_period" {
  description = "The backup retention period."
  value       = aws_redshift_cluster.Cluster.automated_snapshot_retention_period
}

output "cluster_preferred_maintenance_window" {
  description = "The backup window."
  value       = aws_redshift_cluster.Cluster.preferred_maintenance_window
}

output "cluster_endpoint" {
  description = "The connection endpoint."
  value       = aws_redshift_cluster.Cluster.endpoint
}

output "cluster_encrypted" {
  description = "Whether the data in the cluster is encrypted."
  value       = aws_redshift_cluster.Cluster.encrypted
}


output "cluster_vpc_security_group_ids" {
  description = "The VPC security group Ids associated with the cluster."
  value       = aws_redshift_cluster.Cluster.vpc_security_group_ids
}

output "cluster_dns_name" {
  description = "The DNS name of the cluster."
  value       = aws_redshift_cluster.Cluster.dns_name
}

output "cluster_port" {
  description = "The Port the cluster responds on."
  value       = aws_redshift_cluster.Cluster.port
}

output "cluster_cluster_version" {
  description = "The version of Redshift engine software."
  value       = aws_redshift_cluster.Cluster.cluster_version
}

output "cluster_cluster_parameter_group_name" {
  description = "The name of the parameter group to be associated with this cluster."
  value       = aws_redshift_cluster.Cluster.cluster_parameter_group_name
}

output "cluster_cluster_subnet_group_name" {
  description = "The name of a cluster subnet group to be associated with this cluster."
  value       = aws_redshift_cluster.Cluster.cluster_subnet_group_name
}

output "cluster_cluster_public_key" {
  description = "The public key for the cluster."
  value       = aws_redshift_cluster.Cluster.cluster_public_key
}

output "cluster_cluster_revision_number" {
  description = "The specific revision number of the database in the cluster."
  value       = aws_redshift_cluster.Cluster.cluster_revision_number
}

output "cluster_cluster_nodes" {
  description = "The nodes in the cluster. Cluster node blocks are documented below."
  value       = aws_redshift_cluster.Cluster.cluster_nodes
}

output "cluster_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_redshift_cluster.Cluster.tags_all
}

output "aws_redshift_cluster_all" {
  description = "A map of aws redshift cluster attribute references"
  value       = aws_redshift_cluster.Cluster

}

output "redshift_snapshot_copy" {
  description = "A map of all attributes of aws redshift snapshot copy"
  value       = aws_redshift_snapshot_copy.snapshot_copy

}

output "redshift_logging" {
  description = "A map of all attributes of aws redshift logging"
  value       = aws_redshift_logging.Cluster_logging

}