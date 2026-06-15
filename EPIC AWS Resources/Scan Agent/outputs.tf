###############################################################################
# Outputs
###############################################################################

output "instance_id" {
  description = "EC2 instance ID of the scan agent. Use with: aws ssm start-session --target <id>"
  value       = module.scan_agent.instance_id
}

output "private_ip" {
  description = "Private IP of the scan agent"
  value       = module.scan_agent.private_ip
}

output "private_dns" {
  description = "Private DNS of the scan agent"
  value       = module.scan_agent.private_dns
}

output "iam_role_name" {
  description = "Name of the agent's IAM role (attach further policies here if needed)"
  value       = module.scan_agent.iam_role_name
}
