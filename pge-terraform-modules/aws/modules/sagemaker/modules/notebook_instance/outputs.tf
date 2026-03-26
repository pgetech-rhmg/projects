output "notebook_id" {
  description = "The name of the notebook instance."
  value       = aws_sagemaker_notebook_instance.ni.id
}

output "notebook_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this notebook instance."
  value       = aws_sagemaker_notebook_instance.ni.arn
}

output "notebook_url" {
  description = "The URL that you use to connect to the Jupyter notebook that is running in your notebook instance."
  value       = aws_sagemaker_notebook_instance.ni.url
}

output "notebook_interface_id" {
  description = "The network interface ID that Amazon SageMaker created at the time of creating the instance. Only available when setting subnet_id."
  value       = aws_sagemaker_notebook_instance.ni.network_interface_id
}

output "sagemaker_notebook_instance_all" {
  description = "A map of aws sagemaker notebook instance"
  value       = aws_sagemaker_notebook_instance.ni
}