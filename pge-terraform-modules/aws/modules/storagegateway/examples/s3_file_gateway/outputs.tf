output "id" {
  description = "Amazon Resource Name (ARN) of the gateway."
  value       = module.s3_filesystem.id
}

output "arn" {
  description = "Amazon Resource Name (ARN) of the gateway."
  value       = module.s3_filesystem.arn
}

output "gateway_id" {
  description = "Identifier of the gateway."
  value       = module.s3_filesystem.gateway_id
}

output "ec2_instance_id" {
  description = "The ID of the Amazon EC2 instance that was used to launch the gateway."
  value       = module.s3_filesystem.ec2_instance_id
}

output "endpoint_type" {
  description = "The type of endpoint for your gateway."
  value       = module.s3_filesystem.endpoint_type
}

output "host_environment" {
  description = "The type of hypervisor environment used by the host."
  value       = module.s3_filesystem.host_environment
}

output "gateway_network_interface" {
  description = "An array that contains descriptions of the gateway network interfaces."
  value       = module.s3_filesystem.gateway_network_interface
}

output "cache_id" {
  description = "Combined gateway Amazon Resource Name (ARN) and local disk identifier."
  value       = module.s3_filesystem_cache.cache_id
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.s3_filesystem.tags_all
}

output "nfs_file_share_id" {
  description = "Amazon Resource Name (ARN) of the NFS File Share."
  value       = module.nfs_file_share.nfs_file_share_id
}

output "nfs_file_share_arn" {
  description = "Amazon Resource Name (ARN) of the NFS File Share."
  value       = module.nfs_file_share.nfs_file_share_arn
}

output "nfs_fileshare_id" {
  description = "ID of the NFS File Share."
  value       = module.nfs_file_share.nfs_fileshare_id
}

output "nfs_path" {
  description = "File share path used by the NFS client to identify the mount point."
  value       = module.nfs_file_share.nfs_path
}

output "nfs_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.nfs_file_share.nfs_tags_all
}