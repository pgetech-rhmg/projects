output "id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket_replication_configuration.default.id
}


output "aws_s3_bucket_replication_configuration_all" {
  description = "Map of all attributes of s3_bucket_replication_configuration_all"
  value       = aws_s3_bucket_replication_configuration.default
}
