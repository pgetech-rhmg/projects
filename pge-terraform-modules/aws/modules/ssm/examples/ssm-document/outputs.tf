output "created_date" {
  description = "The date the document was created."
  value       = module.ssm-document.created_date
}

output "description" {
  description = "The description of the SSM document."
  value       = module.ssm-document.description
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

output "hash" {
  description = "The sha1 or sha256 of the document content"
  value       = module.ssm-document.hash
}

output "hash_type" {
  description = "The hashing algorithm used when hashing the content."
  value       = module.ssm-document.hash_type
}

output "latest_version" {
  description = "The latest version of the document."
  value       = module.ssm-document.latest_version
}

output "owner" {
  description = "The AWS user account of the person who created the document."
  value       = module.ssm-document.owner
}

output "status" {
  description = "The current status of the document."
  value       = module.ssm-document.status
}

output "parameter" {
  description = "The parameters that are available to this document."
  value       = module.ssm-document.parameter
}

output "platform_types" {
  description = "A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'."
  value       = module.ssm-document.platform_types
}
