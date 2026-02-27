###############################################################################
# Route 53 Record — ALIAS
###############################################################################

resource "aws_route53_record" "alias" {
  count   = var.record_type != null ? 1 : 0

  zone_id = var.zone_id
  name    = var.domain_name
  type    = var.record_type

  alias {
    name                   = var.target_domain_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}


###############################################################################
# Route 53 Record — CNAME
###############################################################################

resource "aws_route53_record" "cname" {
  for_each = {
    for dvo in var.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.target_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
