output "id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket_website_configuration.default.id
}

output "website_domain" {
  description = "The domain of the website endpoint. This is used to create Route 53 alias records"
  value       = aws_s3_bucket_website_configuration.default.website_domain
}

output "website_endpoint" {
  description = "The website endpoint"
  value       = aws_s3_bucket_website_configuration.default.website_endpoint
}


output "aws_s3_bucket_replication_configuration_all" {
  description = "Map of all attributes of s3_bucket_replication_website_all"
  value       = aws_s3_bucket_website_configuration.default
}