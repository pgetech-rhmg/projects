output "appsync_resolver_arn" {
  description = "ARN"
  value       = aws_appsync_resolver.appsync_resolver.arn
}

output "appsync_resolver_all" {
  description = "Map of appsync_resolver object."
  value       = aws_appsync_resolver.appsync_resolver
}