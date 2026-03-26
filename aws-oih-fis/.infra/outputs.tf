###############################################################################
# SSM Parameters
###############################################################################
output "fis_primary_az_parameter" {
  description = "SSM Parameter storing the Primary AZ"
  value       = aws_ssm_parameter.fis_primary_az.name
}

output "fis_secondary_az_parameter" {
  description = "SSM Parameter storing the Secondary AZ"
  value       = aws_ssm_parameter.fis_secondary_az.name
}

output "fis_tertiary_az_parameter" {
  description = "SSM Parameter storing the Tertiary AZ"
  value       = aws_ssm_parameter.fis_tertiary_az.name
}

###############################################################################
# IAM
###############################################################################
output "fis_experiment_role_arn" {
  description = "ARN of the FIS Experiment IAM Role"
  value       = module.fis_primary_ec2_stop.aws_iam_role
}

###############################################################################
# Logging
###############################################################################
output "fis_logs_bucket_name" {
  description = "Name of the S3 bucket for FIS logs"
  value       = module.fis_logs_bucket.id
}

output "fis_logs_bucket_arn" {
  description = "ARN of the S3 bucket for FIS logs"
  value       = module.fis_logs_bucket.arn
}

output "fis_log_group_name" {
  description = "Name of the CloudWatch Log Group for FIS experiments"
  value       = aws_cloudwatch_log_group.fis_experiments.name
}

output "fis_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for FIS experiments"
  value       = aws_cloudwatch_log_group.fis_experiments.arn
}

###############################################################################
# FIS Experiment Template IDs
###############################################################################
output "fis_primary_ec2_stop_id" {
  description = "ID of the Primary EC2 Stop experiment template"
  value       = module.fis_primary_ec2_stop.fis_experimental_template.id
}

output "fis_secondary_ec2_stop_id" {
  description = "ID of the Secondary EC2 Stop experiment template"
  value       = module.fis_secondary_ec2_stop.fis_experimental_template.id
}

output "fis_primary_ebs_io_pause_id" {
  description = "ID of the Primary EBS I/O Pause experiment template"
  value       = module.fis_primary_ebs_io_pause.fis_experimental_template.id
}

output "fis_secondary_ebs_io_pause_id" {
  description = "ID of the Secondary EBS I/O Pause experiment template"
  value       = module.fis_secondary_ebs_io_pause.fis_experimental_template.id
}

output "fis_subnet_disrupt_primary_az_id" {
  description = "ID of the Primary AZ Subnet Disruption experiment template"
  value       = module.fis_subnet_disrupt_primary_az.fis_experimental_template.id
}

output "fis_subnet_disrupt_secondary_az_id" {
  description = "ID of the Secondary AZ Subnet Disruption experiment template"
  value       = module.fis_subnet_disrupt_secondary_az.fis_experimental_template.id
}

output "fis_subnet_disrupt_tertiary_az_id" {
  description = "ID of the Tertiary AZ Subnet Disruption experiment template"
  value       = module.fis_subnet_disrupt_tertiary_az.fis_experimental_template.id
}

###############################################################################
# Test Harness
###############################################################################
output "test_vpc_lambda_arn" {
  description = "ARN of VPC-attached Lambda (will be isolated during disruption)"
  value       = module.test_vpc_lambda.lambda_arn
}

output "test_regional_lambda_arn" {
  description = "ARN of Regional Lambda (should NOT be affected by disruption)"
  value       = module.test_regional_lambda.lambda_arn
}

output "test_ec2_instance_id" {
  description = "Instance ID of the test EC2 instance"
  value       = module.test_ec2.ec2_id
}

output "test_security_group_id" {
  description = "Security group ID for test harness resources"
  value       = module.test_harness_sg.id
}
