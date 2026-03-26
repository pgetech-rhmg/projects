# Outputs for resource 'wafv2-web-acl'

output "arn" {
  description = "The ARN of the WAF WebACL"
  value       = aws_wafv2_web_acl.wafv2-web-acl.arn
}

output "capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = aws_wafv2_web_acl.wafv2-web-acl.capacity
}

output "id" {
  description = "The ID of the WAF WebACL"
  value       = aws_wafv2_web_acl.wafv2-web-acl.id
}

output "tags_all" {
  description = " Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_web_acl.wafv2-web-acl.tags_all
}

output "aws_wafv2_web_acl_all" {
  description = "Map of all aws_wafv2_web_acl"
  value       = aws_wafv2_web_acl.wafv2-web-acl
}