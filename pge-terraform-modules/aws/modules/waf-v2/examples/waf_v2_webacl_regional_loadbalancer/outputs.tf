# Outputs for example 'aws_wafv2_ip_set'

output "ip_set_id" {
  description = "A unique identifier for the set."
  value       = module.wafv2_ip_set.ip_set_id
}

output "ip_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster."
  value       = module.wafv2_ip_set.ip_set_arn
}

output "ip_set_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.wafv2_ip_set.ip_set_tags_all
}

# Outputs for resource 'wafv2-web-acl'

output "arn" {
  description = "The ARN of the WAF WebACL"
  value       = module.wafv2_web_acl.arn
}

output "capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = module.wafv2_web_acl.capacity
}

output "id" {
  description = "The ID of the WAF WebACL"
  value       = module.wafv2_web_acl.id
}

output "tags_all" {
  description = " Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.wafv2_web_acl.tags_all
}