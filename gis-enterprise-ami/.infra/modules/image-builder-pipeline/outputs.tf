output "pipeline_arn" {
  description = "Image Builder pipeline ARN."
  value       = aws_imagebuilder_image_pipeline.this.arn
}

output "recipe_arn" {
  description = "Image Builder recipe ARN."
  value       = aws_imagebuilder_image_recipe.this.arn
}
