module "nlb_ro" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name               = local.nlb_ro_dns_name
  acm_r53update_validate        = true
  tags                          = var.tags
}

module "nlb_rw" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name               = local.nlb_rw_dns_name
  acm_r53update_validate        = true
  tags                          = var.tags
}
