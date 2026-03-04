###############################################################################
# Outputs
###############################################################################

output "instance_id" {
  value = module.ec2.instance_id
}

output "private_ip" {
  value = module.ec2.private_ip
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}
