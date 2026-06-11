# epic-pipeline-module-aws-network

## Overview

Terraform module that resolves an existing AWS network (VPC and private subnets) for EPIC workloads by reading SSM Parameter Store values populated by SAF 2.0.

This module does not create a VPC, subnets, route tables, NAT Gateways, or Internet Gateways. Networking in PG&E AWS accounts is provisioned and managed centrally by SAF 2.0 — this module is the read-only adapter that exposes the resulting `vpc_id` and `private_subnet_ids` to downstream EPIC modules (compute, ALB, RDS, security groups, etc.) so workloads do not need to hardcode subnet IDs in `.pipeline/epic.json` or Terraform code.

## Resources

| Type | Name | Purpose |
|------|------|---------|
| `data.aws_ssm_parameter` | `vpc_id` | Reads VPC ID from SSM |
| `data.aws_ssm_parameter` | `subnet_a` | Reads private subnet A ID from SSM |
| `data.aws_ssm_parameter` | `subnet_b` | Reads private subnet B ID from SSM |

No managed resources are created.

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `ssm_vpc_id_parameter` | `string` | SSM parameter name that stores the existing VPC ID |
| `ssm_private_subnet_a_parameter` | `string` | SSM parameter name that stores private subnet A ID |
| `ssm_private_subnet_b_parameter` | `string` | SSM parameter name that stores private subnet B ID |

### Optional

None.

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `vpc_id` | `string` | ID of the existing VPC resolved from SSM |
| `private_subnet_ids` | `list(string)` | Two-element list of private subnet IDs (subnet A, subnet B) |

## Usage in a Terraform project

```hcl
module "network" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-network.git?ref=main"

  ssm_vpc_id_parameter           = "/saf/network/vpc-id"
  ssm_private_subnet_a_parameter = "/saf/network/private-subnet-a"
  ssm_private_subnet_b_parameter = "/saf/network/private-subnet-b"
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
```

## Usage from another module

```hcl
module "network" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-network.git?ref=main"

  ssm_vpc_id_parameter           = var.ssm_vpc_id_parameter
  ssm_private_subnet_a_parameter = var.ssm_private_subnet_a_parameter
  ssm_private_subnet_b_parameter = var.ssm_private_subnet_b_parameter
}

module "alb" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-alb.git?ref=main"

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  # ...
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |

No provider version constraints are pinned by this module; the consuming project pins the AWS provider.

## Notes

- The SSM parameters are expected to be populated by SAF 2.0 in each PG&E AWS account. Parameter names vary by account and environment — pass them in via `.pipeline/epic.json` Terraform variables rather than hardcoding.
- `private_subnet_ids` is always a two-element list. Workloads requiring more than two AZs are not supported by this module as written.
- The IAM role used by EPIC Terraform runs must have `ssm:GetParameter` on the three parameters above.
