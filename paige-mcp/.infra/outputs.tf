###############################################################################
# Outputs
###############################################################################

output "instance_id" {
  value = module.ec2.instance_id
}

output "bucket_name" {
  value = module.s3_mcp.bucket_name
}
