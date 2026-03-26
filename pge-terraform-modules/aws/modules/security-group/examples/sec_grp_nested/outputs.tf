output "nested_security_group_id" {
  description = "security group id"
  value       = module.nested_security_group[*].sg_id
}

output "nested_security_group_name" {
  description = "security group name"
  value       = module.nested_security_group[*].sg_arn
}
