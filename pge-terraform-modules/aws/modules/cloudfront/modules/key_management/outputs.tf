# aws_cloudfront_public_key
output "public_key_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the public key configuration."
  value = {
    for index, value in aws_cloudfront_public_key.cf_public_key : index => value.caller_reference
  }
}

output "public_key_etag" {
  description = "The current version of the public key."
  value = {
    for index, value in aws_cloudfront_public_key.cf_public_key : index => value.etag
  }
}

output "public_key_id" {
  description = "The current version of the public key."
  value = {
    for index, value in aws_cloudfront_public_key.cf_public_key : index => value.id
  }
}

# aws_cloudfront_key_group
output "key_group_etag" {
  description = " The identifier for this version of the key group."
  value = {
    for index, value in aws_cloudfront_key_group.cf_key_group : index => value.etag
  }
}

output "key_group_id" {
  description = "The identifier for the key group."
  value = {
    for index, value in aws_cloudfront_key_group.cf_key_group : index => value.id
  }
}
