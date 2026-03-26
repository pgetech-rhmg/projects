output "saml_id" {
  description = "Map of all SAML ID"
  value       = module.domain_saml_options[*].saml_id
}