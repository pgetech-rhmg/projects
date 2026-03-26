/*
* # AWS AppStream 2.0 with VPC Endpoints - Private Deployment Example
* Terraform module for AppStream 2.0 with complete VPC endpoint setup for private connectivity
* This example shows how to deploy AppStream without internet access using VPC endpoints
*/

locals {
  optional_tags = var.optional_tags
  name          = "${var.name}-${random_string.name.result}"
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_vpc" "main" {
  id = data.aws_ssm_parameter.vpc_id.value
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_subnet" "fleet_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "fleet_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "fleet_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}


resource "random_string" "name" {
  length           = 8
  upper            = false
  special          = true
  override_special = "_-"
}

################################################################################
# Security Group for AppStream with VPC Endpoint Access
################################################################################

module "security_group_appstream" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  cidr_ingress_rules = [
    # AppStream streaming traffic - VPC internal
    {
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTPS for VPC endpoint communication"
      prefix_list_ids  = []
    },
    {
      from             = 1400
      to               = 1499
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "AppStream streaming via VPC endpoints"
      prefix_list_ids  = []
    },
    # Active Directory communication
    {
      from             = 389
      to               = 389
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "LDAP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 636
      to               = 636
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "LDAPS from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88
      to               = 88
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "Kerberos TCP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88
      to               = 88
      protocol         = "udp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "Kerberos UDP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53
      to               = 53
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "DNS TCP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53
      to               = 53
      protocol         = "udp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "DNS UDP from VPC to Active Directory"
      prefix_list_ids  = []
    }
  ]

  cidr_egress_rules = [
    # VPC endpoint communication
    {
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTPS to VPC endpoints"
      prefix_list_ids  = []
    },
    # Active Directory communication
    {
      from             = 389
      to               = 389
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "LDAP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 636
      to               = 636
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "LDAPS to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88
      to               = 88
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "Kerberos TCP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88
      to               = 88
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "Kerberos UDP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53
      to               = 53
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "DNS TCP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53
      to               = 53
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "DNS UDP to Active Directory"
      prefix_list_ids  = []
    }
  ]

  tags = merge(module.tags.tags, local.optional_tags)
}

################################################################################
# IAM Role for AppStream
################################################################################

module "iam_role_appstream" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  aws_service   = var.role_service
  inline_policy = [file("${path.module}/appstream_iam_policy.json")]
  tags          = merge(module.tags.tags, local.optional_tags)
}

################################################################################
# VPC Endpoints - Required for Private AppStream Deployment
################################################################################

# Option 1: Create new AppStream Streaming VPC Endpoint (Production/Customer deployments)
# Use this when customers need to create their own dedicated VPC endpoint
# Benefits: Full control, isolation, compliance, no shared dependencies
resource "aws_vpc_endpoint" "appstream_streaming" {
  vpc_endpoint_type   = "Interface"
  service_name        = var.appstream_service_name
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  private_dns_enabled = true
  # Note: AppStream streaming service only supports full-access endpoint policy
  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  security_group_ids = [module.security_group_appstream.sg_id]

  tags = merge(module.tags.tags, local.optional_tags, {
    Name    = "${local.name}-appstream-streaming"
    Service = "appstream.streaming"
  })
}

# Option 2: Use existing AppStream Streaming VPC Endpoint (Development/Testing)
# Uncomment this block and comment out the resource above when using existing VPC endpoint
# Benefits: Cost savings, faster deployment, shared infrastructure for testing
/*
data "aws_vpc_endpoint" "appstream_streaming" {
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
  service_name = var.appstream_service_name
  state        = "available"
  
  filter {
    name   = "vpc-endpoint-type"
    values = ["Interface"]
  }
  
  # Uncomment and update with specific VPC endpoint ID if multiple endpoints exist
  # filter {
  #   name   = "vpc-endpoint-id"
  #   values = ["vpce-0dd42cce5ae4b29c1"]
  # }
}
*/

# Note: This is the absolute minimum setup - only AppStream streaming endpoint
# Fleet management operations may be limited without EC2 endpoint
# Add EC2 endpoint back if you experience fleet management issues

################################################################################
# AppStream Fleet
################################################################################

module "fleet" {
  source = "../../modules/fleet"

  name               = local.name
  instance_type      = var.instance_type
  fleet_type         = var.fleet_type
  display_name       = var.display_name
  desired_instances  = var.desired_instances
  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  image_name         = var.image_name
  iam_role_arn       = module.iam_role_appstream.arn
  security_group_ids = [module.security_group_appstream.sg_id]

  domain_join_info = var.domain_join_info

  tags = merge(module.tags.tags, local.optional_tags)
}

################################################################################
# AppStream Stack with VPC Endpoint Access
################################################################################

module "stack_appstream" {
  source       = "../../modules/stack"
  name         = local.name
  description  = var.description
  display_name = var.display_name

  user_settings = [
    {
      action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
      permission = "ENABLED"
    },
    {
      action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
      permission = "ENABLED"
    },
    {
      action     = "FILE_UPLOAD"
      permission = "ENABLED"
    },
    {
      action     = "FILE_DOWNLOAD"
      permission = "ENABLED"
    },
    {
      action     = "PRINTING_TO_LOCAL_DEVICE"
      permission = "ENABLED"
    },
    {
      action     = "DOMAIN_PASSWORD_SIGNIN"
      permission = "ENABLED"
    },
    {
      action     = "DOMAIN_SMART_CARD_SIGNIN"
      permission = "DISABLED"
    }
  ]

  # Access endpoints for VPC endpoint connectivity
  access_endpoints = [{
    endpoint_type = "STREAMING"
    # Use this when creating new VPC endpoint (resource)
    vpce_id = aws_vpc_endpoint.appstream_streaming.id
    # Use this when using existing VPC endpoint (data source - when uncommented)
    # vpce_id       = data.aws_vpc_endpoint.appstream_streaming.id
  }]

  tags = merge(module.tags.tags, local.optional_tags)
}

################################################################################
# Fleet-Stack Association
################################################################################

module "fleet_stack" {
  source = "../../modules/fleet_stack_association"

  fleet_name = module.fleet.id
  stack_name = module.stack_appstream.appstream_stack_id
}