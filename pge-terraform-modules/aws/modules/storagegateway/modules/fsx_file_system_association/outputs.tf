output "file_system_association_id" {
  description = "Amazon Resource Name (ARN) of the FSx file system association."
  value       = aws_storagegateway_file_system_association.file_system_association.id
}

output "file_system_association_arn" {
  description = "Amazon Resource Name (ARN) of the newly created file system association."
  value       = aws_storagegateway_file_system_association.file_system_association.arn
}

output "file_system_association_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_storagegateway_file_system_association.file_system_association.tags_all
}
