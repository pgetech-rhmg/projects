###############################################################################
# Tags
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id     = var.aws_account_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}


###############################################################################
# AMI — PINNED (Amazon Linux 2023, x86_64)
#
# This is a hand-built, stateful box: the scan toolchain and ADO agent are
# installed by hand over SSM (see documents/scan-agent-setup.md), NOT baked
# into the AMI. A `most_recent = true` lookup is therefore a landmine — the
# moment Amazon publishes a newer AL2023 AMI, any `terraform apply` (even an
# unrelated one like an instance-type resize) plans to REPLACE the instance and
# wipe the toolchain + agent registration. We pin the AMI to the one the box was
# built on so applies stay in-place. Bump var.ami_id deliberately only when you
# intend to rebuild the box from the runbook.
###############################################################################


###############################################################################
# Security Group — egress only
#
# The agent needs no inbound rules: access is via SSM Session Manager, which is
# outbound-initiated. Egress is left open on 443 so the agent can reach Azure
# DevOps, the internal SonarQube server, Wiz, and AWS Secrets Manager. We do NOT
# reuse epic-api's web/api/db SGs — those carry app-specific ingress this host
# must not expose.
###############################################################################

resource "aws_security_group" "scan_agent" {
  name        = "pge-epic-scan-agent-${var.environment}"
  description = "EPIC ADO scan agent - egress only, no inbound (SSM access)"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS to ADO, SonarQube, Wiz, Secrets Manager, package repos"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.tags.tags, {
    Name = "pge-epic-scan-agent-${var.environment}"
  })
}


###############################################################################
# Secrets Manager Read Policy
#
# Lets the agent pull scan credentials (WIZ_CLIENT_ID/SECRET, GITHUB_PAT) at
# runtime, scoped to the listed secret ARNs only. Skipped when none provided.
###############################################################################

data "aws_iam_policy_document" "scan_secrets" {
  count = length(var.scan_secret_arns) > 0 ? 1 : 0

  statement {
    sid    = "ReadScanSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.scan_secret_arns
  }
}

resource "aws_iam_policy" "scan_secrets" {
  count = length(var.scan_secret_arns) > 0 ? 1 : 0

  name   = "pge-epic-scan-agent-${var.environment}-secrets-read"
  policy = data.aws_iam_policy_document.scan_secrets[0].json
  tags   = module.tags.tags
}


###############################################################################
# Scan Agent (EC2)
#
# Hosts the `EPIC - Self-hosted` Azure DevOps agent. The scan toolchain
# (ADO agent, .NET SDK, dotnet-sonarscanner, JRE, Node, wizcli) is installed
# by hand over SSM Session Manager — see documents/scan-agent-setup.md.
# user_data is intentionally null so Terraform never clobbers that state.
###############################################################################

module "scan_agent" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  app_name      = "scan-agent"
  environment   = var.environment
  ami           = var.ami_id
  instance_type = var.instance_type

  network = {
    subnet_id          = var.subnet_id
    security_group_ids = [aws_security_group.scan_agent.id]
  }

  # create_instance_profile attaches AmazonSSMManagedInstanceCore (for Session
  # Manager access) plus any custom policy ARNs below.
  iam = {
    create_instance_profile = true
    policy_arns             = length(var.scan_secret_arns) > 0 ? [aws_iam_policy.scan_secrets[0].arn] : []
  }

  root_volume = {
    size = var.root_volume_size
    type = "gp3"
  }

  user_data = null

  tags = merge(module.tags.tags, {
    Role = "ado-scan-agent"
    Pool = "EPIC - Self-hosted"
  })
}
