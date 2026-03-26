output "acm_certificate" {
  value       = aws_acm_certificate.acm_certificate
  description = "Map of the acm certificate"
}

output "acm_certificate_id" {
  value       = aws_acm_certificate.acm_certificate.id
  description = "The ARN of the certificate"
}

output "acm_certificate_arn" {
  value       = aws_acm_certificate.acm_certificate.arn
  description = "The ARN of the certificate"
}

output "acm_certificate_domain_name" {
  value       = aws_acm_certificate.acm_certificate.domain_name
  description = "The domain name for which the certificate is issued"
}

output "acm_certificate_status" {
  value       = aws_acm_certificate.acm_certificate.status
  description = "Status of the certificate"
}

output "acm_certificate_tags_all" {
  value       = aws_acm_certificate.acm_certificate.tags_all
  description = "A map of tags assigned to the resource"
}
