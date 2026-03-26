output "usage_limit_arn" {
  description = "Amazon Resource Name (ARN) of the Redshift Usage Limit."
  value       = aws_redshift_usage_limit.usage-one.arn
}

output "usage_limit_id" {
  description = "The Redshift Usage Limit ID."
  value       = aws_redshift_usage_limit.usage-one.id
}

output "aws_redshift_usage_limit_all" {
  description = "A map of aws redshift usage limit attribute references"
  value       = aws_redshift_usage_limit.usage-one

}