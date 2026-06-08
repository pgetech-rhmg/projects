###############################################################################
# Outputs
###############################################################################

output "instance_id" {
  description = "EC2 instance ID for EPIC deploy stage."
  value       = module.ec2.instance_id
}

output "bucket_name" {
  description = "S3 bucket name for deployment artifacts."
  value       = module.s3_api.bucket_name
}

output "db_cluster_endpoint" {
  description = "Aurora cluster writer endpoint."
  value       = aws_rds_cluster.epic.endpoint
}

output "db_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint."
  value       = aws_rds_cluster.epic.reader_endpoint
}

output "db_secret_arn" {
  description = "ARN of the RDS managed master user secret."
  value       = aws_rds_cluster.epic.master_user_secret[0].secret_arn
}
