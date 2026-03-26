output "cloudfront_origin_access_control_all" {
  description = "Map of cloudfront origin access control resource."
  value       = aws_cloudfront_origin_access_control.default

}

output "cloudfront_origin_access_control_id" {
  description = "The ID of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.default.id
}

output "cloudfront_origin_access_control_arn" {
  description = "The ARN of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.default.arn
}

output "cloudfront_origin_access_control_signing_behavior" {
  description = "The signing behavior of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.default.signing_behavior
}

output "cloudfront_origin_access_control_signing_protocol" {
  description = "The signing protocol of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.default.signing_protocol
}
output "cloudfront_origin_access_control_origin_type" {
  description = "The origin type of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.default.origin_access_control_origin_type
}