#Outputs for transfer family server
output "transfer_server_arn" {
  description = "Amazon Resource Name (ARN) of Transfer Server."
  value       = aws_transfer_server.transfer_server.arn
}

output "transfer_server_id" {
  description = "The Server ID of the Transfer Server."
  value       = aws_transfer_server.transfer_server.id
}

output "transfer_server_endpoint" {
  description = "The endpoint of the Transfer Server."
  value       = aws_transfer_server.transfer_server.endpoint
}

output "transfer_server_host_key_fingerprint" {
  description = "This value contains the message-digest algorithm (MD5) hash of the server's host key. This value is equivalent to the output of the ssh-keygen -l -E md5 -f my-new-server-key command."
  value       = aws_transfer_server.transfer_server.host_key_fingerprint
}

output "transfer_server_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_transfer_server.transfer_server.tags_all
}

output "transfer_server_all" {
  description = "Map of transfer_server object"
  value       = aws_transfer_server.transfer_server
}
