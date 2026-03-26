output "saml_all" {
  value       = aws_opensearch_domain_saml_options.saml
  description = "Map of all Opensearch Domain SAML attributes"
}

output "saml_id" {
  value       = aws_opensearch_domain_saml_options.saml.id
  description = "Opensearch Domain SAML options ID"
}