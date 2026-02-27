variable "ssm_vpc_id_parameter" {
  description = "SSM parameter name that stores the existing VPC ID"
  type        = string
}

variable "ssm_private_subnet_a_parameter" {
  description = "SSM parameter name that stores private subnet A ID"
  type        = string
}

variable "ssm_private_subnet_b_parameter" {
  description = "SSM parameter name that stores private subnet B ID"
  type        = string
}

