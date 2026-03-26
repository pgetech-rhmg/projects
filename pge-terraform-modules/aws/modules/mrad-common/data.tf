data "aws_caller_identity" "current_account" {}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}
