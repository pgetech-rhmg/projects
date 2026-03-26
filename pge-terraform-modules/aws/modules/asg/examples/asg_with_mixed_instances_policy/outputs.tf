# Outputs for Autoscaling group

output "id" {
  value       = module.aws_autoscaling_group.id
  description = "The Auto Scaling Group id"
}

output "arn" {
  value       = module.aws_autoscaling_group.arn
  description = "The ARN for this Auto Scaling Group"
}

output "availability_zones" {
  value       = module.aws_autoscaling_group.availability_zones
  description = "The availability zones of the Auto Scaling Group"
}

output "min_size" {
  value       = module.aws_autoscaling_group.min_size
  description = "The minimum size of the Auto Scaling Group"
}

output "max_size" {
  value       = module.aws_autoscaling_group.max_size
  description = "The maximum size of the Auto Scaling Group"
}

output "name" {
  value       = module.aws_autoscaling_group.name
  description = "The name of the Auto Scaling Group"
}

output "health_check_grace_period" {
  value       = module.aws_autoscaling_group.health_check_grace_period
  description = "Time after instance comes into service before checking health"
}

output "health_check_type" {
  value       = module.aws_autoscaling_group.health_check_type
  description = "Controls how health checking is done"
}

output "desired_capacity" {
  value       = module.aws_autoscaling_group.desired_capacity
  description = "The number of Amazon EC2 instances that should be running in the group"
}

# Outputs for Autoscaling policy

output "autoscaling_policy_arn" {
  value       = module.aws_autoscaling_group.autoscaling_policy_arn
  description = "The ARN assigned by AWS to the scaling policy."
}

output "autoscaling_policy_name" {
  value       = module.aws_autoscaling_group.autoscaling_policy_name
  description = "The scaling policy's name."
}

output "adjustment_type" {
  value       = module.aws_autoscaling_group.adjustment_type
  description = "The scaling policy's adjustment type."
}

output "policy_type" {
  value       = module.aws_autoscaling_group.policy_type
  description = "The scaling policy's type."
}

# Outputs for Autoscaling attachment

output "target_group_arn_suffix" {
  value       = aws_lb_target_group.lb_target_group.arn_suffix
  description = "ARN suffix for use with CloudWatch Metrics."
}

output "target_group_arn" {
  value       = aws_lb_target_group.lb_target_group.arn
  description = "ARN of the Target Group (matches id)."
}

output "target_group_id" {
  value       = aws_lb_target_group.lb_target_group.id
  description = "ARN of the Target Group (matches arn)."
}

output "target_group_name" {
  value       = aws_lb_target_group.lb_target_group.name
  description = "Name of the Target Group."
}

output "target_group_tags_all" {
  value       = aws_lb_target_group.lb_target_group.tags_all
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}