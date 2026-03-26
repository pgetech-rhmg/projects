###########################################
# Outputs
###########################################

output "identity_pool_id" {
  value       = module.cognito_identity_pool.cognito_identity_pool_id
  description = "value of the cognito identity pool id"
}

output "authenticated_role_arn" {
  description = "value of the authenticated role arn"
  value       = module.cognito_identity_pool.authenticated_role_arn
}


