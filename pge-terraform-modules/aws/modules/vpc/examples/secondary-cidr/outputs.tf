output "subnet_a_id" {
  value       = module.vpc-sec-cidr.subnet_a_id
  description = "The IDs of the Subnet A resources."
}

output "subnet_b_id" {
  value       = module.vpc-sec-cidr.subnet_b_id
  description = "The IDs of the Subnet B resources."
}

output "subnet_c_id" {
  value       = module.vpc-sec-cidr.subnet_c_id
  description = "The IDs of the Subnet C resources."
}