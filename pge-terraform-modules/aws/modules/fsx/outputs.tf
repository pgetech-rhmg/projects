output "fsx_windows_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].arn, "")
}

output "fsx_windows_file_system_dns_name" {
  description = "DNS name for the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].dns_name, "")
}

output "fsx_windows_file_system_id" {
  description = "Identifier of the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].id, "")
}

output "fsx_windows_file_system_network_interface_ids" {
  description = "Set of Elastic Network Interface identifiers from which the file system is accessible."
  value       = try(aws_fsx_windows_file_system.windows[0].network_interface_ids, "")
}

output "fsx_windows_file_system_owner_id" {
  description = "AWS account identifier that created the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].owner_id, "")
}

output "fsx_windows_file_system_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = try(aws_fsx_windows_file_system.windows[0].tags_all, "")
}

output "fsx_windows_file_system_vpc_id" {
  description = "Identifier of the Virtual Private Cloud for the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].vpc_id, "")
}

output "fsx_windows_file_system_preferred_file_server_ip" {
  description = "The IP address of the primary, or preferred, file server."
  value       = try(aws_fsx_windows_file_system.windows[0].preferred_file_server_ip, "")
}

output "fsx_windows_file_system_remote_administration_endpoint" {
  description = " For MULTI_AZ_1 deployment types, use this endpoint when performing administrative tasks on the file system using Amazon FSx Remote PowerShell. For SINGLE_AZ_1 deployment types, this is the DNS name of the file system."
  value       = try(aws_fsx_windows_file_system.windows[0].remote_administration_endpoint, "")
}

#outputs for aws_fsx_lustre_file_system
output "fsx_lustre_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].arn, "")
}

output "fsx_lustre_file_system_dns_name" {
  description = "DNS name for the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].dns_name, "")
}

output "fsx_lustre_file_system_id" {
  description = "Identifier of the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].id, "")
}

output "fsx_lustre_file_system_network_interface_ids" {
  description = "Set of Elastic Network Interface identifiers from which the file system is accessible."
  value       = try(aws_fsx_lustre_file_system.lustre[0].network_interface_ids, "")
}

output "fsx_lustre_file_system_mount_name" {
  description = "Identifier of the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].mount_name, "")
}

output "fsx_lustre_file_system_owner_id" {
  description = "AWS account identifier that created the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].owner_id, "")
}

output "fsx_lustre_file_system_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = try(aws_fsx_lustre_file_system.lustre[0].tags_all, "")
}

output "fsx_lustre_file_system_vpc_id" {
  description = "Identifier of the Virtual Private Cloud for the file system."
  value       = try(aws_fsx_lustre_file_system.lustre[0].vpc_id, "")
}