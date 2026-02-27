output "vpc_id" {
  value = data.aws_ssm_parameter.vpc_id.value
}

output "private_subnet_ids" {
  value = local.private_subnet_ids
}

