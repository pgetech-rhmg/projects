/*
* # AWS appstream2.0 with usage example
* Terraform module which creates SAF2.0 appstream2.0 resources in AWS. 
*/
#
# Filename    : modules/appstream2/examples/appstream2/main.tf
# Author      : TCS
# Description : The Terraform usage example creates aws appstream2.0 resources


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

# Directory service credentials - Only needed for directory_config module
# data "aws_ssm_parameter" "username" {
#   name = var.ssm_parameter_directory_username
# }
# 
# data "aws_ssm_parameter" "password" {
#   name = var.ssm_parameter_directory_password
# }

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length           = 8
  upper            = false
  special          = true
  override_special = "_-"
}

#security-group for appstream-2.0
module "security_group_appstream" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [
    # AppStream user access - From internet/corporate networks
    {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTP traffic for AppStream internet access"
      prefix_list_ids  = []
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTPS traffic for AppStream internet access"
      prefix_list_ids  = []
    },
    {
      from             = 1400,
      to               = 1499,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "AppStream streaming traffic from internet"
      prefix_list_ids  = []
    },
    # Active Directory communication - From VPC internal networks
    {
      from             = 389,
      to               = 389,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "LDAP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 636,
      to               = 636,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "LDAPS from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "Kerberos TCP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "udp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "Kerberos UDP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53,
      to               = 53,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "DNS TCP from VPC to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53,
      to               = 53,
      protocol         = "udp",
      cidr_blocks      = [data.aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = []
      description      = "DNS UDP from VPC to Active Directory"
      prefix_list_ids  = []
    }
  ]
  cidr_egress_rules = [
    {
      from             = 80,
      to               = 80,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTP egress traffic"
      prefix_list_ids  = []
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "HTTPS egress traffic"
      prefix_list_ids  = []
    },
    {
      from             = 1400,
      to               = 1499,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.fleet_1.cidr_block, data.aws_subnet.fleet_2.cidr_block, data.aws_subnet.fleet_3.cidr_block]
      ipv6_cidr_blocks = []
      description      = "AppStream streaming egress traffic"
      prefix_list_ids  = []
    },
    # Active Directory communication rules - Required for domain join
    {
      from             = 389,
      to               = 389,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "LDAP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 636,
      to               = 636,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "LDAPS to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "Kerberos TCP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "udp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "Kerberos UDP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53,
      to               = 53,
      protocol         = "tcp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "DNS TCP to Active Directory"
      prefix_list_ids  = []
    },
    {
      from             = 53,
      to               = 53,
      protocol         = "udp",
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      description      = "DNS UDP to Active Directory"
      prefix_list_ids  = []
    },

    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      description      = "Allow all egress traffic"
      prefix_list_ids  = []
    }
  ]
  tags = merge(module.tags.tags, local.optional_tags)
}

#IAM role for appstream-2.0 role
module "iam_role_appstream" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  aws_service   = var.role_service
  inline_policy = [file("${path.module}/appstream_iam_policy.json")]
  tags          = merge(module.tags.tags, local.optional_tags)
}

# Image Builder - Only enable when creating custom images
# Uncomment this module when you need to build a custom AppStream image
# Image builders are used to install applications and create custom images
# Once the image is built and available, comment this module out to save costs
# module "image_builder" {
#   source = "../../"

#   name                    = local.name
#   description             = var.description
#   display_name            = var.display_name
#   image_name              = var.image_name_imagebuilder
#   instance_type           = var.instance_type_imagebuilder
#   appstream_agent_version = var.appstream_agent_version
#   iam_role_arn            = module.iam_role_appstream.arn
#   security_group_ids      = [module.security_group_appstream.sg_id]
#   subnet_ids              = [data.aws_ssm_parameter.subnet_id1.value]
#   endpoint_type           = "STREAMING"
#   # vpce_id not specified - enables internet access via default gateway

#   # Domain join configuration for image builder
#   domain_join_info = var.domain_join_info

#   tags = merge(module.tags.tags, local.optional_tags)
# }

#Fleet
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

  # Domain join configuration for fleet instances - same as image builder
  domain_join_info = var.domain_join_info

  tags = merge(module.tags.tags, local.optional_tags)
}

# AppStream configuration for internet access
# For private connectivity, enable VPC endpoints below
# https://docs.aws.amazon.com/appstream2/latest/developerguide/vpc-endpoints.html

# VPC Endpoint for AppStream streaming - Enable for private subnet deployments
# resource "aws_vpc_endpoint" "vpc_endpoint" {
#   vpc_endpoint_type   = var.vpc_endpoint_type
#   service_name        = var.service_name
#   vpc_id              = data.aws_ssm_parameter.vpc_id.value
#   private_dns_enabled = var.private_dns_enabled
#   subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
#   security_group_ids  = [module.security_group_appstream.sg_id]
#
#   tags = merge(module.tags.tags, local.optional_tags, { Name = "${local.name}-appstream-streaming" })
# }


# User management - Only needed for USERPOOL authentication
# module "user_appstream" {
#   source              = "../../modules/user"
#   authentication_type = var.authentication_type
#   user_name           = var.user_name
#   first_name          = var.first_name
#   last_name           = var.last_name
#   enabled_user        = var.enabled_user
# }

# AppStream stack with domain authentication settings
module "stack_appstream" {
  source       = "../../modules/stack"
  name         = local.name
  description  = var.description
  display_name = var.display_name

  # Storage connectors not used in domain-joined environment
  # Users access network resources through domain authentication and Group Policy
  # storage_connectors = [{
  #   domains             = var.domains
  #   resource_identifier = var.resource_identifier
  # }]

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

  # Application settings not used in current domain-joined configuration
  # application_settings = [{
  #   enabled        = var.enabled
  #   settings_group = var.settings_group
  # }]

  # Access endpoints - Enable for private connectivity via VPC endpoints
  # Use when users need to connect through private networks instead of internet
  # Requires VPC endpoint resource above to be uncommented
  # access_endpoints = [{
  #   endpoint_type = var.endpoint_type
  #   vpce_id       = aws_vpc_endpoint.vpc_endpoint.id
  # }]

  tags = merge(module.tags.tags, local.optional_tags)
}

# Directory config - Only needed for runtime domain joining with base images
# module "directory_config" {
#   source = "../../modules/directory_config"
#
#   directory_name            = var.directory_name
#   organizational_unit_names = var.organizational_unit_names
#   account_name              = data.aws_ssm_parameter.username.value
#   account_password          = data.aws_ssm_parameter.password.value
# }

#Fleet_Stack Association
module "fleet_stack" {
  source = "../../modules/fleet_stack_association"

  fleet_name = module.fleet.id
  stack_name = module.stack_appstream.appstream_stack_id
}

# User-stack association - Only needed for USERPOOL authentication
# module "user_stack" {
#   source = "../../modules/user_stack_association"
#   user_name           = module.user_appstream.appstream_user_all.user_name
#   stack_name          = module.stack_appstream.appstream_stack_id
#   authentication_type = var.authentication_type
# }