output "acm_certificate_id" {
  value       = module.acm_public_certificate.acm_certificate_id
  description = "The ARN of the certificate"
}

output "acm_certificate" {
  value       = module.acm_public_certificate.acm_certificate
  description = "The ARN of the certificate"
  sensitive   = true
}

output "route53_record" {
  value       = module.acm_public_certificate.acm_certificate_validation
  description = "Map of the route53 record"
  sensitive   = true
}

output "acm_certificate_validation" {
  value       = module.acm_public_certificate.acm_certificate_validation
  description = "Map of the acm cert validation object"
  sensitive   = true
}

output "acm_certificate_arn" {
  value       = module.acm_public_certificate.acm_certificate_arn
  description = "The ARN of the certificate"
}

output "acm_certificate_domain_name" {
  value       = module.acm_public_certificate.acm_certificate_domain_name
  description = "The domain name for which the certificate is issued"
}

output "acm_certificate_domain_validation_options" {
  value       = module.acm_public_certificate.acm_certificate_domain_validation_options
  description = "Set of domain validation objects which can be used to complete certificate validation"
}

output "acm_certificate_status" {
  value       = module.acm_public_certificate.acm_certificate_status
  description = "Status of the certificate"
}

output "acm_certificate_tags_all" {
  value       = module.acm_public_certificate.acm_certificate_tags_all
  description = "A map of tags assigned to the resource"
}

output "certificate_validation_id" {
  value       = module.acm_public_certificate.certificate_validation_id
  description = "The time at which the certificate was issued"
}
