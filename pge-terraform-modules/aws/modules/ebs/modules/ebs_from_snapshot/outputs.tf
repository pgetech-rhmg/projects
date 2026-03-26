output "volume_id" {
  description = "The ID of EBS"
  value       = aws_ebs_volume.ebs.id
}

output "volume_arn" {
  description = "The ARN of EBS"
  value       = aws_ebs_volume.ebs.arn
}

output "volume_tags_all" {
  description = "A map of tags assigned to the resource"
  value       = aws_ebs_volume.ebs.tags_all
}