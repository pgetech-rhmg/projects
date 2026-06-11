# epic-pipeline-module-aws-ec2

## Overview

Terraform module that provisions a single AWS EC2 instance for EPIC-managed workloads. Used by application `.infra/` configurations to host runtime services (e.g., a .NET API behind an internal ALB).

The module creates the instance, an optional IAM role and instance profile (with `AmazonSSMManagedInstanceCore` attached by default plus any caller-supplied policy ARNs), and an encrypted root EBS volume. IMDSv2 is required, EBS optimization is enabled, and detailed monitoring is on.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_instance.this` | EC2 instance with IMDSv2 enforced and detailed monitoring enabled |
| `aws_iam_role.this` | Instance role (created when `iam.create_instance_profile = true`) |
| `aws_iam_instance_profile.this` | Instance profile bound to the role |
| `aws_iam_role_policy_attachment.default_ssm` | Attaches `AmazonSSMManagedInstanceCore` to the created role |
| `aws_iam_role_policy_attachment.custom` | Attaches each ARN in `iam.policy_arns` to the created role |

Naming follows `pge-epic-{app_name}-{environment}-*`.

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Logical application name used in resource names and tags |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`) |
| `ami` | `string` | AMI ID to launch |
| `instance_type` | `string` | EC2 instance type (e.g., `t3.medium`) |
| `network` | `object({ subnet_id = string, security_group_ids = list(string) })` | Subnet and security groups for the ENI |
| `root_volume` | `object({ size = number, type = string, kms_key_id = optional(string) })` | Root EBS volume; always encrypted |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `iam` | `object({ create_instance_profile = bool, role_name = optional(string), policy_arns = optional(list(string), []) })` | `{ create_instance_profile = true, role_name = null, policy_arns = [] }` | When `create_instance_profile` is `true`, the module creates a role/profile and attaches `policy_arns`. When `false`, supply `role_name` to attach an existing instance profile |
| `user_data` | `string` | `null` | User data script executed on first boot (use for systemd unit setup, package installs, etc.) |
| `tags` | `map(string)` | `{}` | Tags merged onto the instance, role, and instance profile (a `Name` tag is added automatically) |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | EC2 instance ID (consume in load balancer / SSM deploy modules) |
| `private_ip` | Instance private IP |
| `private_dns` | Instance private DNS name |
| `iam_role_name` | Resolved role name — created role when `create_instance_profile = true`, otherwise the value of `iam.role_name` |

## Usage in a Project

Called from an application's `.pipeline/epic.json`-driven `.infra/main.tf`. Example from `epic-api/.infra/main.tf`:

```hcl
module "ec2" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-ec2.git?ref=main"

  app_name      = "${var.app_name}-api"
  environment   = var.environment
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network = {
    subnet_id          = var.network.subnet_ids[0]
    security_group_ids = [module.aws_security_group_api.aws_security_group_id]
  }

  iam = {
    create_instance_profile = true
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      module.secretmanager.secret_read_arn,
      aws_iam_policy.rds_secret_read.arn
    ]
  }

  root_volume = {
    size = 20
    type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -e

dnf update -y
dnf install -y libicu unzip jq awscli git

mkdir -p /opt/${var.app_name}-api/app

cat > /etc/systemd/system/${var.app_name}-api.service <<-SERVICE
[Unit]
Description=${var.app_name}-api
After=network.target

[Service]
WorkingDirectory=/opt/${var.app_name}-api/app
ExecStart=/opt/${var.app_name}-api/app/${var.app_executable}
Restart=always
RestartSec=5
User=ec2-user
Environment=ASPNETCORE_URLS=http://0.0.0.0:5000
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable ${var.app_name}-api
EOF

  tags = module.tags.tags
}
```

## Composition

The EC2 module is typically composed with sibling EPIC modules:

| Module | Role |
|--------|------|
| `epic-pipeline-module-aws-tags` | Standard PG&E tag set, passed via `tags` |
| `epic-pipeline-module-aws-security-group` | Provides `network.security_group_ids` (e.g., an `api` SG that only allows traffic from the `web` ALB SG) |
| `epic-pipeline-module-aws-secretmanager` | Provides `secret_read_arn` for `iam.policy_arns` so the instance can pull runtime secrets |
| `epic-pipeline-module-aws-load-balancer` | Consumes `instance_id` to register the instance behind an internal ALB |

The EPIC deploy stage targets the instance via SSM using `instance_id` — exposing it as a Terraform output named `instance_id` lets the deploy stage resolve the target automatically.

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS provider | `~> 5.90` |

## Notes

- The root volume is always encrypted; `root_volume.kms_key_id` is optional and falls back to the AWS-managed key when omitted.
- `AmazonSSMManagedInstanceCore` is attached automatically when the module creates the role, which is required for EPIC's SSM-based deploys (`dotnet`, `python`, `java` on EC2).
- When `iam.create_instance_profile = false`, the supplied `iam.role_name` must reference an existing **instance profile** name (not just a role).
- `disable_api_termination` is `false` — instances can be replaced via Terraform without manual intervention.
