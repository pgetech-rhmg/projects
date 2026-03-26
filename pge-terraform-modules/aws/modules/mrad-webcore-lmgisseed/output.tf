output "s3_object_hash" {
  value = data.aws_s3_object.lambda_zip.checksum_sha256
}