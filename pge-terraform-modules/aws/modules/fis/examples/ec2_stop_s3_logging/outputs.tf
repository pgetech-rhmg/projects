output "fis_experimental_template" {
  description = "Outputs the experimental template resource for AWS Fault Injection Simulator (FIS)."
  value       = module.fis_experimental_template.fis_experimental_template
}

output "s3_fis_log_bucket" {
  description = "Outputs the S3 bucket resource used for storing logs related to AWS Fault Injection Simulator (FIS)."
  value       = module.s3_fis_log_bucket
}

output "aws_iam_role" {
  description = "Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations."
  value       = module.fis_experimental_template.aws_iam_role
}