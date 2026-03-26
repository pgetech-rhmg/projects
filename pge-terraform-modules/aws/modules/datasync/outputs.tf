output "id" {
  description = "The ID of the DataSync Task."
  value       = aws_datasync_task.datasync.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the DataSync Task."
  value       = aws_datasync_task.datasync.arn
}

output "tags" {
  description = "A map of tags assigned to the DataSync Task."
  value       = aws_datasync_task.datasync.tags_all
}