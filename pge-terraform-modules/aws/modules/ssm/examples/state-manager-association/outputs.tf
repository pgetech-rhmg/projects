output "platform_types" {
  description = "A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'."
  value       = module.ssm-document.platform_types
}

output "owner" {
  description = "The AWS user account of the person who created the document."
  value       = module.ssm-document.owner
}

output "schema_version" {
  description = "The schema version of the document."
  value       = module.ssm-document.schema_version
}

output "default_version" {
  description = "The default version of the document."
  value       = module.ssm-document.default_version
}

output "document_version" {
  description = "The document version."
  value       = module.ssm-document.document_version
}

output "ssm_state_association_id" {
  description = "The document version."
  value       = module.ssm_association.id
}

output "ssm_state_association_s3_bucket" {
  description = "The document version."
  value       = module.ssm_association.s3_bucket_name
}

output "patch_baseline_all" {
  description = "The patch baseline all."
  value       = module.ssm-patch-manager-baseline.patch_baseline_all
}