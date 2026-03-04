###############################################################################
# Tags
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id     = var.aws_account_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}


###############################################################################
# Secrets Manager
###############################################################################

module "secretmanager" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-secretmanager.git?ref=main"

  app_name                = var.app_name
  environment             = var.environment
  tags                    = module.tags.tags
  secrets                 = var.secrets
  secrets_description     = var.secrets_description
  secret_version_enabled  = true
  recovery_window_in_days = 30
}


###############################################################################
# S3 (API)
###############################################################################

module "s3_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "${var.app_name}-api-deploy"
  environment                = var.environment
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = var.access_log_prefix
  custom_bucket_name         = var.custom_bucket_name
  bucket_policy_json         = var.bucket_policy_json
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = var.enable_public_access_block
  enable_versioning          = var.enable_versioning
  force_destroy              = var.force_s3_destroy
  kms_key_arn                = var.kms_key_arn
  lifecycle_rules            = var.lifecycle_rules
  object_ownership           = var.object_ownership
  sse_algorithm              = var.sse_algorithm
}


###############################################################################
# Certs
###############################################################################

module "acm_web" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = "public"
  tags                  = module.tags.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "acm_api" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.api_domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = "default"
  tags                  = module.tags.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}


###############################################################################
# Security Groups
###############################################################################

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "aws_security_group_web" {
  source              = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name            = var.app_name
  environment         = var.environment
  label               = "web"
  tags                = module.tags.tags
  description         = "Allow HTTPS for ALB"
  vpc_id              = var.network.vpc_id
  cidr_ingress_rules  = [
    {
      description       = "HTTPS from CloudFront",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = [],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
    },
    {
      description       = "CCOE Ingress rules 1",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["10.0.0.0/8"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE Ingress rules 2",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["172.16.0.0/12"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE Ingress rules 3",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["192.168.0.0/16"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE Ingress rules 4",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["172.30.0.0/16"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE Ingress rules 5",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["131.90.0.0/16"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "Opsera tunnel ingress rules",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["192.80.218.0/24"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE additional",
      from              = 443,
      to                = 443,
      protocol          = "tcp",
      cidr_blocks       = ["10.90.0.0/21"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    }
  ]
  cidr_egress_rules   = [
    {
      description      = "CCOE egress rules",
      from             = 0,
      to               = 65535,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.108.0/23"],
      ipv6_cidr_blocks = [],
      prefix_list_ids  = []
    },
    {
      description      = "CCOE egress rules",
      from             = 0,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.108.0/23"],
      ipv6_cidr_blocks = [],
      prefix_list_ids  = []
    }
  ]
  security_group_egress_rules  = [
    {
      description               = "Allow ALB to reach API",
      from                      = 5000,
      to                        = 5000,
      protocol                  = "tcp",
      source_security_group_id  = module.aws_security_group_api.aws_security_group_id
    }
  ]
}

module "aws_security_group_api" {
  source                        = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name                      = var.app_name
  environment                   = var.environment
  label                         = "api"
  tags                          = module.tags.tags
  description                   = "Allow traffic from ALB only"
  vpc_id                        = var.network.vpc_id
  cidr_egress_rules             = [
    {
      description      = "Allow outbound",
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["0.0.0.0/0"],
      ipv6_cidr_blocks = [],
      prefix_list_ids  = []
    }
  ]
  security_group_ingress_rules  = [
    {
      description               = "Allow ALB to reach API",
      from                      = 5000,
      to                        = 5000,
      protocol                  = "tcp",
      source_security_group_id  = module.aws_security_group_web.aws_security_group_id
    }
  ]
}


###############################################################################
# EC2 (API)
###############################################################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}


module "ec2" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  app_name      = var.app_name
  environment   = var.environment
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network = {
    subnet_id          = var.network.subnet_ids[0]
    security_group_ids = [module.aws_security_group_api.aws_security_group_id]
  }

  iam = {
    create_instance_profile = true
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      module.secretmanager.secret_read_arn
    ]
  }

  root_volume = {
    size = 20
    type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -e

dnf update -y
dnf install -y libicu unzip jq awscli git

mkdir -p /opt/${var.app_name}/app

cat > /etc/systemd/system/${var.app_name}.service <<SERVICE
[Unit]
Description=${var.app_name}
After=network.target

[Service]
WorkingDirectory=/opt/${var.app_name}/app
ExecStart=/opt/${var.app_name}/app/${var.app_executable}
Restart=always
RestartSec=5
User=ec2-user
Environment=ASPNETCORE_URLS=http://0.0.0.0:5000
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable ${var.app_name}
EOF

  tags = module.tags.tags
}


###############################################################################
# S3 (Web)
###############################################################################

module "s3_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  app_name                   = "${var.app_name}-web"
  environment                = var.environment
  tags                       = module.tags.tags
  access_log_bucket          = var.access_log_bucket
  access_log_prefix          = var.access_log_prefix
  custom_bucket_name         = var.custom_bucket_name
  bucket_policy_json         = var.bucket_policy_json
  enable_access_logging      = var.enable_access_logging
  enable_public_access_block = var.enable_public_access_block
  enable_versioning          = var.enable_versioning
  force_destroy              = var.force_s3_destroy
  kms_key_arn                = var.kms_key_arn
  lifecycle_rules            = var.lifecycle_rules
  object_ownership           = var.object_ownership
  sse_algorithm              = var.sse_algorithm
}


###############################################################################
# CloudFront
###############################################################################

module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  app_name                    = var.app_name
  environment                 = var.environment
  bucket_name                 = module.s3_web.bucket_name
  bucket_arn                  = module.s3_web.bucket_arn
  bucket_regional_domain_name = module.s3_web.bucket_regional_domain_name
  price_class                 = var.price_class
  custom_domain_aliases       = var.custom_domain_aliases
  custom_acm_certificate_arn  = module.acm_web.certificate_arn

  tags = merge(module.tags.tags, { Name = "pge-epic-${var.app_name}-${var.environment}-cloudfront"})
}


###############################################################################
# Load Balancer
###############################################################################

module "load_balancer_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

  app_name          = var.app_name
  environment       = var.environment
  tags              = module.tags.tags
  vpc_id            = var.network.vpc_id
  subnet_ids        = var.network.subnet_ids
  security_group_id = module.aws_security_group_web.aws_security_group_id
  certificate_arn   = module.acm_api.certificate_arn
  instance_id       = module.ec2.instance_id
  target_port       = 5000
  health_check_path = var.health_check_path
}


###############################################################################
# Route53
###############################################################################

module "aws_route53_record_web_public" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                   = var.public_hosted_zone_id
  domain_name               = var.domain_name
  record_type               = "A"
  target_domain_name        = module.cloudfront.distribution_domain_name
  target_zone_id            = "Z2FDTNDATAQYW2"
  evaluate_target_health    = false
}

module "aws_route53_record_web_private" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                   = var.private_hosted_zone_id
  domain_name               = var.domain_name
  record_type               = "A"
  target_domain_name        = module.cloudfront.distribution_domain_name
  target_zone_id            = "Z2FDTNDATAQYW2"
  evaluate_target_health    = false
}

module "aws_route53_record_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                   = var.private_hosted_zone_id
  domain_name               = var.api_domain_name
  record_type               = "A"
  target_domain_name        = module.load_balancer_api.alb_dns_name
  target_zone_id            = module.load_balancer_api.alb_dns_zone_id
  evaluate_target_health    = true
}

