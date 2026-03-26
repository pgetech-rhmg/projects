output "ssm_document_all" {
  description = "The map of all atributes"
  value       = aws_ssm_document.ssm_document
}

output "created_date" {
  description = "The date the document was created."
  value       = aws_ssm_document.ssm_document.created_date
}

output "description" {
  description = "The description of the SSM document."
  value       = aws_ssm_document.ssm_document.description
}

output "schema_version" {
  description = "The schema version of the document."
  value       = aws_ssm_document.ssm_document.schema_version
}

output "default_version" {
  description = "The default version of the document."
  value       = aws_ssm_document.ssm_document.default_version
}

output "document_version" {
  description = "The document version."
  value       = aws_ssm_document.ssm_document.document_version
}

output "hash" {
  description = "The sha1 or sha256 of the document content"
  value       = aws_ssm_document.ssm_document.hash
}

output "hash_type" {
  description = "The hashing algorithm used when hashing the content."
  value       = aws_ssm_document.ssm_document.hash_type
}

output "latest_version" {
  description = "The latest version of the document."
  value       = aws_ssm_document.ssm_document.latest_version
}

output "owner" {
  description = "The AWS user account of the person who created the document."
  value       = aws_ssm_document.ssm_document.owner
}

output "status" {
  description = "The current status of the document."
  value       = aws_ssm_document.ssm_document.status
}

output "parameter" {
  description = "The parameters that are available to this document."
  value       = aws_ssm_document.ssm_document.parameter
}

output "platform_types" {
  description = "A list of OS platforms compatible with this SSM document, either 'Windows' or 'Linux'."
  value       = aws_ssm_document.ssm_document.platform_types
}

output "id" {
  description = "The default version of the document."
  value       = aws_ssm_document.ssm_document.id
}