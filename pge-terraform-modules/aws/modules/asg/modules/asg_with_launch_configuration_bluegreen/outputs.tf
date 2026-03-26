# Outputs for Autoscaling group
output "id" {
  value       = aws_autoscaling_group.asg.id
  description = "The Auto Scaling Group id"
}

output "arn" {
  value       = aws_autoscaling_group.asg.arn
  description = "The ARN for this Auto Scaling Group"
}

output "availability_zones" {
  value       = aws_autoscaling_group.asg.availability_zones
  description = "The availability zones of the Auto Scaling Group"
}

output "min_size" {
  value       = aws_autoscaling_group.asg.min_size
  description = "The minimum size of the Auto Scaling Group"
}

output "max_size" {
  value       = aws_autoscaling_group.asg.max_size
  description = "The maximum size of the Auto Scaling Group"
}

output "default_cooldown" {
  value       = aws_autoscaling_group.asg.default_cooldown
  description = "Time between a scaling activity and the succeeding scaling activity"
}

output "name" {
  value       = aws_autoscaling_group.asg.name
  description = "The name of the Auto Scaling Group"
}

output "health_check_grace_period" {
  value       = aws_autoscaling_group.asg.health_check_grace_period
  description = "Time after instance comes into service before checking health"
}

output "health_check_type" {
  value       = aws_autoscaling_group.asg.health_check_type
  description = "Controls how health checking is done"
}

output "desired_capacity" {
  value       = aws_autoscaling_group.asg.desired_capacity
  description = "The number of Amazon EC2 instances that should be running in the group"
}

output "launch_configuration" {
  value       = aws_autoscaling_group.asg.launch_configuration
  description = "The launch configuration of the Auto Scaling Group"
}

output "vpc_zone_identifier" {
  value       = aws_autoscaling_group.asg.vpc_zone_identifier
  description = "The VPC zone identifier"
}

# Outputs for Autoscaling policy
output "autoscaling_policy_arn" {
  value       = aws_autoscaling_policy.autoscaling_policy.arn
  description = "The ARN assigned by AWS to the scaling policy."
}

output "autoscaling_policy_name" {
  value       = aws_autoscaling_policy.autoscaling_policy.name
  description = "The scaling policy's name."
}

output "adjustment_type" {
  value       = aws_autoscaling_policy.autoscaling_policy.adjustment_type
  description = "The scaling policy's adjustment type."
}

output "policy_type" {
  value       = aws_autoscaling_policy.autoscaling_policy.policy_type
  description = "The scaling policy's type."
}

# Outputs for Launch configuration
output "launch_config_id" {
  value       = aws_launch_configuration.launch_configuration.id
  description = "The Auto Scaling Group id"
}

output "launch_config_arn" {
  value       = aws_launch_configuration.launch_configuration.arn
  description = "The ARN for this Auto Scaling Group"
}

output "launch_config_name" {
  value       = aws_launch_configuration.launch_configuration.name
  description = "The name of the Auto Scaling Group"
}

output "asg_autoscaling_group" {
  description = "Map of ASG group object"
  value       = aws_autoscaling_group.asg
}

output "asg_launch_configuration" {
  description = "Map of ASG launch configuration object"
  value       = aws_launch_configuration.launch_configuration
}

output "asg_autoscaling_policy" {
  description = "Map of ASG policy object"
  value       = aws_autoscaling_policy.autoscaling_policy
}

