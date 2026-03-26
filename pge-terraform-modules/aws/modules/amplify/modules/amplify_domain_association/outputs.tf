# Outputs for Amplify Domain Association

output "arn" {
  description = "ARN for the domain_association."
  value       = aws_amplify_domain_association.amplify_domain_association.arn
}

output "certificate_verification_dns_record" {
  description = "The DNS record for certificate verification."
  value       = aws_amplify_domain_association.amplify_domain_association.certificate_verification_dns_record
}

output "sub_domain" {
  description = "DNS record and Verified status for the subdomain."
  value       = aws_amplify_domain_association.amplify_domain_association.sub_domain
}

output "amplify_domain_association_all" {
  description = "A map of aws amplify domain association"
  value       = aws_amplify_domain_association.amplify_domain_association
}