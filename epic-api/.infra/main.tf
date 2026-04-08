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
  secrets = merge(var.secrets, {
    "AWS_RDS_SECRET_ARN" = aws_rds_cluster.epic.master_user_secret[0].secret_arn
    "AWS_RDS_ENDPOINT"   = aws_rds_cluster.epic.endpoint
  })
  secrets_description     = var.secrets_description
  secret_version_enabled  = true
  recovery_window_in_days = 0
}


###############################################################################
# Certs
###############################################################################

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

module "aws_security_group_web" {
  source              = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name            = var.app_name
  environment         = var.environment
  label               = "web"
  tags                = module.tags.tags
  description         = "Allow HTTPS for internal ALB from PG&E network"
  vpc_id              = var.network.vpc_id
  cidr_ingress_rules  = [
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
      cidr_blocks       = ["131.89.0.0/16"],
      ipv6_cidr_blocks  = [],
      prefix_list_ids   = []
    },
    {
      description       = "CCOE Ingress rules 6",
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
# S3
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
# Database — Aurora PostgreSQL Serverless v2
###############################################################################

resource "aws_db_subnet_group" "epic" {
  name       = "${var.app_name}-api-${var.environment}"
  subnet_ids = var.network.subnet_ids
  tags       = module.tags.tags
}

module "aws_security_group_db" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = var.app_name
  environment = var.environment
  label       = "db"
  tags        = module.tags.tags
  description = "Allow PostgreSQL from API instances"
  vpc_id      = var.network.vpc_id
  security_group_ingress_rules = [
    {
      description              = "PostgreSQL from API"
      from                     = 5432
      to                       = 5432
      protocol                 = "tcp"
      source_security_group_id = module.aws_security_group_api.aws_security_group_id
    }
  ]
  cidr_egress_rules = []
}

resource "aws_rds_cluster" "epic" {
  cluster_identifier     = "${var.app_name}-api-${var.environment}"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "16.4"
  database_name          = var.db_name
  master_username        = var.db_master_username
  manage_master_user_password = true
  db_subnet_group_name   = aws_db_subnet_group.epic.name
  vpc_security_group_ids = [module.aws_security_group_db.aws_security_group_id]
  skip_final_snapshot    = true
  deletion_protection    = var.environment == "prod"
  storage_encrypted      = true
  tags                   = module.tags.tags

  serverlessv2_scaling_configuration {
    min_capacity = var.db_min_capacity
    max_capacity = var.db_max_capacity
  }
}

resource "aws_rds_cluster_instance" "epic" {
  identifier         = "${var.app_name}-api-${var.environment}-1"
  cluster_identifier = aws_rds_cluster.epic.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.epic.engine
  engine_version     = aws_rds_cluster.epic.engine_version
  tags               = module.tags.tags
}


###############################################################################
# IAM — RDS secret read access
###############################################################################

resource "aws_iam_policy" "rds_secret_read" {
  name = "pge-epic-${var.app_name}-api-${var.environment}-rds-secret-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_rds_cluster.epic.master_user_secret[0].secret_arn
    }]
  })

  tags = module.tags.tags
}


###############################################################################
# EC2
###############################################################################

module "ec2" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  app_name      = "${var.app_name}-api"
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
      module.secretmanager.secret_read_arn,
      aws_iam_policy.rds_secret_read.arn
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

mkdir -p /opt/${var.app_name}-api/app

cat > /etc/systemd/system/${var.app_name}-api.service <<-SERVICE
[Unit]
Description=${var.app_name}-api
After=network.target

[Service]
WorkingDirectory=/opt/${var.app_name}-api/app
ExecStart=/opt/${var.app_name}-api/app/${var.app_executable}
Restart=always
RestartSec=5
User=ec2-user
Environment=ASPNETCORE_URLS=http://0.0.0.0:5000
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable ${var.app_name}-api
EOF

  tags = module.tags.tags
}


###############################################################################
# Load Balancer
###############################################################################

module "load_balancer_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

  app_name          = "${var.app_name}-api"
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

module "aws_route53_record_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                = var.private_hosted_zone_id
  domain_name            = var.api_domain_name
  record_type            = "A"
  target_domain_name     = module.load_balancer_api.alb_dns_name
  target_zone_id         = module.load_balancer_api.alb_dns_zone_id
  evaluate_target_health = true
}
