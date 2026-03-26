# #aws_cloudfront_distribution
output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = local.cloudfront_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = local.cloudfront_arn

}

output "cloudfront_distribution_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the distribution configuration."
  value       = local.use_existing_cloudfront ? null : aws_cloudfront_distribution.s3_distribution[0].caller_reference

}

output "cloudfront_distribution_status" {
  description = "The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system."
  value       = local.use_existing_cloudfront ? null : aws_cloudfront_distribution.s3_distribution[0].status

}

output "cloudfront_distribution_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = local.use_existing_cloudfront ? null : aws_cloudfront_distribution.s3_distribution[0].tags_all
}


output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = local.cloudfront_domain_name

}

output "cloudfront_distribution_last_modified_time" {
  description = "The date and time the distribution was last modified."
  value       = local.use_existing_cloudfront ? data.aws_cloudfront_distribution.existing[0].last_modified_time : aws_cloudfront_distribution.s3_distribution[0].last_modified_time

}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress."
  value       = local.use_existing_cloudfront ? data.aws_cloudfront_distribution.existing[0].in_progress_validation_batches : aws_cloudfront_distribution.s3_distribution[0].in_progress_validation_batches

}

output "cloudfront_distribution_etag" {
  description = "The current version of the distribution's information."
  value       = local.use_existing_cloudfront ? data.aws_cloudfront_distribution.existing[0].etag : aws_cloudfront_distribution.s3_distribution[0].etag
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value       = module.s3.s3.id
}

output "s3_bucket_arn" {
  description = "s3 ARN. Will be of format arn:aws:s3:::bucketname"
  value       = module.s3.s3.arn
}

output "custom_domain_name" {
  description = "alternate domain name for cloudfront distribution"
  value       = var.custom_domain_name
}

output "s3web_type" {
  description = "s3web_type for the codepipeline"
  value       = var.s3web_type
}

output "codepipeline_angular_arn" {
  value       = local.is_angular ? module.codepipeline_angular[0].codepipeline_arn : null
  description = "The codepipeline ARN"
}

output "codepipeline_html_arn" {
  value       = local.is_html ? module.codepipeline_html[0].codepipeline_arn : null
  description = "The codepipeline ARN"
}

output "codepipeline_react_arn" {
  value       = local.is_react ? module.codepipeline_react[0].codepipeline_arn : null
  description = "The codepipeline ARN"
}

output "acm_certificate_arn" {
  value       = var.existing_cloudfront_distribution_arn == null ? module.acm_public_certificate[0].acm_certificate_arn : null
  description = "acm certificate ARN "
}

output "website_address" {
  description = "alternate domain name for cloudfront distribution"
  value       = "https://${var.custom_domain_name}"
}

output "github_repo_url" {
  description = "alternate domain name for cloudfront distribution"
  value       = var.github_repo_url
}

output "github_branch" {
  description = "alternate domain name for cloudfront distribution"
  value       = var.github_branch
}


output "s3web_all" {
  description = "List of Maps of resources created by the s3web module"
  value = [module.acm_public_certificate, aws_cloudfront_distribution.s3_distribution, aws_cloudfront_function.this,
    module.codepipeline_angular, module.codepipeline_html, module.codepipeline_react, module.external_records, module.records,
    module.s3,
    module.wafv2_ip_set, module.ws,
    aws_shield_protection.this, aws_wafv2_web_acl.this, aws_wafv2_web_acl_logging_configuration.this,
    module.cloudfront_origin_access_control,
    module.s3_custom_bucket_policy
  ]
}

