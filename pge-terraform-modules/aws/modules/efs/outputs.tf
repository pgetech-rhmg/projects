output "efs_id" {
  description = "The ID of EFS"
  value       = aws_efs_file_system.efs.id
}

output "efs_arn" {
  description = "The ARN of EFS"
  value       = aws_efs_file_system.efs.arn
}

output "efs_dns_name" {
  description = "The DNS name for EFS"
  value       = aws_efs_file_system.efs.dns_name
}

output "efs_access_point_arn" {
  description = "ARN of the access point."
  value       = aws_efs_access_point.efs_access_point.arn
}

output "efs_access_point_id" {
  description = "ID of the access point."
  value       = aws_efs_access_point.efs_access_point.id
}

output "efs_mount_target_id" {
  description = "The ID of the mount target."
  value       = aws_efs_mount_target.efs_mount_target[*].id
}

output "efs_all" {
  description = "All attributes of EFS"
  value       = aws_efs_file_system.efs
}