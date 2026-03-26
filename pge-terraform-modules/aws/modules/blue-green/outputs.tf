########################
# ALB
########################
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb_baseline.lb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb_baseline.lb_dns_name
}

########################
# Target Groups
########################
output "target_group_arns" {
  description = "Target group ARNs for blue and green"
  value       = module.alb_baseline.target_group_arn
}

########################
# ASGs
########################
output "blue_asg_name" {
  description = "Blue Auto Scaling Group name"
  value       = module.asg_blue.name
}

output "green_asg_name" {
  description = "Green Auto Scaling Group name"
  value       = module.asg_green.name
}

########################
# Launch Templates
########################
output "blue_launch_template_name" {
  description = "Launch template name for Blue ASG"
  value       = module.asg_blue.asg_launch_template[0].name
}

output "green_launch_template_name" {
  description = "Launch template name for Green ASG"
  value       = module.asg_green.asg_launch_template[0].name
}

########################
# AMI Selection (Debug / Visibility)
########################
output "green_ami_id" {
  description = "AMI ID used by Green ASG"
  value       = local.selected_ami_id
}

output "blue_ami_id" {
  description = "AMI ID used by Blue ASG"
  value       = local.blue_ami_id
}

########################
# Traffic Control
########################
output "green_traffic_percentage" {
  description = "Percentage of traffic routed to Green"
  value       = var.green_percent
}

########################
# Lambda / Automation
########################
output "lambda_function_arn" {
  description = "AMI automation Lambda ARN"
  value       = module.lambda_lambda_s3_bucket.lambda_arn
}

########################
# SSM Parameters
########################
output "latest_ami_ssm_parameter" {
  description = "SSM parameter name for latest AMI"
  value       = var.latest_ami_param_name
}

output "ami_catalog_ssm_parameter" {
  description = "SSM parameter name for AMI catalog"
  value       = var.ami_catalog_param_name
}