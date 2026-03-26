################################################################################
# External DNS Policy
################################################################################

# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy


data "aws_iam_policy_document" "external_dns_iam_policy_document" {

  statement {
    effect = "Allow"
    resources = distinct(concat(
      upper(var.domain_env) == "NONPROD" ? [
        "arn:aws:route53:::hostedzone/Z1PO7XO596QKJW"
        ] : [
        "arn:aws:route53:::hostedzone/Z11LPAP1YPL6IP",
        "arn:aws:route53:::hostedzone/Z18QBAZ6GCMPEK"
      ],
      var.route53_zone_arns
    ))
    actions = ["route53:ChangeResourceRecordSets"]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
  }

  statement {
    sid       = "PermissionToAssumeTFCBR53Role"
    effect    = "Allow"
    resources = ["arn:aws:iam::${upper(var.domain_env) == "NONPROD" ? "514712703977" : "686137062481"}:role/TFCBR53Role"]
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

locals {
  external_dns_policy_name = coalesce(var.external_dns_policy_name, "${var.policy_name_prefix}-ExternalDNS")
}

resource "aws_iam_policy" "external_dns" {
  count = var.create_external_dns_role ? 1 : 0

  name        = "${var.cluster_name}-external-dns"
  description = "Permissions for External DNS"
  policy      = data.aws_iam_policy_document.external_dns_iam_policy_document.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count = var.create_external_dns_role && var.attach_external_dns_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}