#Outputs for transfer family access
output "transfer_access_id" {
  description = "The ID of the resource."
  value       = aws_transfer_access.transfer_access.id
}

output "transfer_access_all" {
  description = "Map of transfer_access object"
  value       = aws_transfer_access.transfer_access
}


