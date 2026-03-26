data "aws_opensearch_domain" "domain" {
  count       = var.domain_search ? 1 : 0
  domain_name = var.domain_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#Domain Policy
module "domain_policy" {
  source = "../../modules/domain_policy"

  count           = var.domain_search ? 1 : 0
  domain_name     = data.aws_opensearch_domain.domain[0].domain_name
  access_policies = data.aws_iam_policy_document.domain_policy[0].json
}