################################################################################
# Load Balancer
################################################################################

output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.nlb.id
}

output "arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.nlb.arn
}

output "arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = module.nlb.arn_suffix
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.nlb.dns_name
}

output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.nlb.zone_id
}

################################################################################
# Listener(s)
################################################################################

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = module.nlb.listeners
}

output "listener_rules" {
  description = "Map of listeners rules created and their attributes"
  value       = module.nlb.listener_rules
}

################################################################################
# Target Group(s)
################################################################################

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = module.nlb.target_groups
  sensitive   = true
}

# ################################################################################
# # Security Group
# ################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.nlb_security_group.sg_arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.nlb_security_group.sg_id
}


output "ec2_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the ec2 security group"
  value       = module.ec2_security_group.sg_arn
}

output "ec2_security_group_id" {
  description = "ID of the ec2 security group"
  value       = module.ec2_security_group.sg_id
}

# ################################################################################
# # Route53 Record(s)
# ################################################################################

output "route53_records" {
  description = "The Route53 records created and attached to the load balancer"
  value       = module.records_nlb.fqdn
}

output "route53_records_name" {
  description = "The Route53 records name created and attached to the load balancer"
  value       = module.records_nlb.name
}


################################################################################
# # acm
# ################################################################################

output "acm_certificate" {
  description = "acm certificate"
  value       = module.acm.acm_certificate
  sensitive   = true

}

output "acm_certificate_arn" {
  description = "acm certificate arn"
  value       = module.acm.acm_certificate_arn

}

output "acm_domain_name" {
  description = "acm domain name"
  value       = module.acm.acm_certificate_domain_name

}

################################################################################
# # ec2
# ################################################################################

output "ec2_nlb" {
  description = "ec2 instance used for nlb target group"
  value       = module.ec2.arn

}