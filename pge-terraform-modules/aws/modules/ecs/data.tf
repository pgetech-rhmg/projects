data "aws_secretsmanager_secret" "wiz_registry_credentials" {
  name = var.wiz_registry_credentials
}


data "aws_secretsmanager_secret_version" "wiz_secret_version" {
  secret_id = data.aws_secretsmanager_secret.wiz_secret_credential.id
}


data "aws_secretsmanager_secret" "wiz_secret_credential" {
  name = var.wiz_secret_credential
}