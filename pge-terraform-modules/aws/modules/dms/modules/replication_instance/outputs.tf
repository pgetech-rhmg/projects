# Outputs for dms replication subnet group

output "vpc_id_replication_subnet_group" {
  description = "The ID of the VPC the subnet group is in."
  value       = aws_dms_replication_subnet_group.test.vpc_id
}

# Outputs for dms replication instance

output "replication_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the replication instance."
  value       = aws_dms_replication_instance.test.replication_instance_arn
}

output "replication_instance_private_ips" {
  description = "A list of the private IP addresses of the replication instance."
  value       = aws_dms_replication_instance.test.replication_instance_private_ips
}

output "dms_replication_subnet_group_all" {
  description = "A map of aws dms replication subnet group"
  value       = aws_dms_replication_subnet_group.test
}

output "dms_replication_instance_all" {
  description = "A map of aws dms replication instance"
  value       = aws_dms_replication_instance.test

}