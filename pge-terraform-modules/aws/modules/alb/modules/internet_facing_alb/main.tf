/*
* AWS Application Load Balancer
* Terraform module which creates SAF2.0 AWS Application Load Balancer
*/

#
#  Filename    : aws/module/alb/modules/internet_facing_alb/main.tf
#  Date        : 22 March 2022
#  Author      : TCS
#  Description : This terraform module creates internal alb for relevant aws services.

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : alb
# Description : This terraform module creates alb for relevant aws services.

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })

  # The local block is used to extract the values form the variable 'lb_target_group'. The processed value is used in
  # the resource 'aws_lb_target_group_attachment'. The local variable 'lb_target_group_attachment' will provide the corresponding
  # values to the argument 'target_group_arn' and 'target_id' depending upon the number of target groups that is created. A variable
  # tg_index is created and it is used to assign the target_id accordingly.

  lb_target_group_attachment = merge(flatten([
    for index, group in var.lb_target_group : [
      for target_index, targets in group : {
        for target_key, target in targets : join(".", [group.name, target_key]) => merge({ tg_index = group.name }, target)
      }
      if target_index == "targets"
    ]
  ])...)

  # The local variables 'lb_listener_http_redirect' and 'lb_listener_http_fixed_response' are used to process and
  # extract the values for the 'redirect' and 'fixed-response' code block in the resource 'lb_listener_http'.

  lb_listener_http_redirect = flatten([for index, value in var.lb_listener_http : [
  for ki, va in value : merge({ redirect_index = index }, va) if ki == "redirect"]])

  lb_listener_http_fixed_response = flatten([for index, value in var.lb_listener_http : [
  for ki, va in value : merge({ fixed_response_index = index }, va) if ki == "fixed_response"]])

  # The local variables 'lb_listener_https_redirect' and 'lb_listener_https_fixed_response' are used to process and
  # extract the values for the 'redirect' and 'fixed-response' code block in the resource 'lb_listener_https'.

  lb_listener_https_redirect = flatten([for index, value in var.lb_listener_https : [
  for ki, va in value : merge({ redirect_index = index }, va) if ki == "redirect"]])

  # The local variable 'certificates' is used to process the variable values
  # given in the resource 'lb_listener_certificate'. The values given in the variable
  # 'certificate_arn' must be a list of string so that the user can give mutiple certificates.
  # Since the for_each doesn't support list(map(string)), we need to convert the values into map(string).
  # The local variable 'certificates' converts list(map(string)) to map(string) so that for_each
  # can be use the 'aws_lb_listener_certificate' resource.

  certificates = { for index, value in var.certificate_arn : index => value }

  # The local variable 'lb_listener_rule_http' converts the list(map(string)) to map(string). This
  # local variable is used in the resource 'aws_lb_listener_rule' for creating multiple listener rules.

  lb_listener_rule_http = { for index, value in var.lb_listener_rule_http : index => value }

  # The resource 'aws_lb_listener_rule' can create multiple listener rules. The for_each only supports
  # map(string). The local variable 'lb_listener_rule_https' converts the list(map(string)) to map(string).

  lb_listener_rule_https = { for index, value in var.lb_listener_rule_https : index => value }
}

#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
#------------------------------------------------------------------------------
resource "aws_lb" "lb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  access_logs {
    bucket  = var.bucket_name
    prefix  = "alb-logs"
    enabled = true
  }

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields
  idle_timeout               = var.idle_timeout
  enable_waf_fail_open       = var.enable_waf_fail_open
  customer_owned_ipv4_pool   = var.customer_owned_ipv4_pool
  ip_address_type            = var.ip_address_type
  desync_mitigation_mode     = var.desync_mitigation_mode
  enable_http2               = var.enable_http2

  tags = local.module_tags
}

# The 'aws_lb_target_group' resource can create multiple target groups. In the for_each function, the variable 'lb_target_group'
# is converted into a map(string) since the for_each loop do not supports list(map(string)). The arguments provided in lookup are
# optional variables.

