output "certificate_arn" {
  description = "The ARN of the validated ACM certificate."
  value       = var.certificate_type == "public" ? aws_acm_certificate_validation.public[0].certificate_arn : aws_acm_certificate_validation.default[0].certificate_arn
}

output "certificate_domain_name" {
  description = "The primary domain name of the ACM certificate."
  value       = var.certificate_type == "public" ? aws_acm_certificate.public[0].domain_name : aws_acm_certificate.default[0].domain_name
}

output "certificate_status" {
  description = "The status of the ACM certificate."
  value       = var.certificate_type == "public" ? aws_acm_certificate.public[0].status : aws_acm_certificate.default[0].status
}

output "validation_record_fqdns" {
  description = "The FQDNs of the DNS validation records created in Route53."
  value       = module.aws_route53_record.validation_record_fqdns
}
