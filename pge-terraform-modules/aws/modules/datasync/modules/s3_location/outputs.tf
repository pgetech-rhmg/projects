output "arn" {
  description = "The Amazon Resource Name (ARN) of the source S3 location"
  value       = aws_datasync_location_s3.this.arn
}

output "id" {
  description = "The ID of the source S3 location"
  value       = aws_datasync_location_s3.this.id
}

output "tags" {
  description = "The tags assigned to the source S3 location"
  value       = aws_datasync_location_s3.this.tags_all
}