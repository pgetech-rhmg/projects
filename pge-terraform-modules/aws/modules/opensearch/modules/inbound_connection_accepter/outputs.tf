output "aws_opensearch_inbound_connection_accepter_id" {
  description = "Connection accepter ID"
  value       = aws_opensearch_inbound_connection_accepter.connection_accepter.id
}

output "aws_opensearch_inbound_connection_accepter_status" {
  description = "Connection accepter status"
  value       = aws_opensearch_inbound_connection_accepter.connection_accepter.connection_status
}

output "aws_opensearch_inbound_connection_accepter_all" {
  description = "Map of all Inbound Connection accepter attributes"
  value       = aws_opensearch_inbound_connection_accepter.connection_accepter
}