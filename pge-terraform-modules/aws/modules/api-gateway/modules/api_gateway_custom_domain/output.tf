output "custom_domain_name" {
  description = "Custom Domain Name"
  value       = local.custom_domain_name
}

output "acm_certificate_arn" {
  value       = module.acm_public_certificate.acm_certificate_arn
  description = "acm certificate ARN "
}