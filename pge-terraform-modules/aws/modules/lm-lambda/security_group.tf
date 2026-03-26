##################################################################
#
#  Filename    : aws/modules/lm-lambda/security_group.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Lambda Function for Locaste & Mark
#
##################################################################
module "lambda_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${var.function_name}_sg"
  description = "Security group for lambda log_group_sumo_subscription"
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value

  cidr_egress_rules = [
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    }
  ]

  tags = module.tags.tags
}
