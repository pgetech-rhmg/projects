output "notebook_id" {
  description = "The name of the notebook instance."
  value       = module.notebook_instance.notebook_id
}

output "notebook_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this notebook instance."
  value       = module.notebook_instance.notebook_arn
}

output "notebook_url" {
  description = "The URL that you use to connect to the Jupyter notebook that is running in your notebook instance."
  value       = module.notebook_instance.notebook_url
}

output "notebook_interface_id" {
  description = "The network interface ID that Amazon SageMaker created at the time of creating the instance. Only available when setting subnet_id."
  value       = module.notebook_instance.notebook_interface_id
}