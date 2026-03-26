# #aws_cloudfront_cache_policy
output "cache_policy_etag" {
  description = "The current version of the cache policy."
  value = {
    for index, value in aws_cloudfront_cache_policy.cf_cache_policy : index => value.etag
  }
}

output "cache_policy_id" {
  description = "The identifier for the cache policy."
  value = {
    for index, value in aws_cloudfront_cache_policy.cf_cache_policy : index => value.id
  }
}

# #aws_cloudfront_response_headers_policy
output "response_headers_policy_etag" {
  description = "The current version of the response headers policy."
  value = {
    for index, value in aws_cloudfront_response_headers_policy.cf__response_headers_policy : index => value.etag
  }
}

output "response_headers_policy_id" {
  description = "The identifier for the response headers policy."
  value = {
    for index, value in aws_cloudfront_response_headers_policy.cf__response_headers_policy : index => value.id
  }
}

# #aws_cloudfront_origin_request_policy
output "origin_request_policy_etag" {
  description = "The current version of the origin request policy."
  value = {
    for index, value in aws_cloudfront_origin_request_policy.cf_origin_request_policy : index => value.etag
  }
}

output "origin_request_policy_id" {
  description = "The identifier for the origin request policy."
  value = {
    for index, value in aws_cloudfront_origin_request_policy.cf_origin_request_policy : index => value.id
  }
}