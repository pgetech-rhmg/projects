output "subnet_a_id" {
  value       = aws_subnet.subnet_a[*].id
  description = "The IDs of the Subnet A resources."
}

output "subnet_b_id" {
  value       = aws_subnet.subnet_b[*].id
  description = "The IDs of the Subnet B resources."
}

output "subnet_c_id" {
  value       = aws_subnet.subnet_c[*].id
  description = "The IDs of the Subnet C resources."
}