output "dashboard_arn" {
  description = "ECS Dashboard arn"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}