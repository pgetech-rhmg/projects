output "website_address" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web.website_address
}

output "github_repo_url" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web.github_repo_url
}

output "github_branch" {
  description = "alternate domain name for cloudfront distribution"
  value       = module.s3web.github_branch
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = module.s3web.cloudfront_distribution_id
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value       = module.s3web.s3_bucket_id
}

output "s3web_type" {
  description = "s3web_type for the codepipeline"
  value       = module.s3web.s3web_type
}

output "codepipeline_angular_arn" {
  value       = module.s3web.codepipeline_angular_arn
  description = "The codepipeline ARN"
}

output "codepipeline_html_arn" {
  value       = module.s3web.codepipeline_html_arn
  description = "The codepipeline ARN"
}

output "codepipeline_react_arn" {
  value       = module.s3web.codepipeline_react_arn
  description = "The codepipeline ARN"
}

output "acm_certificate_arn" {
  value       = module.s3web.acm_certificate_arn
  description = "acm certificate ARN "
}


