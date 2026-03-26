#outputs for lustre_file_system
output "fsx_lustre_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = aws_fsx_lustre_file_system.lustre.arn
}

output "fsx_lustre_file_system_dns_name" {
  description = "DNS name for the file system."
  value       = aws_fsx_lustre_file_system.lustre.dns_name
}

output "fsx_lustre_file_system_id" {
  description = "Identifier of the file system."
  value       = aws_fsx_lustre_file_system.lustre.id
}

output "fsx_lustre_file_system_network_interface_ids" {
  description = "Set of Elastic Network Interface identifiers from which the file system is accessible."
  value       = aws_fsx_lustre_file_system.lustre.network_interface_ids
}

output "fsx_lustre_file_system_mount_name" {
  description = "Identifier of the file system."
  value       = aws_fsx_lustre_file_system.lustre.mount_name
}

output "fsx_lustre_file_system_owner_id" {
  description = "AWS account identifier that created the file system."
  value       = aws_fsx_lustre_file_system.lustre.owner_id
}

output "fsx_lustre_file_system_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_fsx_lustre_file_system.lustre.tags_all
}

output "fsx_lustre_file_system_vpc_id" {
  description = "Identifier of the Virtual Private Cloud for the file system."
  value       = aws_fsx_lustre_file_system.lustre.vpc_id
}

#outputs for data_repository_association
output "data_repository_association_arn" {
  description = "Amazon Resource Name of the file system."
  value       = aws_fsx_data_repository_association.data_repository_association.arn
}

output "data_repository_association_id" {
  description = "Identifier of the data repository association."
  value       = aws_fsx_data_repository_association.data_repository_association.id
}

output "data_repository_association_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_fsx_data_repository_association.data_repository_association.tags_all
}