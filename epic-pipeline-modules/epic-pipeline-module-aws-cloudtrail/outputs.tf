output "trail_id" {
  description = "CloudTrail ID."
  value       = aws_cloudtrail.this.id
}

output "trail_arn" {
  description = "CloudTrail ARN."
  value       = aws_cloudtrail.this.arn
}

output "trail_name" {
  description = "CloudTrail name."
  value       = aws_cloudtrail.this.name
}

output "trail_home_region" {
  description = "Home region for the trail."
  value       = aws_cloudtrail.this.home_region
}
