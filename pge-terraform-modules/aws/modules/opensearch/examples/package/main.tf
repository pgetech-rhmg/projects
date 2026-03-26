module "package" {
  source = "../../modules/package"

  package_name        = var.package_name
  package_description = var.package_description

  s3_bucket_name = var.s3_bucket_name
  s3_key         = var.s3_key

}

module "package_association" {
  source = "../../modules/package_association"

  count = var.domain_search ? 1 : 0

  package_id  = module.package.package_id
  domain_name = data.aws_opensearch_domain.domain[0].domain_name
}

data "aws_opensearch_domain" "domain" {
  count       = var.domain_search ? 1 : 0
  domain_name = var.domain_name
}