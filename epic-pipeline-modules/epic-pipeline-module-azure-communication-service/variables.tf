variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "communication_service_name" {
  type        = string
  description = "Name of the Azure Communication Services resource"
}

variable "email_service_name" {
  type        = string
  description = "Name of the Email Communication Service resource"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "data_location" {
  type        = string
  description = "Geography where the service stores data at rest"
  default     = "United States"
}

variable "domain_name" {
  type        = string
  description = "Email domain name. Use \"AzureManagedDomain\" for a free *.azurecomm.net sender domain."
  default     = "AzureManagedDomain"
}

variable "domain_management" {
  type        = string
  description = "How the sender domain is managed"
  default     = "AzureManaged"

  validation {
    condition     = contains(["AzureManaged", "CustomerManaged", "CustomerManagedInExchangeOnline"], var.domain_management)
    error_message = "domain_management must be one of: AzureManaged, CustomerManaged, CustomerManagedInExchangeOnline"
  }
}
