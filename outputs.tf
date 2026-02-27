output "aws_security_group" {
  description = "Map of security group object"
  value       = aws_security_group.default
}

output "aws_security_group_id" {
  description = "security group id"
  value       = aws_security_group.default.id
}

output "aws_security_group_arn" {
  description = "security group id"
  value       = aws_security_group.default.arn
}
