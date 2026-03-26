output "nfs_file_share_id" {
  description = "Amazon Resource Name (ARN) of the NFS File Share."
  value       = aws_storagegateway_nfs_file_share.nfs.id
}

output "nfs_file_share_arn" {
  description = "Amazon Resource Name (ARN) of the NFS File Share."
  value       = aws_storagegateway_nfs_file_share.nfs.arn
}

output "nfs_fileshare_id" {
  description = "ID of the NFS File Share."
  value       = aws_storagegateway_nfs_file_share.nfs.fileshare_id
}

output "nfs_path" {
  description = "File share path used by the NFS client to identify the mount point."
  value       = aws_storagegateway_nfs_file_share.nfs.path
}

output "nfs_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_storagegateway_nfs_file_share.nfs.tags_all
}