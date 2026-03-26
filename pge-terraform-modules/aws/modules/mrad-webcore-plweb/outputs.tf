output "region" {
  value = data.aws_region.current.name
}

output "repo_name" {
  value = local.repo_name
}

output "git_branch" {
  value = var.git_branch
}

output "sonar_token_name" {
  value = local.sonarqube_secret_name
}
