#Outputs for image version

output "image_version_id" {
  description = "The name of the Image."
  value       = aws_sagemaker_image_version.image_version.id
}

output "image_version_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Image Version."
  value       = aws_sagemaker_image_version.image_version.arn
}

output "image_version_image_arn" {
  description = "The Amazon Resource Name (ARN) of the image the version is based on."
  value       = aws_sagemaker_image_version.image_version.image_arn
}

output "image_version_container_image" {
  description = "The registry path of the container image that contains this image version."
  value       = aws_sagemaker_image_version.image_version.container_image
}

output "sagemaker_image_version_all" {
  description = "A map of aws sagemaker image version"
  value       = aws_sagemaker_image_version.image_version
}