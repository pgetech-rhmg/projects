# epic-pipeline-module-aws-security-group

Terraform module that provisions an AWS security group with optional CIDR-based and security-group-referenced ingress/egress rules. Used by EPIC application repos in their `.infra/` Terraform to define network boundaries for ALBs, EC2 instances, and RDS.

---

## Resources Created

- `aws_security_group.default` — Named `pge-epic-{app_name}-{environment}-{label}-sg`
- `aws_security_group_rule.cidr_ingress` — One per entry in `cidr_ingress_rules`
- `aws_security_group_rule.cidr_egress` — One per entry in `cidr_egress_rules`
- `aws_security_group_rule.security_group_ingress` — One per entry in `security_group_ingress_rules`
- `aws_security_group_rule.security_group_egress` — One per entry in `security_group_egress_rules`

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used for resource naming. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `label` | `string` | Additional naming label (e.g., `web`, `api`, `db`). |
| `description` | `string` | Security group description. |
| `vpc_id` | `string` | ID of the VPC the security group belongs to. |
| `tags` | `map(string)` | Common tags applied to the security group. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `cidr_ingress_rules` | `list(object)` | `[]` | Ingress rules sourced from CIDR ranges. |
| `cidr_egress_rules` | `list(object)` | `[]` | Egress rules targeting CIDR ranges. |
| `security_group_ingress_rules` | `list(object)` | `[]` | Ingress rules sourced from another security group. |
| `security_group_egress_rules` | `list(object)` | `[]` | Egress rules targeting another security group. |

**`cidr_ingress_rules` / `cidr_egress_rules` object shape:**

| Field | Type | Description |
|-------|------|-------------|
| `from` | `number` | Start port. |
| `to` | `number` | End port. |
| `protocol` | `string` | Protocol (`tcp`, `udp`, `-1` for all). |
| `cidr_blocks` | `list(string)` | IPv4 CIDR ranges. |
| `ipv6_cidr_blocks` | `list(string)` | IPv6 CIDR ranges. |
| `prefix_list_ids` | `list(string)` | VPC prefix list IDs. |
| `description` | `string` | Rule description. |

**`security_group_ingress_rules` / `security_group_egress_rules` object shape:**

| Field | Type | Description |
|-------|------|-------------|
| `from` | `number` | Start port. |
| `to` | `number` | End port. |
| `protocol` | `string` | Protocol (`tcp`, `udp`, `-1` for all). |
| `source_security_group_id` | `string` | Source/target security group ID. |
| `description` | `string` | Rule description. |

---

## Outputs

| Name | Description |
|------|-------------|
| `aws_security_group` | The full `aws_security_group` resource object. |
| `aws_security_group_id` | The security group ID (use this when referencing from other rules or attaching to instances/ALBs). |
| `aws_security_group_arn` | The security group ARN. |

---

## Usage in a Terraform Project

The pattern below comes from `epic-api/.infra/main.tf` and shows two security groups that cross-reference each other: a `web` SG (ALB) that allows HTTPS in from PG&E CIDR ranges and explicitly egresses to the `api` SG, and an `api` SG (EC2) that only accepts traffic from the `web` SG.

```hcl
module "aws_security_group_web" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = var.app_name
  environment = var.environment
  label       = "web"
  tags        = module.tags.tags
  description = "Allow HTTPS for internal ALB from PG&E network"
  vpc_id      = var.network.vpc_id

  cidr_ingress_rules = [
    {
      description      = "CCOE Ingress rules 1"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "CCOE Ingress rules 2"
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["172.16.0.0/12"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  cidr_egress_rules = [
    {
      description      = "CCOE egress rules"
      from             = 0
      to               = 65535
      protocol         = "tcp"
      cidr_blocks      = ["10.90.108.0/23"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  security_group_egress_rules = [
    {
      description              = "Allow ALB to reach API"
      from                     = 5000
      to                       = 5000
      protocol                 = "tcp"
      source_security_group_id = module.aws_security_group_api.aws_security_group_id
    }
  ]
}

module "aws_security_group_api" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = var.app_name
  environment = var.environment
  label       = "api"
  tags        = module.tags.tags
  description = "Allow traffic from ALB only"
  vpc_id      = var.network.vpc_id

  cidr_egress_rules = [
    {
      description      = "Allow outbound"
      from             = 0
      to               = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  security_group_ingress_rules = [
    {
      description              = "Allow ALB to reach API"
      from                     = 5000
      to                       = 5000
      protocol                 = "tcp"
      source_security_group_id = module.aws_security_group_web.aws_security_group_id
    }
  ]
}
```

The `aws_security_group_id` output is then attached to consumers — e.g., `module.load_balancer_api` (with the `web` SG) and `module.ec2` (with the `api` SG) — to enforce the boundary.

---

## Usage from Another Module (Composition)

Wrap the module inside a higher-level composition module, exposing the SG ID for downstream resources:

```hcl
module "app_sg" {
  source      = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"
  app_name    = var.app_name
  environment = var.environment
  label       = "app"
  tags        = var.tags
  description = "Application security group"
  vpc_id      = var.vpc_id

  security_group_ingress_rules = var.ingress_from_sgs
  cidr_egress_rules            = var.egress_cidrs
}

output "app_security_group_id" {
  value = module.app_sg.aws_security_group_id
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |

---

## Notes

- **`cidr_*_rules` vs `security_group_*_rules`** — Use `cidr_ingress_rules` / `cidr_egress_rules` when the source/target is an IP range (PG&E corporate CIDRs, `0.0.0.0/0`, etc.). Use `security_group_ingress_rules` / `security_group_egress_rules` when the source/target is another security group ID — this is how you express "ALB → API → DB" boundaries without hardcoding IPs.
- **Cross-referencing security groups** — Two SGs can reference each other (web ↔ api) because Terraform creates the `aws_security_group` resources first, then layers the rules on top. Pass `module.<other_sg>.aws_security_group_id` between modules, as shown in the `web`/`api` example.
- **Rule keying** — Rules are keyed by `description + from + to + protocol`. Two rules with identical values across these fields will collide; vary the `description` to keep them distinct.
- **Naming** — The SG name is fixed as `pge-epic-{app_name}-{environment}-{label}-sg`. Use `label` to disambiguate multiple SGs for the same app (e.g., `web`, `api`, `db`).
- This module is invoked from an application's `.infra/` Terraform during the EPIC DeployInfra stage. Application identity (`app_name`, `environment`) is passed in from the app's variables and is not read from `.pipeline/epic.json` directly by this module.
