output "iam_service_linked_roles" {
  description = "Map of IAM Service-linked role objects"
  value       = aws_iam_service_linked_role.default
}

output "name" {
  description = "The name of the IAM role created"
  value = [
    for bd in aws_iam_service_linked_role.default : bd.name
  ]
}

output "id" {
  description = "The Amazon Resource Name (ARN) of the role."
  value = [
    for bd in aws_iam_service_linked_role.default : bd.id
  ]
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value = [
    for bd in aws_iam_service_linked_role.default : bd.arn
  ]
}

output "create_date" {
  description = "The creation date of the IAM role."
  value = [
    for bd in aws_iam_service_linked_role.default : bd.create_date
  ]
}

output "description" {
  description = "The description of the role."
  value = [
    for bd in aws_iam_service_linked_role.default : bd.description
  ]
}

output "path" {
  description = "The path of the role in IAM"
  value = [
    for bd in aws_iam_service_linked_role.default : bd.path
  ]
}