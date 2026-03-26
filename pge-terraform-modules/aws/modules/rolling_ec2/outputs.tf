
# ALB
output "alb_arn" {
  value = module.alb_baseline.lb_arn
}

output "alb_dns_name" {
  value = module.alb_baseline.lb_dns_name
}

output "alb_target_group_arn" {
  value = module.alb_baseline.target_group_arn
}

# ASG
output "asg_name" {
  value = module.asg.name
}


# Lambda

output "lambda_arn" {
  value = module.lambda_s3_bucket.lambda_arn
}

# SSM
output "latest_ami_parameter_name" {
  value = var.latest_ami_param_name
}

output "ami_catalog_parameter_name" {
  value = var.ami_catalog_param_name
}