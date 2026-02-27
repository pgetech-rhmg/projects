output "alb" {
  description = "Map of the ALB object."
  value       = aws_lb.default
}

output "alb_arn" {
  description = "ARN of the ALB."
  value       = aws_lb.default.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.default.dns_name
}

output "alb_dns_zone_id" {
  description = "DNS zone id of the ALB."
  value       = aws_lb.default.zone_id
}

output "target_group" {
  description = "Map of the target group object."
  value       = aws_lb_target_group.default
}

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.default.arn
}

output "listener_arn" {
  description = "ARN of the HTTPS listener."
  value       = aws_lb_listener.https.arn
}