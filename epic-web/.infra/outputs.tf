###############################################################################
# Outputs
###############################################################################

output "bucket_name" {
  description = "S3 bucket name for static asset deployment (pipeline aws s3 sync target)."
  value       = module.s3_web.bucket_name
}

output "instance_id" {
  description = "EC2 instance ID running nginx — exposed for SSM-based deploy upgrades."
  value       = module.ec2.instance_id
}

output "alb_dns_name" {
  description = "Internal ALB DNS name."
  value       = module.load_balancer_web.alb_dns_name
}
