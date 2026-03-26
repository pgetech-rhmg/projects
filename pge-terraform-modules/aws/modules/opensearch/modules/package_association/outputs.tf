output "aws_opensearch_package_association_id" {
  description = "Unique ID of the package association"
  value       = aws_opensearch_package_association.package_association.id
}

output "aws_opensearch_package_association_all" {
  description = "Map of all package association attributes"
  value       = aws_opensearch_package_association.package_association
}