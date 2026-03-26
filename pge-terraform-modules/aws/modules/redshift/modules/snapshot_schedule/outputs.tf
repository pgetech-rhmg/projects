output "snapshot_schedule_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Snapshot Schedule."
  value       = aws_redshift_snapshot_schedule.snapshot_schedule.arn
}

output "snapshot_schedule_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = aws_redshift_snapshot_schedule.snapshot_schedule.tags_all
}

output "aws_redshift_snapshot_schedule_all" {
  description = "A map of aws redshift snapshot schedule attributes references"
  value       = aws_redshift_snapshot_schedule.snapshot_schedule

}

output "aws_redshift_snapshot_schedule_association_all" {
  description = "A map of aws redshift snapshot schedule association attributes references"
  value       = aws_redshift_snapshot_schedule_association.snapshot_schedule_association

}