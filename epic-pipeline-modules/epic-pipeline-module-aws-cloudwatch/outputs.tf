output "log_group_name" {
  description = "Resolved log group name."
  value       = local.manage_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "log_group_arn" {
  description = "Log group ARN."
  value       = local.manage_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

output "metric_filter_names" {
  description = "Map of metric filter logical name to attached filter name."
  value = {
    for k, f in aws_cloudwatch_log_metric_filter.this : k => f.name
  }
}

output "dashboard_arn" {
  description = "Dashboard ARN when managed by this module."
  value       = local.manage_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Dashboard name when managed by this module."
  value       = local.manage_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_name : null
}
