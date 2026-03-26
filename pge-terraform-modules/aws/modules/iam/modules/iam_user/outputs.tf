output "iam_user" {
  description = "Map of IAM User object"
  value       = aws_iam_user.default
}

output "name" {
  description = "The user's name"
  value       = aws_iam_user.default.name
}

output "arn" {
  description = "The ARN assigned by AWS for this user"
  value       = aws_iam_user.default.arn
}

output "unique_id" {
  description = "The unique ID assigned by AWS"
  value       = aws_iam_user.default.unique_id
}
