output "appstream_image_arn" {
  value       = aws_appstream_image_builder.image_builder.arn
  description = "ARN of the appstream image builder."
}

output "appstream_image_created_time" {
  value       = aws_appstream_image_builder.image_builder.created_time
  description = "Date and time, in UTC and extended RFC 3339 format, when the image builder was created."
}

output "appstream_image_id" {
  value       = aws_appstream_image_builder.image_builder.id
  description = "The name of the image builder."
}

output "appstream_image_state" {
  value       = aws_appstream_image_builder.image_builder.state
  description = "State of the image builder. Can be: PENDING, UPDATING_AGENT, RUNNING, STOPPING, STOPPED, REBOOTING, SNAPSHOTTING, DELETING, FAILED, UPDATING, PENDING_QUALIFICATION"
}


output "appstream_image_all" {
  value       = aws_appstream_image_builder.image_builder
  description = "Map of appstream_image attributes"
}