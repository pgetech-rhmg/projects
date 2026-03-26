# Outputs for Model Package Group Policy

output "model_package_group_policy_id" {
  description = "The name of the Model Package Package Group."
  value       = aws_sagemaker_model_package_group_policy.model_package_group_policy.id
}

output "sagemaker_model_package_group_policy_all" {
  description = "A map of aws sagemaker model package group policy"
  value       = aws_sagemaker_model_package_group_policy.model_package_group_policy
}