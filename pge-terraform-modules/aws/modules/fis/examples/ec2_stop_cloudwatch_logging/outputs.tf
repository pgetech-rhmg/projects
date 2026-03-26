output "fis_experimental_template" {
  description = "Outputs the experimental template resource for AWS Fault Injection Simulator (FIS)."
  value       = module.fis_experimental_template.fis_experimental_template
}

output "aws_iam_role" {
  description = "Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations."
  value       = module.fis_experimental_template.aws_iam_role
}

output "cloudwatch_log_group" {
  description = "Outputs the CloudWatch Log Group created for FIS experiment logging."
  value       = aws_cloudwatch_log_group.this
}