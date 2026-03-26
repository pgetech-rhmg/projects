output "aws_security_group" {
  description = "Map of security group object"
  value       = aws_security_group.default
}

output "sg_id" {
  description = "security group id"
  value       = aws_security_group.default.id
}

output "sg_arn" {
  description = "security group id"
  value       = aws_security_group.default.arn
}
