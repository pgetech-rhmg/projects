#outputs for lustre_file_system
output "fsx_lustre_file_system_arn" {
  description = "Amazon Resource Name of the file system."
  value       = module.lustre_data_repository_association.fsx_lustre_file_system_arn
}

output "fsx_lustre_file_system_id" {
  description = "Identifier of the file system."
  value       = module.lustre_data_repository_association.fsx_lustre_file_system_id
}

#outputs for data_repository_association
output "data_repository_association_arn" {
  description = "Amazon Resource Name of the file system."
  value       = module.lustre_data_repository_association.data_repository_association_arn
}

output "data_repository_association_id" {
  description = "Identifier of the data repository association."
  value       = module.lustre_data_repository_association.data_repository_association_id
}
