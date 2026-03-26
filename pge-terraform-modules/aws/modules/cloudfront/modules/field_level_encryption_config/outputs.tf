# aws_cloudfront_field_level_encryption_config
output "field_level_encryption_config_caller_reference" {
  description = "Internal value used by CloudFront to allow future updates to the Field Level Encryption Config."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_config.cf_field_level_encryption_config : index => value.caller_reference
  }
}

output "field_level_encryption_config_etag" {
  description = "The current version of the Field Level Encryption Config."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_config.cf_field_level_encryption_config : index => value.etag
  }
}

output "field_level_encryption_config_id" {
  description = "The identifier for the Field Level Encryption Config."
  value = {
    for index, value in aws_cloudfront_field_level_encryption_config.cf_field_level_encryption_config : index => value.id
  }
}
