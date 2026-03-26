output "appstream_stack_arn" {
  description = "ARN of the appstream stack."
  value       = aws_appstream_stack.stack.arn
}

output "appstream_stack_created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the stack was created."
  value       = aws_appstream_stack.stack.created_time
}

output "appstream_stack_id" {
  description = "Unique ID of the appstream stack."
  value       = aws_appstream_stack.stack.id
}


output "appstream_stack_all" {
  description = "map of all appstream_stack attributes"
  value       = aws_appstream_stack.stack
}