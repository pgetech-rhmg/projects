###############################################################################
# Outputs
###############################################################################

output "ec2_instance_id" {
	description = "EC2 instance ID"
	value       = module.ec2.instance_id
}

output "ec2_private_ip" {
	description = "EC2 instance private IP"
	value       = module.ec2.private_ip
}

output "mcp_endpoint" {
	description = "MCP endpoint URL"
	value       = "https://${var.mcp_domain_name}"
}
