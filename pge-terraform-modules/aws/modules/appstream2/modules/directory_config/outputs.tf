output "appstream_directory_config" {
  description = "Unique identifier (ID) of the appstream directory config."
  value       = aws_appstream_directory_config.directory_config.id
}

output "appstream_created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the directory config was created."
  value       = aws_appstream_directory_config.directory_config.created_time
}



output "appstream_all" {
  description = "Map of all appstream_directory attributes"
  value       = aws_appstream_directory_config.directory_config
}