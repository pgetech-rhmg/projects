output "name" {
  description = "The user's name"
  value       = module.aws_iam_user.name
}

output "arn" {
  description = "The ARN assigned by AWS for this user"
  value       = module.aws_iam_user.arn
}

output "unique_id" {
  description = "The unique ID assigned by AWS"
  value       = module.aws_iam_user.unique_id
}
