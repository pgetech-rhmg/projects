#outputs for aws_acm_certificate
output "acm_certificate_id" {
  value       = module.acm_private_ca.acm_certificate_id
  description = "The ARN of the certificate"
}

output "acm_certificate_arn" {
  value       = module.acm_private_ca.acm_certificate_arn
  description = "The ARN of the certificate"
}

output "acm_certificate_domain_name" {
  value       = module.acm_private_ca.acm_certificate_domain_name
  description = "The domain name for which the certificate is issued"
}

output "acm_certificate_status" {
  value       = module.acm_private_ca.acm_certificate_status
  description = "Status of the certificate"
}

output "acm_certificate_tags_all" {
  value       = module.acm_private_ca.acm_certificate_tags_all
  description = "A map of tags assigned to the resource"
}