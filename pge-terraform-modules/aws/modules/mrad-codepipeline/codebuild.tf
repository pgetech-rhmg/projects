locals {
  kms_key_arn = coalesce(var.kms_key_arn, "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:alias/aws/s3")
}

data "aws_ssm_parameter" "sonar_scanner_cli_zip_url" {
  name = "/mrad/codepipeline/sonar-scanner-cli-url"
}
module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.0.7"

  name        = "sg_codebuild_${var.project_name}_${var.branch}"
  description = "security group for CodeBuild"
  vpc_id      = data.aws_vpc.mrad_vpc.id

  cidr_egress_rules = [
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    }
  ]

  tags = var.tags
}
