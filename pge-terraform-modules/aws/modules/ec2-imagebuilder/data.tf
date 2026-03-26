# Fetch Parameters

data "aws_ssm_parameter" "non_prod_ami_sns_topic_arn" {
  name            = var.non_prod_ami_sns_topic_arn
  with_decryption = true
}

data "aws_ssm_parameter" "cmk_ebs_arn" {
  name            = var.cmk_ebs_arn
  with_decryption = true
}

data "aws_ssm_parameter" "approver_topic_arn" {
  name            = var.approver_topic_arn
  with_decryption = true
}

data "aws_ssm_parameter" "cmk_arn" {
  name            = var.cmk_arn
  with_decryption = true
}

data "aws_ssm_parameter" "vpc_id" {
  name            = var.vpc_id
  with_decryption = true
}
data "aws_ssm_parameter" "vpc_cidr" {
  name            = var.vpc_cidr
  with_decryption = true
}

data "aws_ssm_parameter" "subnet_id_az_a" {
  name            = var.subnet_id_az_a
  with_decryption = true
}

data "aws_ssm_parameter" "subnet_id_az_b" {
  name            = var.subnet_id_az_b
  with_decryption = true
}

data "aws_ssm_parameter" "subnet_id_az_c" {
  name            = var.subnet_id_az_c
  with_decryption = true
}

data "aws_ssm_parameter" "ami_parameter" {
  name            = var.ami_parameter_store
  with_decryption = true
}

data "aws_ssm_parameter" "beta_ami_parameter" {
  name            = "${var.ami_parameter_store}-beta"
  with_decryption = true
}

data "aws_ssm_parameter" "encrypted_ami_parameter" {
  name            = "${var.ami_parameter_store}-beta/encrypted"
  with_decryption = true
}
data "aws_ssm_parameter" "encrypted_ami_parameter_main" {
  name            = "${var.ami_parameter_store}/encrypted"
  with_decryption = true
}

data "aws_ssm_parameter" "prev_ami_parameter" {
  name            = "${var.ami_parameter_store}-prev"
  with_decryption = true
}

data "aws_ssm_parameter" "status_ami_parameter" {
  name            = var.ami_parameter_store_status
  with_decryption = true
}

data "aws_ssm_parameter" "nonprod_ami_parameter" {
  name            = "${var.ami_parameter_store}-nonprod"
  with_decryption = true
}
