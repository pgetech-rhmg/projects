output "db_instance_automated_backups_replication_id" {
  description = "The automated backups replication id"
  value       = aws_db_instance_automated_backups_replication.this.id
}