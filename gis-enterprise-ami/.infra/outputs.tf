###############################################################################
# Outputs
#
# These are published as the terraform-outputs artifact by EPIC's infra stage.
# The AMI build/deploy stages don't consume Terraform outputs directly — they
# read from epic.json and SSM — but these are useful for visibility and for
# downstream consumers that provision instances from the built AMIs.
###############################################################################

output "ami_kms_key_arn" {
  description = "KMS key ARN used to encrypt built AMIs."
  value       = aws_kms_key.amis.arn
}

output "image_builder_log_bucket" {
  description = "S3 bucket for Image Builder logs."
  value       = aws_s3_bucket.image_builder_logs.id
}

output "esri_assets_bucket" {
  description = "S3 bucket for ESRI installation assets."
  value       = aws_s3_bucket.esri_assets.id
}

output "image_builder_security_group_id" {
  description = "Security group ID for Image Builder instances."
  value       = aws_security_group.image_builder.id
}

output "image_builder_instance_profile" {
  description = "IAM instance profile for Image Builder."
  value       = aws_iam_instance_profile.image_builder.name
}

output "pipeline_arns" {
  description = "Map of component name to Image Builder pipeline ARN."
  value = {
    for name, mod in module.image_builder : name => mod.pipeline_arn
  }
}
