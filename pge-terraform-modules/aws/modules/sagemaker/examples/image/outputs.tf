output "id" {
  description = "The name of the Image."
  value       = module.image.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this Image."
  value       = module.image.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.image.tags_all
}