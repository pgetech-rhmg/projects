output "lb_arn" {
  value = module.rolling_ec2.alb_arn
}

output "lb_dns_name" {
  value = module.rolling_ec2.alb_dns_name
}

output "lb_target_group_arn" {
  value = module.rolling_ec2.alb_target_group_arn
}

output "asg_name" {
  value = module.rolling_ec2.asg_name
}

output "lambda_arn" {
  value = module.rolling_ec2.lambda_arn
}

output "latest_ami_parameter_name" {
  value = module.rolling_ec2.latest_ami_parameter_name
}

output "ami_catalog_parameter_name" {
  value = module.rolling_ec2.ami_catalog_parameter_name
}