output "domain_policy" {
  description = "Map of all attributes of the domain policy"
  value       = module.domain_policy[*].domain_policy_all
}