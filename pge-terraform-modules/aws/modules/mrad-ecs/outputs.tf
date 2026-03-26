output "security_group_id" {
  description = "ID of the ECS security group."
  value       = aws_security_group.ecs_security_group.id
}

output "ecs_task_definition_family_map" {
  description = "Map of task name to ECS task definition family."
  value       = { for k, task in module.ecs_task_definition : k => task.ecs_task_definition_family }
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs_fargate.ecs_cluster_arn
}

output "ecr_repo_urls" {
  description = "Map of task name to ECR repository URL."
  value       = { for k, task in module.ecr : k => task.ecr_repository_url }
}

output "lb_arn" {
  description = "The ARN of the load balancer."
  value       = var.lb ? module.load_balancer[0].lb_arn : null
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = var.lb ? module.load_balancer[0].lb_dns_name : null
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = var.lb ? module.load_balancer[0].lb_zone_id : null
}

output "listener_https_arn" {
  description = "ARN of the listener"
  value       = var.lb ? module.load_balancer[0].listener_https_arn : null
}

output "autoscaling_target_ids" {
  description = "IDs of the autoscaling targets"
  value       = var.enable_autoscaling ? { for k, v in aws_appautoscaling_target.ecs_target : k => v.id } : {}
}

output "autoscaling_policy_arns" {
  description = "ARNs of the autoscaling policies"
  value       = var.enable_autoscaling ? { for k, v in aws_appautoscaling_policy.ecs_policy : k => v.arn } : {}
}

output "autoscaling_enabled" {
  description = "Whether autoscaling is enabled"
  value       = var.enable_autoscaling
}
