
/*
 * # AWS NLB  module
 * Terraform module which creates SAF2.0 NLB in AWS.
 * nlb logs cannot be written to a kms-cmk encrypted s3 bucket.
 * So standard encryption is used for the s3 bucket.
 * https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
 * Public NLB tetsing is not done as there is no public subnet available in the aws account.
*/
#
# Filename    : aws/modules/nlb/examples/internal_nlb/main.tf
# Date        : 10 April 2024
# Author      : PGE
# Description : Internal NLB creation main file.
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.Optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role

}
locals {
  base_domain_name = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.acm_domain_name)[1]
}

module "kms_key" {
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.1"
  name        = var.kms_name
  description = var.kms_description
  policy      = file("${path.module}/${var.template_file_name}")
  tags        = merge(module.tags.tags, local.optional_tags)
  aws_role    = local.aws_role
  kms_role    = local.kms_role
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/2/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/2/privatesubnet2/id"
}

data "aws_caller_identity" "current" {}


data "aws_ssm_parameter" "golden_ami" {
  name = "/ami/base-windows-2019/latest"
}

data "aws_ssm_parameter" "windows_ad_golden" {
  name = "/ec2/windows/security_group_id/ad"
}

data "aws_ssm_parameter" "windows_bmc_proxy_golden" {
  name = "/ec2/windows/security_group_id/bmc_proxy"
}

data "aws_ssm_parameter" "windows_bmc_scanner_golden" {
  name = "/ec2/windows/security_group_id/bmc_scanner"
}

data "aws_ssm_parameter" "windows_encase_golden" {
  name = "/ec2/windows/security_group_id/encase"
}

data "aws_ssm_parameter" "windows_rdp_golden" {
  name = "/ec2/windows/security_group_id/rdp"
}

data "aws_ssm_parameter" "windows_sccm_golden" {
  name = "/ec2/windows/security_group_id/sccm"
}

data "aws_ssm_parameter" "windows_scom_golden" {
  name = "/ec2/windows/security_group_id/scom"
}


data "aws_route53_zone" "public_zone" {
  provider     = aws.r53
  name         = local.base_domain_name
  private_zone = false
}

data "aws_subnet" "ec2" {
  id = data.aws_ssm_parameter.subnet_id1.value
}



##################################################################
# Network Load Balancer
##################################################################

module "nlb" {
  source = "../../"

  name        = var.nlb_name
  bucket_name = var.bucket_name

  load_balancer_type               = "network"
  vpc_id                           = data.aws_ssm_parameter.vpc_id.value
  dns_record_client_routing_policy = "availability_zone_affinity"

  subnets  = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  internal = var.internal

  # For example only
  enable_deletion_protection = false

  # Security Group
  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  security_groups                                              = [module.nlb_security_group.sg_id]


  listeners = {
    ex-one = {
      port     = 81
      protocol = "TCP_UDP"
      forward = {
        target_group_key = "ex-target-one"
      }
    }

    ex-two = {
      port     = 82
      protocol = "UDP"
      forward = {
        target_group_key = "ex-target-two"
      }
    }

    ex-three = {
      port     = 83
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target-three"
      }
    }

    ex-four = {
      port            = 84
      protocol        = "TLS"
      certificate_arn = module.acm.acm_certificate_arn
      forward = {
        target_group_key = "ex-target-four"
      }
    }
  }

  target_groups = {
    ex-target-one = {
      name_prefix            = "t1-"
      protocol               = "TCP_UDP"
      port                   = 81
      target_type            = "instance"
      target_id              = [module.ec2.id, module.ec2_new.id]
      connection_termination = true
      preserve_client_ip     = true

      stickiness = {
        type = "source_ip"
      }

      tags = {
        tcp_udp = true
      }
    }

    ex-target-two = {
      name_prefix = "t2-"
      protocol    = "UDP"
      port        = 82
      target_type = "instance"
      target_id   = [module.ec2.id, module.ec2_new.id]
    }

    ex-target-three = {
      name_prefix          = "t3-"
      protocol             = "TCP"
      port                 = 83
      target_type          = "ip"
      target_id            = [module.ec2.private_ip, module.ec2_new.private_ip]
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    }

    ex-target-four = {
      name_prefix = "t4-"
      protocol    = "TLS"
      port        = 84
      target_type = "instance"
      target_id   = [module.ec2.id, module.ec2_new.id]
      target_health_state = {
        enable_unhealthy_connection_termination = false
      }
    }
  }

  tags = merge(module.tags.tags, local.optional_tags)
}

################################################################################
# Supporting resources
################################################################################

module "nlb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.nlb_sg_name
  description        = var.nlb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.nlb_cidr_ingress_rules
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = [data.aws_subnet.ec2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}


module "ec2_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.sg_name
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  security_group_ingress_rules = [{
    from                     = 80,
    to                       = 80,
    protocol                 = "tcp",
    source_security_group_id = module.nlb_security_group.sg_id,
    description              = "CCOE Ingress rules",
    },
    {
      from                     = 443,
      to                       = 443,
      protocol                 = "tcp",
      source_security_group_id = module.nlb_security_group.sg_id,
      description              = "CCOE Ingress rules",
  }]
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group.sg_id, data.aws_ssm_parameter.windows_sccm_golden.value, data.aws_ssm_parameter.windows_encase_golden.value, data.aws_ssm_parameter.windows_rdp_golden.value, data.aws_ssm_parameter.windows_ad_golden.value, data.aws_ssm_parameter.windows_bmc_scanner_golden.value, data.aws_ssm_parameter.windows_bmc_proxy_golden.value, data.aws_ssm_parameter.windows_scom_golden.value]



  tags = merge(module.tags.tags, local.optional_tags)
}

module "s3" {
  source        = "app.terraform.io/pgetech/s3/aws"
  version       = "0.1.1"
  force_destroy = true
  bucket_name   = var.bucket_name
  kms_key_arn   = module.kms_key.key_arn
  policy = templatefile("${path.module}/${var.policy}", {
    bucket_name = var.bucket_name
    account_num = data.aws_caller_identity.current.account_id
    aws_role    = var.aws_role
    aws_region  = var.aws_region
  })
  tags = merge(module.tags.tags, local.optional_tags)

}

module "ec2_new" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group.sg_id, data.aws_ssm_parameter.windows_sccm_golden.value, data.aws_ssm_parameter.windows_encase_golden.value, data.aws_ssm_parameter.windows_rdp_golden.value, data.aws_ssm_parameter.windows_ad_golden.value, data.aws_ssm_parameter.windows_bmc_scanner_golden.value, data.aws_ssm_parameter.windows_bmc_proxy_golden.value, data.aws_ssm_parameter.windows_scom_golden.value]



  tags = merge(module.tags.tags, local.optional_tags)
}



module "acm" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"
  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_domain_name = var.acm_domain_name
  tags            = merge(module.tags.tags, local.optional_tags)
}



module "records_nlb" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  zone_id = data.aws_route53_zone.public_zone.zone_id

  providers = {
    aws = aws.r53
  }

  records = [
    {
      name    = "tfcnlb.nonprod.pge.com"
      type    = "CNAME"
      ttl     = "300"
      records = ["www.example.com"]
    }
  ]
}
