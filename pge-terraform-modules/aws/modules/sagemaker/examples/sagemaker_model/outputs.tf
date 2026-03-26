output "sagemaker_model_name" {
  description = "The name of the model."
  value       = module.sagemaker_model.sagemaker_model_name
}

output "sagemaker_model_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this model."
  value       = module.sagemaker_model.sagemaker_model_arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.sagemaker_model.tags_all
}