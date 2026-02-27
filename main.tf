resource "aws_lb" "api" {
  name               = "pge-epic-${var.app_name}-${var.environment}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.aws_security_group_web.aws_security_group_id]
  subnets            = var.network.subnet_ids
  tags               = module.tags.tags
}

resource "aws_lb_target_group" "api" {
  name     = "pge-epic-${var.app_name}-${var.environment}-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.network.vpc_id

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = module.tags.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.acm_api.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = module.tags.tags
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = module.ec2.instance_id
  port             = 5000
}
