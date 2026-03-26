# Outputs for Glue Crawler

output "crawler_id" {
  description = "Crawler name"
  value       = aws_glue_crawler.glue_crawler.id
}

output "crawler_arn" {
  description = "The ARN of the crawler"
  value       = aws_glue_crawler.glue_crawler.arn
}

output "crawler_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = aws_glue_crawler.glue_crawler.tags_all
}

output "aws_glue_crawler" {
  description = "A map of aws_glue_crawler"
  value       = aws_glue_crawler.glue_crawler
}