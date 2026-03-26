# Outputs for Autoscaling group
output "asg_id" {
  value       = module.asg_with_launch_template.id
  description = "The Auto Scaling Group id"
}

output "asg_arn" {
  value       = module.asg_with_launch_template.arn
  description = "The ARN for this Auto Scaling Group"
}

output "asg_availability_zones" {
  value       = module.asg_with_launch_template.availability_zones
  description = "The availability zones of the Auto Scaling Group"
}

output "min_size" {
  value       = module.asg_with_launch_template.min_size
  description = "The minimum size of the Auto Scaling Group"
}

output "max_size" {
  value       = module.asg_with_launch_template.max_size
  description = "The maximum size of the Auto Scaling Group"
}

output "default_cooldown" {
  value       = module.asg_with_launch_template.default_cooldown
  description = "Time between a scaling activity and the succeeding scaling activity"
}

output "asg_name" {
  value       = module.asg_with_launch_template.name
  description = "The name of the Auto Scaling Group"
}

output "health_check_grace_period" {
  value       = module.asg_with_launch_template.health_check_grace_period
  description = "Time after instance comes into service before checking health"
}

output "health_check_type" {
  value       = module.asg_with_launch_template.health_check_type
  description = "Controls how health checking is done"
}

output "desired_capacity" {
  value       = module.asg_with_launch_template.desired_capacity
  description = "The number of Amazon EC2 instances that should be running in the group"
}

output "launch_configuration" {
  value       = module.asg_with_launch_template.launch_configuration
  description = "The launch configuration of the Auto Scaling Group"
}

# Outputs for Autoscaling policy
output "autoscaling_policy_arn" {
  description = "The ARN assigned by AWS to the scaling policy."
  value       = module.asg_with_launch_template.autoscaling_policy_arn
}

output "autoscaling_policy_name" {
  description = "The scaling policy's name."
  value       = module.asg_with_launch_template.autoscaling_policy_name
}

output "adjustment_type" {
  description = "The scaling policy's adjustment type."
  value       = module.asg_with_launch_template.adjustment_type
}

output "policy_type" {
  description = "The scaling policy's type."
  value       = module.asg_with_launch_template.policy_type
}

output "asg_launch_template_arn" {
  value       = module.asg_with_launch_template[*].asg_launch_template_arn
  description = "Amazon Resource Name (ARN) of the launch template"
}

output "asg_launch_template_id" {
  value       = module.asg_with_launch_template[*].asg_launch_template_id
  description = "The ID of the launch template"
}

output "asg_launch_template_latest_version" {
  value       = module.asg_with_launch_template[*].asg_launch_template_latest_version
  description = "The latest version of the launch template"
}

