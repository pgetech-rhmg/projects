data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_route53_zone" "private_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = true
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
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

data "aws_secretsmanager_secret_version" "latest_version" {
  secret_id = data.aws_secretsmanager_secret.jfrog_credentials.id
}

data "aws_secretsmanager_secret" "jfrog_credentials" {
  name = var.jfrog_credentials
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "golden_ami" {
  name = var.parameter_golden_ami_name
}

data "template_file" "kms_policy" {
  template = templatefile("${path.module}/${var.template_file_name}",
    {
      account_num = data.aws_caller_identity.current.account_id
      ecs_iam     = module.ecs_iam_role.name
  }, )
}