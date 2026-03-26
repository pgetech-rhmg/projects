output "appstream_user_arn" {
  description = "ARN of the appstream user."
  value       = aws_appstream_user.user.arn
}

output "appstream_user_created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the user was created."
  value       = aws_appstream_user.user.created_time
}

output "appstream_user_id" {
  description = "Unique ID of the appstream user."
  value       = aws_appstream_user.user.id
}

output "appstream_user_all" {
  description = "map of all appstream user attributes"
  value       = aws_appstream_user.user
}