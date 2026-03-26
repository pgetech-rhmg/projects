# Outputs for Amplify Branch

output "arn" {
  description = "ARN for the branch."
  value       = aws_amplify_branch.amplify_branch.arn
}

output "associated_resources" {
  description = "A list of custom resources that are linked to this branch."
  value       = aws_amplify_branch.amplify_branch.associated_resources
}

output "custom_domains" {
  description = "Custom domains for the branch."
  value       = aws_amplify_branch.amplify_branch.custom_domains
}

output "destination_branch" {
  description = "Destination branch if the branch is a pull request branch."
  value       = aws_amplify_branch.amplify_branch.destination_branch
}

output "source_branch" {
  description = "Source branch if the branch is a pull request branch."
  value       = aws_amplify_branch.amplify_branch.source_branch
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_amplify_branch.amplify_branch.tags_all
}

output "amplify_branch" {
  description = "A map of aws amplify branch"
  value       = aws_amplify_branch.amplify_branch
}