#First EC2 instance for multiattach
output "ec2_01_id" {
  description = "The ID of the instance"
  value       = module.ec2_01.id
}

output "ec2_01_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_01.arn
}

output "ec2_01_capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = module.ec2_01.capacity_reservation_specification
}

output "ec2_01_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_01.instance_state
}

output "ec2_01_primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = module.ec2_01.primary_network_interface_id
}

output "ec2_01_private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = module.ec2_01.private_dns
}

output "ec2_01_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.ec2_01.tags_all
}

#Second Ec2 instance for multiattach
output "ec2_02_id" {
  description = "The ID of the instance"
  value       = module.ec2_02.id
}

output "ec2_02_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_02.arn
}

output "ec2_02_capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = module.ec2_02.capacity_reservation_specification
}

output "ec2_02_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_02.instance_state
}

output "ec2_02_primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = module.ec2_02.primary_network_interface_id
}

output "ec2_02_private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = module.ec2_02.private_dns
}

output "ec2_02_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.ec2_02.tags_all
}

#EBS
output "volume_id" {
  description = "The ID of EBS"
  value       = module.ebs.volume_id
}

output "volume_arn" {
  description = "The ARN of EBS"
  value       = module.ebs.volume_arn
}

output "volume_tags_all" {
  description = "A map of tags assigned to the resource"
  value       = module.ebs.volume_tags_all
}