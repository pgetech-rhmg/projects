output "website_address" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web_html.website_address
}

output "github_repo_url" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web_html.github_repo_url
}

output "github_branch" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web_html.github_branch
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = module.s3web_html.cloudfront_distribution_id
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value       = module.s3web_html.s3_bucket_id
}

output "s3web_type" {
  description = "s3web_type for the codepipeline"
  value       = module.s3web_html.s3web_type
}



output "codepipeline_html_arn" {
  value       = module.s3web_html.codepipeline_html_arn
  description = "The codepipeline ARN"
}


output "acm_certificate_arn" {
  value       = module.s3web_html.acm_certificate_arn
  description = "acm certificate ARN "
}