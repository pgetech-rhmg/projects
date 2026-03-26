output "db_cluster_id" {
  value = aws_neptune_cluster.neptune_db_cluster.id
}

output "db_subnet_group_id" {
  value = aws_neptune_subnet_group.neptune_subnet_group.id
}

output "db_cluster_resource_id" {
  value = aws_neptune_cluster.neptune_db_cluster.cluster_resource_id
}

output "db_cluster_endpoint" {
  value = aws_neptune_cluster.neptune_db_cluster.reader_endpoint
}

output "sparql_endpoint" {
  value = "https://${aws_neptune_cluster.neptune_db_cluster.endpoint}:${aws_neptune_cluster.neptune_db_cluster.port}/sparql"
}

output "gremlin_endpoint" {
  value = "https://${aws_neptune_cluster.neptune_db_cluster.endpoint}:${aws_neptune_cluster.neptune_db_cluster.port}/gremlin"
}

output "loader_endpoint" {
  value = "https://${aws_neptune_cluster.neptune_db_cluster.endpoint}:${aws_neptune_cluster.neptune_db_cluster.port}/loader"
}

output "db_cluster_read_endpoint" {
  value = aws_neptune_cluster.neptune_db_cluster.reader_endpoint
}

output "db_cluster_port" {
  value = aws_neptune_cluster.neptune_db_cluster.port
}

output "poller_ecr" {
  value = aws_ecr_repository.neptune_poller.repository_url
}

output "consumer_ecr" {
  value = aws_ecr_repository.graph_consumer.repository_url
}

output "neptune_db_instance_id" {
  value = [aws_neptune_cluster_instance.neptune_db_instance[*].id]
}
