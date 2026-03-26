output "iam_role" {
  description = "Map of IAM Role object"
  value       = aws_iam_role.default
}

output "name" {
  value       = aws_iam_role.default.name
  description = "The name of the IAM role created"
}

output "id" {
  value       = aws_iam_role.default.unique_id
  description = "The stable and unique string identifying the role"
}

output "arn" {
  value       = aws_iam_role.default.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "create_date" {
  value       = aws_iam_role.default.create_date
  description = "The creation date of the IAM role"
}

output "description" {
  description = "The description of the role."
  value       = aws_iam_role.default.description
}

output "path" {
  description = "The path of the role in IAM"
  value       = aws_iam_role.default.path
}