resource "aws_lb_target_group" "lb_target_group" {
  for_each = { for tg in var.lb_target_group : tg.name => tg }

  name        = each.value.name
  target_type = each.value.target_type
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  tags        = local.module_tags

  name_prefix                        = lookup(each.value, "name_prefix", null)
  deregistration_delay               = lookup(each.value, "deregistration_delay", null)
  lambda_multi_value_headers_enabled = lookup(each.value, "lambda_multi_value_headers_enabled", null)
  load_balancing_algorithm_type      = lookup(each.value, "load_balancing_algorithm_type", null)
  preserve_client_ip                 = lookup(each.value, "preserve_client_ip", null)
  protocol_version                   = lookup(each.value, "protocol_version", null)
  proxy_protocol_v2                  = lookup(each.value, "proxy_protocol_v2", null)
  slow_start                         = lookup(each.value, "slow_start", null)

  lifecycle {
    create_before_destroy = true
  }

  dynamic "health_check" {
    for_each = each.value.health_check

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      interval            = lookup(health_check.value, "interval", null)
      matcher             = lookup(health_check.value, "matcher", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness

    content {
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      cookie_name     = lookup(stickiness.value, "cookie_name", null)
      enabled         = lookup(stickiness.value, "enabled", null)
      type            = stickiness.value.type
    }
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each = local.lb_target_group_attachment != null ? local.lb_target_group_attachment : {}

  target_group_arn  = aws_lb_target_group.lb_target_group[each.value.tg_index].arn
  target_id         = each.value.target_id
  port              = lookup(each.value, "port", null)
  availability_zone = lookup(each.value, "availability_zone", null)
}

resource "aws_lb_listener" "lb_listener_http" {
  for_each = { for lhp in var.lb_listener_http : lhp.port => lhp }

  load_balancer_arn = aws_lb.lb.arn

  port     = each.value.port
  protocol = each.value.protocol

  default_action {
    type             = each.value.type
    target_group_arn = contains(["forward"], lookup(each.value, "type", "")) ? aws_lb_target_group.lb_target_group[each.value.target_group_name].id : null
    dynamic "redirect" {
      for_each = [for index, re in local.lb_listener_http_redirect : re if re.redirect_index >= 0]

      content {
        path        = lookup(redirect.value, "path", null)
        host        = lookup(redirect.value, "host", null)
        port        = lookup(redirect.value, "port", null)
        protocol    = lookup(redirect.value, "protocol", null)
        query       = lookup(redirect.value, "query", null)
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = [for index, fr in local.lb_listener_http_fixed_response : fr if fr.fixed_response_index >= 0]

      content {
        content_type = fixed_response.value.content_type
        message_body = lookup(fixed_response.value, "message_body", null)
        status_code  = lookup(fixed_response.value, "status_code", null)
      }
    }
  }

  tags = local.module_tags
}

# Resource 'lb_listener_https' is used to create multiple https listener.

resource "aws_lb_listener" "lb_listener_https" {
  for_each = { for lhps in var.lb_listener_https : lhps.port => lhps }

  load_balancer_arn = aws_lb.lb.arn

  port     = each.value.port
  protocol = each.value.protocol

  certificate_arn = each.value.certificate_arn
  ssl_policy      = lookup(each.value, "ssl_policy", "ELBSecurityPolicy-TLS13-1-2-2021-06")

  default_action {
    type             = each.value.type
    target_group_arn = contains(["forward"], lookup(each.value, "type", "")) ? aws_lb_target_group.lb_target_group[each.value.target_group_name].id : null

    dynamic "redirect" {
      for_each = [for index, re in local.lb_listener_https_redirect : re if re.redirect_index >= 0]

      content {
        path        = lookup(redirect.value, "path", null)
        host        = lookup(redirect.value, "host", null)
        port        = lookup(redirect.value, "port", null)
        protocol    = lookup(redirect.value, "protocol", null)
        query       = lookup(redirect.value, "query", null)
        status_code = redirect.value.status_code
      }
    }
    dynamic "fixed_response" {
      for_each = [for index, fr in local.lb_listener_http_fixed_response : fr if fr.fixed_response_index >= 0]

      content {
        content_type = fixed_response.value.content_type
        message_body = lookup(fixed_response.value, "message_body", null)
        status_code  = lookup(fixed_response.value, "status_code", null)
      }
    }
  }

  tags = local.module_tags
}

resource "aws_lb_listener_certificate" "lb_listener_certificate" {
  for_each = local.certificates

  listener_arn    = aws_lb_listener.lb_listener_https[each.value.lb_listener_https_port].arn
  certificate_arn = each.value.certificate_arn
}

# The resource 'aws_lb_listener_rule' can create multiple listener rules. The for_each only supports
# map(string).

resource "aws_lb_listener_rule" "lb_listener_rule_http" {
  for_each = local.lb_listener_rule_http

  listener_arn = aws_lb_listener.lb_listener_http[each.value.lb_listener_http_port].arn
  priority     = lookup(each.value, "priority", null)

  #redirect
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "redirect"
    ]

    content {
      type = action.value["type"]
      redirect {

        path        = lookup(action.value, "path", null)
        host        = lookup(action.value, "host", null)
        port        = lookup(action.value, "port", null)
        protocol    = lookup(action.value, "protocol", null)
        query       = lookup(action.value, "query", null)
        status_code = action.value.status_code
      }
    }
  }

  #fixed-response
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "fixed-response"
    ]

    content {
      type = action.value["type"]
      fixed_response {
        content_type = action.value.content_type
        message_body = lookup(action.value, "message_body", null)
        status_code  = lookup(action.value, "status_code", null)
      }
    }
  }

  # forward
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "forward"
    ]

    content {
      type             = action.value["type"]
      target_group_arn = aws_lb_target_group.lb_target_group[action.value.target_group_name].id
    }
  }

  #path pattern condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "path_pattern", [])) != 0
    ]

    content {
      path_pattern {
        values = condition.value["path_pattern"]
      }
    }
  }

  # host_header condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "host_header", [])) != 0
    ]

    content {
      host_header {
        values = condition.value["host_header"]
      }
    }
  }

  # http_header condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "http_header", [])) != 0
    ]

    content {
      dynamic "http_header" {
        for_each = condition.value["http_header"]

        content {
          http_header_name = http_header.value["http_header_name"]
          values           = http_header.value["values"]
        }
      }
    }
  }

  # http_request_method condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "http_request_method", [])) != 0
    ]

    content {
      http_request_method {
        values = condition.value["http_request_method"]
      }
    }
  }

  # query_string condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "query_string", [])) != 0
    ]

    content {
      dynamic "query_string" {
        for_each = condition.value["query_string"]

        content {
          key   = lookup(query_string.value, "key", null)
          value = query_string.value["value"]

        }
      }
    }
  }

  #source_ip condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "source_ip", [])) != 0
    ]

    content {
      source_ip {
        values = condition.value["source_ip"]
      }
    }
  }
  tags = local.module_tags
}

