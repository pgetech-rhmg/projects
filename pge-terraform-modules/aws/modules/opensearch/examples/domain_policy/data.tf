data "aws_iam_policy_document" "domain_policy" {
  count = var.domain_search ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${data.aws_opensearch_domain.domain[0].domain_name}/*"]
  }
}

