output "arn" {
  description = "The Amazon Resource Name (ARN) of the source FSx location"
  value       = aws_datasync_location_fsx_windows_file_system.this.arn
}

output "id" {
  description = "The ID of the source FSx location"
  value       = aws_datasync_location_fsx_windows_file_system.this.id
}

output "uri" {
  description = "The URI of the FSx location"
  value       = aws_datasync_location_fsx_windows_file_system.this.uri
}

output "tags" {
  description = "A map of tags assigned to the FSx Windows location"
  value       = aws_datasync_location_fsx_windows_file_system.this.tags_all
}

output "creation_time" {
  description = "The creation time of the FSx Windows location"
  value       = aws_datasync_location_fsx_windows_file_system.this.creation_time
}