resource "aws_lb_listener_rule" "lb_listener_rule_https" {
  for_each = local.lb_listener_rule_https

  listener_arn = aws_lb_listener.lb_listener_https[each.value.lb_listener_https_port].arn
  priority     = lookup(each.value, "priority", null)

  #redirect
  dynamic "action" {
    for_each = [
      for rule in each.value.actions : rule if rule.type == "redirect"
    ]

    content {
      type = action.value["type"]
      redirect {

        path        = lookup(action.value, "path", null)
        host        = lookup(action.value, "host", null)
        port        = lookup(action.value, "port", null)
        protocol    = lookup(action.value, "protocol", null)
        query       = lookup(action.value, "query", null)
        status_code = action.value.status_code
      }
    }
  }

  #fixed-response
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "fixed-response"
    ]

    content {
      type = action.value["type"]
      fixed_response {
        content_type = action.value.content_type
        message_body = lookup(action.value, "message_body", null)
        status_code  = lookup(action.value, "status_code", null)
      }
    }
  }

  # forward
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "forward"
    ]

    content {
      type             = action.value["type"]
      target_group_arn = aws_lb_target_group.lb_target_group[action.value.target_group_name].id
    }
  }

  #weighted-forward #use type = weighted-forward to use this block.
  dynamic "action" {
    for_each = [
      for action_rule in each.value.actions : action_rule
      if action_rule.type == "weighted-forward"
    ]

    content {
      type = "forward"
      forward {
        dynamic "target_group" {
          for_each = action.value["target_group"]

          content {
            arn    = aws_lb_target_group.lb_target_group[target_group.value.target_group_name].id
            weight = target_group.value["weight"]
          }
        }
        dynamic "stickiness" {
          for_each = [lookup(action.value, "stickiness", {})]

          content {
            enabled  = stickiness.value["enabled"]
            duration = try(stickiness.value["duration"], 10)
          }
        }
      }
    }
  }

  #path pattern condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "path_pattern", [])) != 0
    ]

    content {
      path_pattern {
        values = condition.value["path_pattern"]
      }
    }
  }

  # host_header condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "host_header", [])) != 0
    ]

    content {
      host_header {
        values = condition.value["host_header"]
      }
    }
  }

  # http_header condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "http_header", [])) != 0
    ]

    content {
      dynamic "http_header" {
        for_each = condition.value["http_header"]

        content {
          http_header_name = http_header.value["http_header_name"]
          values           = http_header.value["values"]
        }
      }
    }
  }

  # http_request_method condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "http_request_method", [])) != 0
    ]

    content {
      http_request_method {
        values = condition.value["http_request_method"]
      }
    }
  }

  # query_string condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "query_string", [])) != 0
    ]

    content {
      dynamic "query_string" {
        for_each = condition.value["query_string"]

        content {
          key   = lookup(query_string.value, "key", null)
          value = query_string.value["value"]

        }
      }
    }
  }

  #source_ip condition
  dynamic "condition" {
    for_each = [
      for condition_rule in each.value.conditions : condition_rule
      if length(lookup(condition_rule, "source_ip", [])) != 0
    ]

    content {
      source_ip {
        values = condition.value["source_ip"]
      }
    }
  }

  tags = local.module_tags
}
