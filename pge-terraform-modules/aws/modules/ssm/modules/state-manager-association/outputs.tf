output "id" {
  description = "The SSM State manager ID"
  value       = aws_ssm_association.AutomationDocument.association_id
}

output "s3_bucket_name" {
  description = "The SSM State manager s3_bucket_name"
  value       = aws_ssm_association.AutomationDocument.output_location
}

