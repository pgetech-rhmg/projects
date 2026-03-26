output "s3" {
  description = "Map of S3 object"
  value       = aws_s3_bucket.default
}

output "id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.default.id
}

output "arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
  value       = aws_s3_bucket.default.arn
}


output "is_dc_public_or_internal" {
  description = "Dataclassification passed"
  value       = local.is_dc_public_or_internal

}

output "is_static_web" {
  description = "is bucketType static web or not"
  value       = local.is_static_web
}