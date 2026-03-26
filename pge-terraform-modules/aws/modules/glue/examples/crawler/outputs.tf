# Outputs for Glue Crawler

output "crawler_s3_id" {
  description = "Crawler name"
  value       = module.crawler_s3.crawler_id
}

output "crawler_s3_arn" {
  description = "The ARN of the crawler"
  value       = module.crawler_s3.crawler_arn
}

output "crawler_s3_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = module.crawler_s3.crawler_tags_all
}

output "crawler_dynamodb_id" {
  description = "Crawler name"
  value       = module.crawler_dynamodb.crawler_id
}

output "crawler_dynamodb_arn" {
  description = "The ARN of the crawler"
  value       = module.crawler_dynamodb.crawler_arn
}

output "crawler_dynamodb_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = module.crawler_dynamodb.crawler_tags_all
}