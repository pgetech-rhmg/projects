output "pipeline_arn" {
  description = "ARN of the image builder pipeline"
  value       = aws_imagebuilder_image_pipeline.this.arn
}

output "pipeline_name" {
  description = "Name of the image builder pipeline"
  value       = aws_imagebuilder_image_pipeline.this.name
}

output "image_recipe_arn" {
  description = "ARN of the image recipe"
  value       = aws_imagebuilder_image_recipe.this.arn
}
