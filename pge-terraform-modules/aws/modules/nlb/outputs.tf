################################################################################
# Load Balancer
################################################################################

output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(aws_lb.this[0].id, null)
}

output "arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(aws_lb.this[0].arn, null)
}

output "arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = try(aws_lb.this[0].arn_suffix, null)
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.this[0].dns_name, null)
}

output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = try(aws_lb.this[0].zone_id, null)
}

################################################################################
# Listener(s)
################################################################################

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = aws_lb_listener.this
}

output "listener_rules" {
  description = "Map of listeners rules created and their attributes"
  value       = aws_lb_listener_rule.this
}

################################################################################
# Target Group(s)
################################################################################

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = aws_lb_target_group.this
}

################################################################################
# map of all resources
################################################################################

output "nlb_all" {
  description = "Map of aws nlb resource"
  value       = aws_lb.this

}

output "nlb_listener_all" {
  description = "Map of aws nlb listener resource"
  value       = aws_lb_listener.this

}

output "nlb_listener_rule_all" {
  description = "Map of aws nlb listener rule"
  value       = aws_lb_listener_rule.this

}

output "nlb_listener_certificate_all" {
  description = "Map of aws nlb listener certificate"
  value       = aws_lb_listener_certificate.this

}

output "nlb_target_group_all" {
  description = "Map of aws nlb target group"
  value       = aws_lb_target_group.this

}

output "nlb_target_group_attachment_all" {
  description = "Map of aws nlb target group attachment"
  value       = aws_lb_target_group_attachment.lb_target_group_attachment

}

output "wafv2_web_acl_association_all" {
  description = "Map of aws wafv2 web acl association"
  value       = aws_wafv2_web_acl_association.this

}