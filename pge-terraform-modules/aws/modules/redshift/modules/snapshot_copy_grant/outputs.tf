output "snapshot_grant_copy_arn" {
  description = "Amazon Resource Name (ARN) of snapshot copy grant"
  value       = aws_redshift_snapshot_copy_grant.test_tf.arn
}

output "snapshot_grant_copy_id" {
  description = "ID of snapshot copy grant"
  value       = aws_redshift_snapshot_copy_grant.test_tf.id
}

output "aws_redshift_snapshot_copy_grant_all" {
  description = "A map of aws redshift snapshot copy grant resource attributes references"
  value       = aws_redshift_snapshot_copy_grant.test_tf

}