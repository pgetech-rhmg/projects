##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/security_group.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
module "security_group_project" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${var.repo_name}-dispactch"
  description = "Security Group for codebuild-dispatch of ${var.repo_name}"
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value
  tags        = module.tags.tags
  cidr_egress_rules = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}
