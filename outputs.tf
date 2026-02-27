output "alb" {
  description = "Map of the ALB object."
  value       = aws_lb.api
}

output "alb_arn" {
  description = "ARN of the ALB."
  value       = aws_lb.api.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.api.dns_name
}

output "target_group" {
  description = "Map of the target group object."
  value       = aws_lb_target_group.api
}

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.api.arn
}

output "listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = aws_lb_listener.https.arn
}