module "queries_lb_cert" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.0.7"

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  acm_domain_name        = local.lb_fqdn
  acm_r53update_validate = true
  tags                   = var.tags
  # This only applies in the prod account, but will overwrite a previous instance if it exists
  acm_subject_alternative_names = var.git_branch == "main" ? local.lb_subject_alternative_names : []
}
