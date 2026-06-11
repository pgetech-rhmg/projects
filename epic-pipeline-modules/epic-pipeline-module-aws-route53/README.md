# EPIC AWS Route53 Module

## Overview

Reusable Terraform module that manages Route53 records for EPIC applications. Supports two record patterns from a single module:

- **Alias records** — point a hosted zone record at an AWS-managed target (CloudFront distribution, ALB, etc.) using `aws_route53_record.alias` with the AWS-recommended `evaluate_target_health` semantics
- **CNAME validation records** — fan out CNAMEs from an ACM certificate's `domain_validation_options` to satisfy DNS-based certificate validation

Consumed by application `.infra/` directories (referenced via `app.infraPath` in `.pipeline/epic.json`) to expose deployed services on PG&E DNS.

---

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_route53_record.alias` | Alias record pointing `domain_name` in `zone_id` at a target (CloudFront, ALB, etc.). Created when `record_type` is set. |
| `aws_route53_record.cname` | CNAME records created from ACM `domain_validation_options` for certificate validation. TTL fixed at 60s. |

---

## Inputs

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `domain_name` | `string` | `null` | Domain name for the alias record (e.g., `epic-web-dev.lab.pge.com`). |
| `zone_id` | `string` | `null` | Route53 hosted zone ID that hosts `domain_name`. |
| `record_type` | `string` | `null` | Record type for the alias (typically `A` or `AAAA`). When omitted, the alias record is not created. |
| `target_domain_name` | `string` | `null` | DNS name of the alias target (e.g., CloudFront `distribution_domain_name`, ALB `dns_name`). |
| `target_zone_id` | `string` | `null` | Hosted zone ID of the alias target (e.g., CloudFront's fixed `Z2FDTNDATAQYW2`, or an ALB's `dns_zone_id`). Also used as the zone for any CNAME validation records. |
| `evaluate_target_health` | `bool` | `false` | Whether Route53 should evaluate target health when answering. Set `true` for ALB targets, `false` for CloudFront. |
| `domain_validation_options` | `list(object)` | `[]` | List of ACM certificate validation records. Each object must have `domain_name`, `resource_record_name`, `resource_record_type`, `resource_record_value`. |

---

## Outputs

| Output | Description |
|--------|-------------|
| `validation_record_fqdns` | List of FQDNs for the created CNAME validation records. Use as `validation_record_fqdns` input to `aws_acm_certificate_validation`. |

---

## Usage in a Project

The canonical patterns live in `epic-web/.infra/main.tf` (CloudFront alias) and `epic-api/.infra/main.tf` (ALB alias).

### Alias record to a CloudFront distribution (epic-web)

```hcl
module "aws_route53_record_web_private" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                = var.private_hosted_zone_id
  domain_name            = var.domain_name
  record_type            = "A"
  target_domain_name     = module.cloudfront.distribution_domain_name
  target_zone_id         = "Z2FDTNDATAQYW2"
  evaluate_target_health = false
}
```

`Z2FDTNDATAQYW2` is the fixed CloudFront hosted zone ID. Health evaluation is disabled — CloudFront does not expose target health to Route53.

### Alias record to an ALB (epic-api)

```hcl
module "aws_route53_record_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  zone_id                = var.private_hosted_zone_id
  domain_name            = var.api_domain_name
  record_type            = "A"
  target_domain_name     = module.load_balancer_api.alb_dns_name
  target_zone_id         = module.load_balancer_api.alb_dns_zone_id
  evaluate_target_health = true
}
```

Health evaluation is enabled so Route53 only answers when the ALB's target group is healthy.

---

## Composition Usage

### CNAME validation for an ACM certificate

When the ACM certificate module returns `domain_validation_options`, pass them through to create the validation CNAMEs in the public hosted zone:

```hcl
module "acm_validation_records" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-route53.git?ref=main"

  target_zone_id            = var.public_hosted_zone_id
  domain_validation_options = module.acm.domain_validation_options
}
```

Then feed the output into `aws_acm_certificate_validation`:

```hcl
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = module.acm.certificate_arn
  validation_record_fqdns = module.acm_validation_records.validation_record_fqdns
}
```

### Alias-only vs validation-only vs combined

The module's two resources are independent:

- Set `record_type` (and the alias inputs) to create only the alias record
- Pass `domain_validation_options` to create only validation CNAMEs
- Both can be set in the same call

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

---

## Notes

- `target_zone_id` serves a dual purpose: it is the alias target's hosted zone (when creating an alias) and the zone that holds the CNAME validation records (when `domain_validation_options` is set). In a combined call, both must reference the same zone.
- CNAME validation records use a 60s TTL to keep ACM validation responsive; this is not configurable.
