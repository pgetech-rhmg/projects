module "nlb_ro_cname" {

  providers = {
    aws = aws.r53
  }

  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"

  zone_id = data.aws_route53_zone.private_zone.zone_id

  records = [
    {
      name    = local.nlb_ro_dns_name
      type    = "CNAME"
      ttl     = "300"
      records = [aws_lb.nlb_readonly.dns_name]
    }
  ]
}

module "nlb_rw_cname" {

  providers = {
    aws = aws.r53
  }

  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"

  zone_id = data.aws_route53_zone.private_zone.zone_id

  records = [
    {
      name    = local.nlb_rw_dns_name
      type    = "CNAME"
      ttl     = "300"
      records = [aws_lb.nlb_readwrite.dns_name]
    }
  ]
}
