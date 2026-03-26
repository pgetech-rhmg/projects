output "sagemaker_model_name" {
  description = "The name of the model"
  value       = aws_sagemaker_model.sagemaker_model.name
}

output "sagemaker_model_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this model."
  value       = aws_sagemaker_model.sagemaker_model.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_sagemaker_model.sagemaker_model.tags_all
}

output "sagemaker_model_all" {
  description = "A map of aws sagemaker model"
  value       = aws_sagemaker_model.sagemaker_model
}