# This module creates a pair of network load balancers (NLBs) 
# to be used as a single point of entry for Neptune requests

resource "aws_lb" "nlb_readwrite" {
  name                             = "${var.prefix}-${var.suffix}-rw"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  tags                             = var.tags

  subnets = [
    data.aws_subnet.mrad1.id,
    data.aws_subnet.mrad2.id,
    data.aws_subnet.mrad3.id
  ]

  access_logs {
    bucket  = "ccoe-nlb-accesslogs-spoke-${var.region}-${local.account_num}-prod"
    prefix  = "mrad-webcore-nlb-readwrite"
    enabled = true
  }
}

resource "aws_lb" "nlb_readonly" {
  name                             = "${var.prefix}-${var.suffix}-ro"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  tags                             = var.tags

  subnets = [
    data.aws_subnet.mrad1.id,
    data.aws_subnet.mrad2.id,
    data.aws_subnet.mrad3.id
  ]

  access_logs {
    bucket  = "ccoe-nlb-accesslogs-spoke-${var.region}-${local.account_num}-prod"
    prefix  = "mrad-webcore-nlb-readonly"
    enabled = true
  }
}

# LISTENERS
resource "aws_lb_listener" "listener_readwrite" {
  load_balancer_arn = aws_lb.nlb_readwrite.arn
  port              = 8182
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.nlb_rw.acm_certificate_arn
  tags              = var.tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_readwrite.arn
  }
}

resource "aws_lb_listener" "listener_readonly" {
  load_balancer_arn = aws_lb.nlb_readonly.arn
  port              = 8182
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.nlb_ro.acm_certificate_arn
  tags              = var.tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_readonly.arn
  }
}

# TARGET GROUPS
resource "aws_lb_target_group" "tg_readwrite" {
  name        = "${var.prefix}-tg-${var.suffix}-rw"
  port        = 8182
  protocol    = "TLS"
  vpc_id      = data.aws_vpc.mrad_vpc.id
  target_type = "ip"
  tags        = var.tags

  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "tg_readonly" {
  name        = "${var.prefix}-tg-${var.suffix}-ro"
  port        = 8182
  protocol    = "TLS"
  vpc_id      = data.aws_vpc.mrad_vpc.id
  target_type = "ip"
  tags        = var.tags
  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}
