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
# Certs — regional ACM cert for the internal ALB
###############################################################################

module "acm_web" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.domain_name
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

module "aws_security_group_web" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = "${var.app_name}-web"
  environment = var.environment
  label       = "web"
  tags        = module.tags.tags
  description = "Allow HTTPS for internal ALB from PG&E network"
  vpc_id      = var.network.vpc_id
  cidr_ingress_rules = [
    {
      description      = "CCOE Ingress rules 1"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE Ingress rules 2"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE Ingress rules 3"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE Ingress rules 4"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["172.30.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE Ingress rules 5"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["131.90.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "Opsera tunnel ingress rules"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["192.80.218.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE additional"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["10.90.0.0/21"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  cidr_egress_rules = [
    {
      description      = "CCOE egress rules"
      from             = 0
      to               = 65535
      protocol         = "tcp"
      cidr_blocks      = ["10.90.108.0/23"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  security_group_egress_rules = [
    {
      description              = "Allow ALB to reach nginx"
      from                     = 80
      to                       = 80
      protocol                 = "tcp"
      source_security_group_id = module.aws_security_group_ec2.aws_security_group_id
    }
  ]
}

module "aws_security_group_ec2" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = "${var.app_name}-web"
  environment = var.environment
  label       = "ec2"
  tags        = module.tags.tags
  description = "Allow HTTP from internal ALB only"
  vpc_id      = var.network.vpc_id
  cidr_egress_rules = [
    {
      description      = "Allow outbound (S3, package repos, SSM)"
      from             = 0
      to               = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  security_group_ingress_rules = [
    {
      description              = "Allow ALB to reach nginx"
      from                     = 80
      to                       = 80
      protocol                 = "tcp"
      source_security_group_id = module.aws_security_group_web.aws_security_group_id
    }
  ]
}


###############################################################################
# S3 — deployment artifact bucket (kept; pipeline still does aws s3 sync)
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
# EC2 — nginx serving the SPA, sync'd from S3 every minute via cron
###############################################################################

module "ec2" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  app_name      = "${var.app_name}-web"
  environment   = var.environment
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network = {
    subnet_id          = var.network.subnet_ids[0]
    security_group_ids = [module.aws_security_group_ec2.aws_security_group_id]
  }

  iam = {
    create_instance_profile = true
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
dnf install -y nginx awscli cronie
systemctl enable --now crond

# nginx config — SPA fallback so client-side routing works
cat > /etc/nginx/conf.d/${var.app_name}-web.conf <<-NGINX
server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

# remove default server block
sed -i '/server {/,/^}/d' /etc/nginx/nginx.conf || true

mkdir -p /usr/share/nginx/html

# initial sync so the instance is functional immediately after boot
aws s3 sync s3://${module.s3_web.bucket_name}/ /usr/share/nginx/html/ --delete || true

# 1-minute cron to pick up new deploys from the pipeline's aws s3 sync
cat > /etc/cron.d/${var.app_name}-web-sync <<-CRON
* * * * * root /usr/bin/aws s3 sync s3://${module.s3_web.bucket_name}/ /usr/share/nginx/html/ --delete >/var/log/${var.app_name}-web-sync.log 2>&1
CRON
chmod 644 /etc/cron.d/${var.app_name}-web-sync

systemctl enable --now nginx
EOF

  tags = module.tags.tags
}


###############################################################################
# Load Balancer — internal ALB
###############################################################################

module "load_balancer_web" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

  app_name          = "${var.app_name}-web"
  environment       = var.environment
  tags              = module.tags.tags
  vpc_id            = var.network.vpc_id
  subnet_ids        = var.network.subnet_ids
  security_group_id = module.aws_security_group_web.aws_security_group_id
  certificate_arn   = module.acm_web.certificate_arn
  instance_id       = module.ec2.instance_id
  target_port       = 80
  health_check_path = var.health_check_path
  health_check_port = 80
}


###############################################################################
# Route53 — private zone only (no public record)
###############################################################################

module "aws_route53_record_web_private" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                = var.private_hosted_zone_id
  domain_name            = var.domain_name
  record_type            = "A"
  target_domain_name     = module.load_balancer_web.alb_dns_name
  target_zone_id         = module.load_balancer_web.alb_dns_zone_id
  evaluate_target_health = true
}
