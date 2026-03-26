output "cloudfront_function_arn" {
  description = "Amazon Resource Name (ARN) identifying your CloudFront Function."
  value       = aws_cloudfront_function.cf_function.arn
}

output "cloudfront_function_all" {
  description = "Map of all cloudfront_function attributes"
  value       = aws_cloudfront_function.cf_function
}

output "cloudfront_function_etag" {
  description = " ETag hash of the function. This is the value for the DEVELOPMENT stage of the function."
  value       = aws_cloudfront_function.cf_function.etag
}

output "cloudfront_function_live_stage_etag" {
  description = "ETag hash of any LIVE stage of the function."
  value       = aws_cloudfront_function.cf_function.live_stage_etag
}

output "cloudfront_function_status" {
  description = "Status of the function."
  value       = aws_cloudfront_function.cf_function.status
}

