output "origin_access_identity_id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.id
}

output "origin_access_identity_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the origin access identity."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.caller_reference
}

output "origin_access_identity_all" {
  description = "Map of all origin_access_identity attributes"
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity
}

output "origin_access_identity_cloudfront_access_identity_path" {
  description = "A shortcut to the full path for the origin access identity to use in CloudFront."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.cloudfront_access_identity_path
}

output "origin_access_identity_etag" {
  description = "The current version of the origin access identity's information."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.etag
}

output "origin_access_identity_iam_arn" {
  description = "A pre-generated ARN for use in S3 bucket policies."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.iam_arn
}

output "origin_access_identity_s3_canonical_user_id" {
  description = "The Amazon S3 canonical user ID for the origin access identity, which you use when giving the origin access identity read permission to an object in Amazon S3."
  value       = aws_cloudfront_origin_access_identity.cf_origin_access_identity.s3_canonical_user_id
}
