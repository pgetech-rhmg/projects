output "efs_id" {
  description = "The ID of EFS"
  value       = module.efs.efs_id
}

output "efs_arn" {
  description = "The ARN of EFS"
  value       = module.efs.efs_arn
}

output "efs_dns_name" {
  description = "The DNS name for EFS"
  value       = module.efs.efs_dns_name
}

output "efs_access_point_arn" {
  description = "ARN of the access point."
  value       = module.efs.efs_access_point_arn
}

output "efs_access_point_id" {
  description = "ID of the access point."
  value       = module.efs.efs_access_point_id
}

output "efs_mount_target_id" {
  description = "The ID of the mount target."
  value       = module.efs.efs_mount_target_id
}
