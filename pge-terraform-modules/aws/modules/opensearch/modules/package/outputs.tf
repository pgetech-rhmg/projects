output "package_id" {
  description = "The Id of the package."
  value       = aws_opensearch_package.package.id
}

output "available_package_version" {
  description = "The current version of the package."
  value       = aws_opensearch_package.package.available_package_version
}

output "aws_opensearch_package_all" {
  description = "Map of all package attributes"
  value       = aws_opensearch_package.package
}