# epic-pipeline-module-aws-certificate

Issues and DNS-validates an AWS ACM certificate for a domain hosted in Route53. Supports certificates in the caller's default region (e.g. for ALB/API Gateway) or in `us-east-1` (required by CloudFront).

---

## Resources Created

- `aws_acm_certificate.default` — ACM certificate in the caller's default provider region (when `certificate_type = "default"`)
- `aws_acm_certificate.public` — ACM certificate in `us-east-1` via the `aws.us_east_1` provider alias (when `certificate_type = "public"`)
- `aws_acm_certificate_validation.default` / `aws_acm_certificate_validation.public` — Waits for DNS validation to complete
- `module.aws_route53_record` — Creates the DNS validation `CNAME` records in the supplied public hosted zone (delegates to `epic-pipeline-module-aws-route53`)

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `domain_name` | `string` | The domain name for the ACM certificate. |
| `public_hosted_zone_id` | `string` | The Route53 hosted zone ID used for DNS validation records. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `certificate_type` | `string` | `"default"` | `"default"` issues in the caller's default AWS provider region. `"public"` issues in `us-east-1` (e.g. for CloudFront). |
| `tags` | `map(string)` | `{}` | A map of tags to apply to all resources. |

---

## Outputs

| Name | Description |
|------|-------------|
| `certificate_arn` | ARN of the validated ACM certificate. |
| `certificate_domain_name` | Primary domain name of the ACM certificate. |
| `certificate_status` | Status of the ACM certificate. |
| `validation_record_fqdns` | FQDNs of the DNS validation records created in Route53. |

---

## Usage in a Terraform Project

Consumers of this module are application `.infra/` directories that conform to the EPIC contract (`.pipeline/epic.json`). Both the ALB and CloudFront patterns are shown.

### CloudFront (public certificate in `us-east-1`)

From `epic-web/.infra/main.tf`:

```hcl
module "acm_web" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = "public"
  tags                  = module.tags.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### ALB / API Gateway (default region)

From `epic-api/.infra/main.tf`:

```hcl
module "acm_api" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.api_domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = "default"
  tags                  = module.tags.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

The certificate ARN is then consumed downstream:

```hcl
module "load_balancer_api" {
  # ...
  certificate_arn = module.acm_api.certificate_arn
}

module "cloudfront" {
  # ...
  custom_acm_certificate_arn = module.acm_web.certificate_arn
}
```

---

## Usage from Another Module (Composition)

When composing this module inside another module, pass both provider configurations through:

```hcl
module "acm" {
  source                = "git::https://github.com/pgetech/epic-pipeline-module-aws-certificate.git?ref=main"
  domain_name           = var.domain_name
  public_hosted_zone_id = var.public_hosted_zone_id
  certificate_type      = var.certificate_type
  tags                  = var.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

The parent module must declare the `aws.us_east_1` configuration alias in its own `versions.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.90"
      configuration_aliases = [aws.us_east_1]
    }
  }
}
```

---

## Provider & Terraform Versions

| Requirement | Version |
|-------------|---------|
| `terraform` | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

This module declares an `aws.us_east_1` configuration alias because ACM certificates used by CloudFront must be issued in `us-east-1`. Callers are required to pass both providers — even when `certificate_type = "default"` — via the `providers` block:

```hcl
providers = {
  aws           = aws
  aws.us_east_1 = aws.us_east_1
}
```

The root project is responsible for declaring the two AWS provider blocks (one default, one aliased to `us-east-1`).

---

## Notes

- `certificate_type = "public"` is for any certificate that must live in `us-east-1` (CloudFront, regardless of where the rest of the stack is deployed). `certificate_type = "default"` issues into whichever region the default `aws` provider is configured for, and is the right choice for ALBs, API Gateway, and other regional services.
- Validation is DNS-only and is driven through `epic-pipeline-module-aws-route53`, which writes the required `CNAME` records into `public_hosted_zone_id`. The `aws_acm_certificate_validation` resource then blocks until AWS confirms the records.
- `create_before_destroy` is set on the certificate so in-place rotations don't take down the consuming listener/distribution.
