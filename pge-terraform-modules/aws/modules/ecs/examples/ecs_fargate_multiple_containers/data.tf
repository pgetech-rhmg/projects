data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.parameter_subnet_id3_name
}

data "aws_ssm_parameter" "subnet_cidr1" {
  name = var.parameter_subnet_cidr1_id
}

data "aws_ssm_parameter" "subnet_cidr2" {
  name = var.parameter_subnet_cidr2_id
}

data "aws_ssm_parameter" "subnet_cidr3" {
  name = var.parameter_subnet_cidr3_id
}

data "aws_ssm_parameter" "alb_cidr1" {
  name = var.parameter_alb_cidr_id1
}

data "aws_ssm_parameter" "alb_cidr2" {
  name = var.parameter_alb_cidr_id2
}

data "aws_ssm_parameter" "alb_cidr3" {
  name = var.parameter_alb_cidr_id3
}

data "aws_secretsmanager_secret" "jfrog_password" {
  name = var.jfrog_password
}

data "aws_secretsmanager_secret_version" "latest_version" {
  secret_id = data.aws_secretsmanager_secret.jfrog_password.id
}

data "aws_secretsmanager_secret" "wiz_registry_credentials" {
  name = var.wiz_registry_credentials
}

data "aws_secretsmanager_secret" "wiz_secret_credential" {
  name = var.wiz_secret_credential
}

data "aws_secretsmanager_secret_version" "wiz_secret_version" {
  secret_id = data.aws_secretsmanager_secret.wiz_secret_credential.id
}

data "aws_caller_identity" "current" {}