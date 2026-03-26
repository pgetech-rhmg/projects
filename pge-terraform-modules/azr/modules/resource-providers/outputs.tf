output "registered_providers" {
  description = "List of resource providers"
  value       = var.resource_providers
}

output "provider_registration_note" {
  description = "Information about how this module handles resource provider registration"
  value       = "This module attempts to register the specified resource providers in the target subscription using Azure Resource Manager. Azure may also automatically register some providers during the subscription lifecycle, but you should verify registration status for required providers as needed."
}

# Exposes DNS-related configuration derived from var.custom_dns_servers for use by downstream modules.
# This module does not apply DNS settings itself; consumer modules (for example, VNet modules) can read this output
# to decide whether and how to configure custom DNS servers on their own resources.
output "dns_configuration" {
  description = "DNS server configuration"
  value = {
    custom_dns_servers = var.custom_dns_servers
    dns_configured     = length(var.custom_dns_servers) > 0
  }
}
