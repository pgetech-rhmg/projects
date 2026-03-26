output "acm_arn" {
  value = module.acm_public_certificate.acm_certificate_arn
}

output "acm_certificate_id" {
  value = module.acm_public_certificate.acm_certificate_id
}

output "url" {
  value = module.r53.fqdn
}

output "lb_id" {
  value = module.alb.lb_id
}

output "lb_dns_name" {
  value = module.alb.lb_dns_name
}

output "target_group_id" {
  value = module.alb.target_group_id
}

output "asg_id" {
  value = module.asg_with_launch_template.id
}

output "launch_template_id" {
  value = module.asg_with_launch_template.asg_launch_template_id
}

# added for ec2web_scheduled submodule
output "asg_name" {
  value = module.asg_with_launch_template.name
}