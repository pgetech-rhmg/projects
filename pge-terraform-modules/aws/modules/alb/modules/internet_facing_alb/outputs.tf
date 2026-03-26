output "lb_id" {
  description = "The id of the load balancer (matches arn)."
  value       = aws_lb.lb.id
}

output "lb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.lb.arn
}

output "lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.lb.arn_suffix
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.lb.dns_name
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.lb.zone_id
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER target group output
#------------------------------------------------------------------------------

output "target_group_arn_suffix" {
  description = "ARN suffix for use with CloudWatch Metrics."
  value = {
    for index, value in aws_lb_target_group.lb_target_group : index => value.arn_suffix
  }
}

output "target_group_arn" {
  description = "ARN of the Target Group (matches id)."
  value = {
    for index, value in aws_lb_target_group.lb_target_group : index => value.arn
  }
}

output "target_group_id" {
  description = "ARN of the Target Group (matches arn)."
  value = {
    for index, value in aws_lb_target_group.lb_target_group : index => value.id
  }
}

output "target_group_name" {
  description = "Name of the Target Group."
  value = {
    for index, value in aws_lb_target_group.lb_target_group : index => value.name
  }
}

output "target_group_tags_all" {
  description = "ARN suffix for use with CloudWatch Metrics."
  value = {
    for index, value in aws_lb_target_group.lb_target_group : index => value.tags_all
  }
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER target group attachment output
#------------------------------------------------------------------------------

output "lb_target_group_attachment_id" {
  description = "A unique identifier for the attachment."
  value = {
    for index, value in aws_lb_target_group_attachment.lb_target_group_attachment : index => value.id
  }
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER Listener output
#------------------------------------------------------------------------------
output "listener_http_arn" {
  description = "ARN of the listener (matches id)."
  value = {
    for index, value in aws_lb_listener.lb_listener_http : index => value.arn
  }
}

output "listener_http_id" {
  description = "ARN of the listener (matches arn)."
  value = {
    for index, value in aws_lb_listener.lb_listener_http : index => value.id
  }
}

output "listener_http_tags_all" {
  description = "A map of tags assigned to the resource."
  value = {
    for index, value in aws_lb_listener.lb_listener_http : index => value.tags_all
  }
}

output "listener_https_arn" {
  description = "ARN of the listener (matches id)."
  value = {
    for index, value in aws_lb_listener.lb_listener_https : index => value.arn
  }
}

output "listener_https_id" {
  description = "ARN of the listener (matches arn)."
  value = {
    for index, value in aws_lb_listener.lb_listener_https : index => value.id
  }
}

output "listener_https_tags_all" {
  description = "A map of tags assigned to the resource."
  value = {
    for index, value in aws_lb_listener.lb_listener_https : index => value.tags_all
  }
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER Listener certificate output
#------------------------------------------------------------------------------

output "lb_listener_certificate" {
  description = "The listener_arn and certificate_arn separated by a _."
  value = {
    for index, value in aws_lb_listener_certificate.lb_listener_certificate : index => value.id
  }
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER Listener rule output
#------------------------------------------------------------------------------

output "listener_rule_http_id" {
  description = "ARN of the listener (matches arn)."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_http : index => value.id
  }
}

output "listener_rule_http_arn" {
  description = "ARN of the listener (matches id)."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_http : index => value.arn
  }
}

output "listener_rule_http_tags_all" {
  description = "A map of tags assigned to the resource."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_http : index => value.tags_all
  }
}

output "listener_rule_https_id" {
  description = "ARN of the listener (matches arn)."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_https : index => value.id
  }
}

output "listener_rule_https_arn" {
  description = "ARN of the listener (matches id)."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_https : index => value.arn
  }
}

output "listener_rule_https_tags_all" {
  description = "A map of tags assigned to the resource."
  value = {
    for index, value in aws_lb_listener_rule.lb_listener_rule_https : index => value.tags_all
  }
}

output "alb" {
  description = "Map of ALB object"
  value       = aws_lb.lb
}

output "alb_target_group" {
  description = "Map of ALB target-group object"
  value       = aws_lb_target_group.lb_target_group
}

output "alb_listener_http" {
  description = "Map of ALB http listener object"
  value       = aws_lb_listener.lb_listener_http
}

output "alb_listener_https" {
  description = "Map of ALB https listener object"
  value       = aws_lb_listener.lb_listener_https
}

output "alb_listener_rule_http" {
  description = "Map of ALB http listener rule object"
  value       = aws_lb_listener_rule.lb_listener_rule_http
}

output "alb_listener_rule_https" {
  description = "Map of ALB https listener rule object"
  value       = aws_lb_listener_rule.lb_listener_rule_https
}