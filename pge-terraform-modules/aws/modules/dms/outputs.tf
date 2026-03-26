# Outputs for dms replication task

output "replication_task_arn" {
  description = "The Amazon Resource Name (ARN) for the replication task."
  value       = aws_dms_replication_task.dms_replication_task.replication_task_arn
}

output "replication_task_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_dms_replication_task.dms_replication_task.tags_all
}

output "replication_task_status" {
  description = "Status of the replication task."
  value       = aws_dms_replication_task.dms_replication_task.status
}

output "dms_replication_task_all" {
  description = "A map of aws dms replication task"
  value       = aws_dms_replication_task.dms_replication_task

}