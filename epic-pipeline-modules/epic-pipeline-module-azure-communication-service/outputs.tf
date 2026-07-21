output "communication_service_id" {
  value       = azurerm_communication_service.this.id
  description = "Resource ID of the Communication Services resource"
}

output "communication_service_name" {
  value       = azurerm_communication_service.this.name
  description = "Name of the Communication Services resource"
}

output "primary_connection_string" {
  value       = azurerm_communication_service.this.primary_connection_string
  description = "Primary connection string for sending via the Communication Services resource"
  sensitive   = true
}

output "email_service_id" {
  value       = azurerm_email_communication_service.this.id
  description = "Resource ID of the Email Communication Service"
}

output "email_domain_id" {
  value       = azurerm_email_communication_service_domain.this.id
  description = "Resource ID of the email domain"
}

output "mail_from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.mail_from_sender_domain
  description = "MAIL FROM sender domain (envelope sender)"
}

output "from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.from_sender_domain
  description = "Sender domain (e.g. <guid>.azurecomm.net) — prefix a local part (DoNotReply@) to form the sender address"
}
