#outputs for image version

output "id" {
  description = "The name of the Image."
  value       = module.sagemaker_image_version.image_version_id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Image Version."
  value       = module.sagemaker_image_version.image_version_arn
}

output "image_arn" {
  description = "The Amazon Resource Name (ARN) of the image the version is based on."
  value       = module.sagemaker_image_version.image_version_image_arn
}

output "container_image" {
  description = "The registry path of the container image that contains this image version."
  value       = module.sagemaker_image_version.image_version_container_image
}