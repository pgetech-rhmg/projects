################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
}

data "aws_secretsmanager_secret" "jfrog_credential" {
  name = var.jfrog_credentials
}

data "aws_secretsmanager_secret_version" "jfrog_credential" {
  secret_id = data.aws_secretsmanager_secret.jfrog_credential.id
}


data "aws_secretsmanager_secret" "wiz_secret_credential" {
  name = var.wiz_secret_credential
}

data "aws_secretsmanager_secret_version" "wiz_secret_version" {
  secret_id = data.aws_secretsmanager_secret.wiz_secret_credential.id
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = true
}

