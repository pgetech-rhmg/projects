output "id" {
  description = "Amazon Resource Name (ARN) of the gateway."
  value       = module.fsx_filesystem.id
}

output "arn" {
  description = "Amazon Resource Name (ARN) of the gateway."
  value       = module.fsx_filesystem.arn
}

output "gateway_id" {
  description = "Identifier of the gateway."
  value       = module.fsx_filesystem.gateway_id
}

output "ec2_instance_id" {
  description = "The ID of the Amazon EC2 instance that was used to launch the gateway."
  value       = module.fsx_filesystem.ec2_instance_id
}

output "endpoint_type" {
  description = "The type of endpoint for your gateway."
  value       = module.fsx_filesystem.endpoint_type
}

output "host_environment" {
  description = "The type of hypervisor environment used by the host."
  value       = module.fsx_filesystem.host_environment
}

output "gateway_network_interface" {
  description = "An array that contains descriptions of the gateway network interfaces."
  value       = module.fsx_filesystem.gateway_network_interface
}

output "cache_id" {
  description = "Combined gateway Amazon Resource Name (ARN) and local disk identifier."
  value       = module.fsx_filesystem_cache.cache_id
}

# output "ipv4_address" {
#   description = "The Internet Protocol version 4 (IPv4) address of the interface."
#   value       = aws_storagegateway_gateway.example.ipv4_address
# }

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.fsx_filesystem.tags_all
}