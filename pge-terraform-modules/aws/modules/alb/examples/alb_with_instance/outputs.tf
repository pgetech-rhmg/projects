output "lb_id" {
  description = "The id of the load balancer (matches arn)."
  value       = module.alb.lb_id
}

output "lb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = module.alb.lb_arn
}

output "lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = module.alb.lb_arn_suffix
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.lb_dns_name
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = module.alb.lb_zone_id
}


output "target_group_arn" {
  description = "ARN of the Target Group (matches id)."
  value       = module.alb.target_group_arn
}

output "lb_target_group_attachment_id" {
  description = "A unique identifier for the attachment."
  value       = module.alb.lb_target_group_attachment_id
}

output "listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value       = module.alb.listener_http_arn
}

output "listener_https_arn" {
  description = "ARN of the listener (matches id)."
  value       = module.alb.listener_https_arn
}

output "lb_listener_certificate" {
  description = "The listener_arn and certificate_arn separated by a _."
  value       = module.alb.lb_listener_certificate
}

output "listener_rule_http_id" {
  description = "ARN of the listener (matches arn)."
  value       = module.alb.listener_rule_http_id
}

output "listener_rule_https_id" {
  description = "ARN of the listener (matches arn)."
  value       = module.alb.listener_rule_https_id
}