output "iam_policy" {
  description = "Map of IAM Policy object"
  value       = aws_iam_policy.default
}

output "id" {
  description = "The policy's ID"
  value       = aws_iam_policy.default.id
}

output "arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = aws_iam_policy.default.arn
}

output "description" {
  description = "The description of the policy"
  value       = aws_iam_policy.default.description
}

output "name" {
  description = "The name of the policy"
  value       = aws_iam_policy.default.name
}

output "path" {
  description = "The path of the policy in IAM"
  value       = aws_iam_policy.default.path
}

output "policy" {
  description = "The policy document"
  value       = aws_iam_policy.default.policy
}
