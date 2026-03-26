output "role_name" {
  value       = module.aws_iam_service_linked_roles.name
  description = "The name of the created role"
}

output "role_id" {
  value       = module.aws_iam_service_linked_roles.id
  description = "The stable and unique string identifying the role"
}

output "role_arn" {
  value       = module.aws_iam_service_linked_roles.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}