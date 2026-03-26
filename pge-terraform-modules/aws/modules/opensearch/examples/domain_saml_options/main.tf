data "aws_opensearch_domain" "domain" {
  count       = var.domain_search ? 1 : 0
  domain_name = var.domain_name
}

module "domain_saml_options" {
  source = "../../modules/domain_saml_options"

  count = var.domain_search ? 1 : 0

  domain_name           = data.aws_opensearch_domain.domain[0].domain_name
  saml_options          = var.saml_options
  metadata_content_file = file("${path.module}/${var.metadata_content_file}")
}