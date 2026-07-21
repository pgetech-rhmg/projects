resource "azurerm_communication_service" "this" {
  name                = var.communication_service_name
  resource_group_name = var.resource_group_name

  data_location = var.data_location

  tags = var.tags
}

resource "azurerm_email_communication_service" "this" {
  name                = var.email_service_name
  resource_group_name = var.resource_group_name

  data_location = var.data_location

  tags = var.tags
}

# Azure-managed domain (free *.azurecomm.net sender). Set var.domain_management
# to "CustomerManaged" and add the DNS records out-of-band for a custom domain.
resource "azurerm_email_communication_service_domain" "this" {
  name             = var.domain_name
  email_service_id = azurerm_email_communication_service.this.id

  domain_management = var.domain_management
}
