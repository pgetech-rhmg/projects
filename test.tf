module "alb_api" {
  source = "./modules/alb"

  # Core
  app_name    = var.app_name
  environment = var.environment
  vpc_id      = var.network.vpc_id
  subnet_ids  = var.network.subnet_ids

  # Security
  security_group_id = module.aws_security_group_web.aws_security_group_id

  # TLS
  certificate_arn = module.acm_api.certificate_arn

  # Target / EC2
  instance_id       = module.ec2.instance_id
  target_port       = 5000
  health_check_path = "/health"

  # Tags
  tags = module.tags.tags
}