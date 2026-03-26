output "health_check_arn" {
  description = "The Amazon Resource Name (ARN) of the Health Check"
  value       = aws_route53_health_check.example.arn
}

output "health_check_id" {
  description = "The id of the health check"
  value       = aws_route53_health_check.example.id
}

output "health_check_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = aws_route53_health_check.example.tags_all
}