###############################################################################
# Outputs
###############################################################################

output "instance_id" {
  value = module.ec2.instance_id
}

output "bucket_name" {
  value = module.s3_api.bucket_name
}
