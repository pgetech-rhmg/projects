#Output the Pinpoint Project ID
output "pinpoint_app_id" {
  description = "The ID of the Pinpoint application"
  value       = aws_pinpoint_app.main.id
}