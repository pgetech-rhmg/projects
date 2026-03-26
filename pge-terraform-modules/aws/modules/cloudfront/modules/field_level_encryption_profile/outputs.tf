# #aws_cloudfront_field_level_encryption_profile
output "field_level_encryption_profile_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the Field Level Encryption Profile."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_profile.cf_field_level_encryption_profile : index => value.caller_reference
  }
}

output "field_level_encryption_profile_etag" {
  description = "The current version of the Field Level Encryption Profile."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_profile.cf_field_level_encryption_profile : index => value.etag
  }
}

output "field_level_encryption_profile_id" {
  description = "The identifier for the Field Level Encryption Profile."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_profile.cf_field_level_encryption_profile : index => value.id
  }
}
