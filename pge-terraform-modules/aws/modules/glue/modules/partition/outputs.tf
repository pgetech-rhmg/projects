output "glue_partition_id" {
  description = "partition id."
  value       = aws_glue_partition.glue_partition.id
}

output "glue_partition_creation_time" {
  description = " The time at which the partition was created."
  value       = aws_glue_partition.glue_partition.creation_time
}

output "glue_partition_last_analyzed_time" {
  description = " The last time at which column statistics were computed for this partition."
  value       = aws_glue_partition.glue_partition.last_analyzed_time
}

output "glue_partion_last_accessed_time" {
  description = " The last time at which the partition was accessed."
  value       = aws_glue_partition.glue_partition.last_accessed_time
}

output "aws_glue_partition" {
  description = " A map of aws_glue_partition object."
  value       = aws_glue_partition.glue_partition
}