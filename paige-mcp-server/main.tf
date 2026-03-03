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
# Certs
###############################################################################

module "acm_mcp" {
	source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
	domain_name           = var.mcp_domain_name
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

module "aws_security_group_alb" {
	source              = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
	app_name            = var.app_name
	environment         = var.environment
	label               = "alb"
	tags                = module.tags.tags
	description         = "Allow HTTPS for ALB"
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
			description               = "Allow ALB to reach MCP",
			from                      = 8000,
			to                        = 8000,
			protocol                  = "tcp",
			source_security_group_id  = module.aws_security_group_mcp.aws_security_group_id
		},
		{
			description               = "Allow ALB health check to reach MCP health port",
			from                      = 8001,
			to                        = 8001,
			protocol                  = "tcp",
			source_security_group_id  = module.aws_security_group_mcp.aws_security_group_id
		}
	]
}

module "aws_security_group_mcp" {
	source                        = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
	app_name                      = var.app_name
	environment                   = var.environment
	label                         = "mcp"
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
			description               = "Allow ALB to reach MCP",
			from                      = 8000,
			to                        = 8000,
			protocol                  = "tcp",
			source_security_group_id  = module.aws_security_group_alb.aws_security_group_id
		},
		{
			description               = "Allow ALB health check",
			from                      = 8001,
			to                        = 8001,
			protocol                  = "tcp",
			source_security_group_id  = module.aws_security_group_alb.aws_security_group_id
		}
	]
}


###############################################################################
# EC2 (MCP)
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

	app_name      = "${var.app_name}-mcp"
	environment   = var.environment
	ami           = data.aws_ami.amazon_linux.id
	instance_type = var.instance_type

	network = {
		subnet_id          = var.network.subnet_ids[0]
		security_group_ids = [module.aws_security_group_mcp.aws_security_group_id]
	}

	iam = {
		create_instance_profile = true
		policy_arns = [
			"arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
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
dnf install -y python3.11 python3.11-pip git awscli

mkdir -p /opt/${var.app_name}/app

cat > /etc/systemd/system/${var.app_name}.service <<SERVICE
[Unit]
Description=${var.app_name}
After=network.target

[Service]
WorkingDirectory=/opt/${var.app_name}/app
ExecStart=/opt/${var.app_name}/venv/bin/python -m ${var.app_executable}
Restart=always
RestartSec=5
User=ec2-user

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable ${var.app_name}
EOF

	tags = module.tags.tags
}


###############################################################################
# Load Balancer
###############################################################################

module "load_balancer_mcp" {
	source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

	app_name          = "${var.app_name}-mcp"
	environment       = var.environment
	tags              = module.tags.tags
	vpc_id            = var.network.vpc_id
	subnet_ids        = var.network.subnet_ids
	security_group_id = module.aws_security_group_alb.aws_security_group_id
	certificate_arn   = module.acm_mcp.certificate_arn
	instance_id       = module.ec2.instance_id
	target_port       = 8000
	health_check_port = 8001
	health_check_path = var.health_check_path
}


###############################################################################
# Route53
###############################################################################

module "aws_route53_record_mcp" {
	source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

	zone_id                   = var.private_hosted_zone_id
	domain_name               = var.mcp_domain_name
	record_type               = "A"
	target_domain_name        = module.load_balancer_mcp.alb_dns_name
	target_zone_id            = module.load_balancer_mcp.alb_dns_zone_id
	evaluate_target_health    = true
}