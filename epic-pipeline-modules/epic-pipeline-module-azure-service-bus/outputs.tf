output "namespace_id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Resource ID of the Service Bus namespace"
}

output "namespace_name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Name of the Service Bus namespace"
}

output "default_primary_connection_string" {
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  description = "Primary connection string of the namespace's default RootManageSharedAccessKey rule"
  sensitive   = true
}

output "default_primary_key" {
  value       = azurerm_servicebus_namespace.this.default_primary_key
  description = "Primary key of the namespace's default RootManageSharedAccessKey rule"
  sensitive   = true
}

output "queue_ids" {
  value       = { for name, q in azurerm_servicebus_queue.this : name => q.id }
  description = "Map of queue name to resource ID"
}

output "queue_names" {
  value       = [for q in azurerm_servicebus_queue.this : q.name]
  description = "Names of the created queues"
}
