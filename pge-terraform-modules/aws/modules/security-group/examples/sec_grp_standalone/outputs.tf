output "security_group_id" {
  description = "security group id"
  value       = module.standalone_security_group[*].sg_id
}

output "security_group_arn" {
  description = "security group name"
  value       = module.standalone_security_group[*].sg_arn
}