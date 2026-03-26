#Output for api_gateway_deployment
output "web_acl_arn" {
  value       = module.wafv2_web_acl.arn
  description = "The ID for API Gateway Deployment"
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
