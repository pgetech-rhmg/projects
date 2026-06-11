output "proxy_name" {
  description = "RDS Proxy name."
  value       = aws_db_proxy.this.name
}

output "proxy_arn" {
  description = "RDS Proxy ARN."
  value       = aws_db_proxy.this.arn
}

output "proxy_endpoint" {
  description = "RDS Proxy endpoint hostname."
  value       = aws_db_proxy.this.endpoint
}

output "target_group_name" {
  description = "Default target group name."
  value       = aws_db_proxy_default_target_group.this.name
}

output "target_group_arn" {
  description = "Default target group ARN."
  value       = aws_db_proxy_default_target_group.this.arn
}

output "target_endpoint" {
  description = "Endpoint of the registered target."
  value       = aws_db_proxy_target.this.endpoint
}
