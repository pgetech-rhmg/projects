# Outputs for resource 'aws_wafv2_ip_set'

output "ip_set_id" {
  description = "A unique identifier for the set."
  value       = aws_wafv2_ip_set.wafv2_ip_set.id
}

output "ip_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster."
  value       = aws_wafv2_ip_set.wafv2_ip_set.arn
}

output "ip_set_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_ip_set.wafv2_ip_set.tags_all
}


output "aws_wafv2_ip_set_all" {
  description = "Map of all aws_wafv2_ip_set"
  value       = aws_wafv2_ip_set.wafv2_ip_set
}