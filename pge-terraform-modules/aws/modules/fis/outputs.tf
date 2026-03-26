output "fis_experimental_template" {
  description = "Outputs the experimental template resource for AWS Fault Injection Simulator (FIS)."
  value       = aws_fis_experiment_template.experiment_template
}

output "aws_iam_role" {
  description = "Outputs the IAM role resource used for AWS Fault Injection Simulator (FIS) operations."
  value       = module.fis_role[*].arn
}

