output "authentication_profile_id" {
  description = "The name of the authentication profile."
  value       = aws_redshift_authentication_profile.authentication_profile.id
}

output "aws_redshift_authentication_profile_all" {
  description = "A map of all aws redshift authentication profile attribute references"
  value       = aws_redshift_authentication_profile.authentication_profile

}