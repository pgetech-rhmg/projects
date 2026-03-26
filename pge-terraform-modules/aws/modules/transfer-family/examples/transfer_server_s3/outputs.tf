#Outputs for transfer family server
output "transfer_server_arn" {
  description = "Amazon Resource Name (ARN) of Transfer Server."
  value       = module.transfer_server.transfer_server_arn
}

output "transfer_server_id" {
  description = "The Server ID of the Transfer Server."
  value       = module.transfer_server.transfer_server_id
}

output "transfer_server_endpoint" {
  description = "The endpoint of the Transfer Server."
  value       = module.transfer_server.transfer_server_endpoint
}

output "transfer_server_host_key_fingerprint" {
  description = "This value contains the message-digest algorithm (MD5) hash of the server's host key. This value is equivalent to the output of the ssh-keygen -l -E md5 -f my-new-server-key command."
  value       = module.transfer_server.transfer_server_host_key_fingerprint
}

output "transfer_server_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.transfer_server.transfer_server_tags_all
}

#Outputs for transfer family workflow
output "transfer_workflow_arn" {
  description = "The Workflow ARN."
  value       = module.transfer_workflow.transfer_workflow_arn
}

output "transfer_workflow_id" {
  description = "The Workflow id."
  value       = module.transfer_workflow.transfer_workflow_id
}

output "transfer_workflow_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.transfer_workflow.transfer_workflow_tags_all
}

#Outputs for transfer family access
output "transfer_access_id" {
  description = "The ID of the resource."
  value       = module.transfer_access.transfer_access_id
}