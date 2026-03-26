resource "aws_lb" "load_balancer" {
  name               = "${local.queries_resource_name}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.ecs_security_group.id]
  idle_timeout       = 300

  subnets = [
    data.aws_subnet.private1.id,
    data.aws_subnet.private2.id,
    data.aws_subnet.private3.id
  ]

  access_logs {
    bucket  = module.lb_log_bucket.id
    enabled = true
  }

  tags = var.tags
}

resource "aws_route53_record" "service_dns" {
  allow_overwrite = true
  provider        = aws.r53
  zone_id         = data.aws_route53_zone.private_zone.zone_id
  name            = local.lb_fqdn
  type            = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = 443
  protocol          = "HTTPS"
  # Required by Prisma/Brinqa scans, latest ssl policy is at:
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = module.queries_lb_cert.acm_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.id
    type             = "forward"
  }

  tags = var.tags
}

# ALB Target Group keeper
# https://www.terraform.io/docs/providers/random/index.html
resource "random_string" "target_group_suffix" {
  length  = 2
  special = false

  keepers = {
    # Generate a new id each time we switch to a new port
    port = var.application_port
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = "${local.queries_resource_name}${random_string.target_group_suffix.result}"
  port        = var.application_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.mrad_vpc.id
  tags        = var.tags

  health_check {
    path = var.health_check_path
    port = var.application_port
    # AWS load balancers can't send headers in health checks
    # therefore we can only determine whether the listener is up
    # This is due to the Apollo GraphQL service requiring a header
    matcher = "400-499"
  }

  depends_on = [aws_lb.load_balancer]

  lifecycle {
    create_before_destroy = true
  }

}
