output "outbound_connection_id" {
  description = "Outbound Connection ID"
  value       = aws_opensearch_outbound_connection.outbound_connection.id
}

output "outbound_connection_connection_status" {
  description = "map of all Outbound Connection Status"
  value       = aws_opensearch_outbound_connection.outbound_connection.connection_status
}

output "outbound_connection_all" {
  description = "Map of all Outbound Connection attributes"
  value       = aws_opensearch_outbound_connection.outbound_connection
}