output "smb_file_share_id" {
  description = "Amazon Resource Name (ARN) of the SMB File Share."
  value       = aws_storagegateway_smb_file_share.smb_file_share.id
}

output "smb_file_share_arn" {
  description = " Amazon Resource Name (ARN) of the SMB File Share."
  value       = aws_storagegateway_smb_file_share.smb_file_share.arn
}

output "smb_file_share_fileshare_id" {
  description = "ID of the SMB File Share."
  value       = aws_storagegateway_smb_file_share.smb_file_share.fileshare_id
}

output "smb_file_share_path" {
  description = "File share path used by the NFS client to identify the mount point."
  value       = aws_storagegateway_smb_file_share.smb_file_share.path
}

output "smb_file_share_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_storagegateway_smb_file_share.smb_file_share.tags_all
}