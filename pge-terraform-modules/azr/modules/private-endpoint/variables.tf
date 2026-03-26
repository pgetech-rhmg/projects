# Variables for Azure Private Endpoint module

variable "name" {
  type        = string
  description = "Name of the private endpoint"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint"
}

variable "private_connection_resource_id" {
  type        = string
  description = "Resource ID of the service to connect to"
}

variable "subresource_names" {
  type        = list(string)
  description = "Subresource names for the connection (e.g., ['vault'], ['blob'], ['redisCache'])"
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "List of Private DNS Zone IDs for the endpoint"
  default     = []
}

variable "is_manual_connection" {
  type        = bool
  description = "Is this a manual connection requiring approval"
  default     = false
}

variable "request_message" {
  type        = string
  description = "Message for manual connection approval"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
