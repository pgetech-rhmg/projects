output "infrastructure_configuration" {
  description = "EC2 Image Builder infrastructure configuration. "
  value       = aws_imagebuilder_infrastructure_configuration.imagebuilder_infra_config
}

output "image_builder_img" {
  description = "EC2 Image Builder Image."
  value       = aws_imagebuilder_image.image_builder_img
}

output "image_builder_image_recipe_arn" {
  description = "EC2 Imagebuilder Image Recipe ARN"
  value       = aws_imagebuilder_image_recipe.image_recipe.arn
}

output "imagebuilder_security_group" {
  description = "Imagebuilder security group"
  value       = module.image_builder_sg
}

output "security_group_id" {
  description = "The ID of the security group created for Imagebuilder."
  value       = module.image_builder_sg.sg_id
}

output "iam_instance_profile" {
  description = "EC2 Imagebuilder Instance Profile"
  value       = aws_iam_instance_profile.iam_instance_profile
}

output "imagebuilder_image_pipeline" {
  description = "EC2 Imagebuilder Image Pipeline"
  value       = aws_imagebuilder_image_pipeline.imagebuilder_pipeline
}

output "distribution_configuration" {
  description = "EC2 Imagebuilder distribution configuration"
  value       = aws_imagebuilder_distribution_configuration.without_license[0].arn
}