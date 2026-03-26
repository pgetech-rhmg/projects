# Output the Cognito Identity Pool ID
output "cognito_identity_pool_id" {
  value       = aws_cognito_identity_pool.main.id
  description = "value of the cognito identity pool id"
}



output "cognito_identity_pool_allow_unauthenticated_identities" {
  value       = aws_cognito_identity_pool.main.allow_unauthenticated_identities
  description = "value of the cognito identity pool allow unauthenticated identities"

}

output "cognito_identity_pool_openid_connect_provider_arns" {
  value       = aws_cognito_identity_pool.main.openid_connect_provider_arns
  description = "value of the cognito identity pool openid connect provider arns"

}

output "cognito_identity_pool_saml_provider_arns" {
  value       = aws_cognito_identity_pool.main.saml_provider_arns
  description = "value of the cognito identity pool saml provider arns"

}

output "cognito_identity_pool_arn" {
  value       = aws_cognito_identity_pool.main.arn
  description = "value of the cognito identity pool arn"

}

output "cognito_identity_pool" {
  value       = aws_cognito_identity_pool.main
  description = "map of aws congito identity pool"
}

## IAM Role for Authenticated Users
output "authenticated_role_arn" {
  value       = aws_iam_role.authenticated.arn
  description = "value of the authenticated role arn"
}




output "identity_pool_roles_attachment" {
  value       = aws_cognito_identity_pool_roles_attachment.main
  description = "value of the identity pool roles attachment"

}