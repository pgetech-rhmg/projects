output "id_user_stack" {
  description = "Unique ID of the appstream User Stack association."
  value       = aws_appstream_user_stack_association.user_stack.id
}

output "id_user_all" {
  description = "Map of all id_user attributes"
  value       = aws_appstream_user_stack_association.user_stack
}