# epic-pipeline-module-aws-load-balancer

Internal Application Load Balancer with an HTTPS listener and a single EC2 target attachment. Used by EPIC application stacks (`.pipeline/epic.json`) to front EC2-backed services with TLS termination.

---

## Resources

- `aws_lb.default` — internal Application Load Balancer
- `aws_lb_target_group.default` — HTTP target group with health check
- `aws_lb_listener.https` — HTTPS listener on port 443 (TLS 1.3 1-2 policy)
- `aws_lb_target_group_attachment.default` — registers the EC2 instance with the target group

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name used for naming ALB resources. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `vpc_id` | `string` | The ID of the VPC that the ALB and target group belong to. |
| `subnet_ids` | `list(string)` | Subnet IDs to attach to the ALB. |
| `security_group_id` | `string` | Security group ID to attach to the ALB. |
| `certificate_arn` | `string` | ARN of the ACM certificate for the HTTPS listener. |
| `instance_id` | `string` | EC2 instance ID to register with the target group. |
| `tags` | `map(string)` | Common tags. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `target_port` | `number` | `5000` | Port the target EC2 instance listens on. |
| `health_check_path` | `string` | `/health` | HTTP path used for target group health checks. |
| `health_check_port` | `number` | `5000` | Port the target group health check probes. |

---

## Outputs

| Name | Description |
|------|-------------|
| `alb` | The full `aws_lb` object. |
| `alb_arn` | ARN of the ALB. |
| `alb_dns_name` | DNS name of the ALB. Consumed by the Route53 module as `target_domain_name`. |
| `alb_dns_zone_id` | Hosted zone ID of the ALB. Consumed by the Route53 module as `target_zone_id`. |
| `target_group` | The full `aws_lb_target_group` object. |
| `target_group_arn` | ARN of the target group. |
| `listener_arn` | ARN of the HTTPS listener. |

---

## Usage in a Terraform Project

Drop into an application's `.infra/main.tf`. This is the canonical pattern from `epic-api/.infra/main.tf` — internal ALB fronting an EC2 instance, fed an ACM certificate and the EC2 instance ID from sibling modules.

```hcl
module "load_balancer_api" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

  app_name          = "${var.app_name}-api"
  environment       = var.environment
  tags              = module.tags.tags
  vpc_id            = var.network.vpc_id
  subnet_ids        = var.network.subnet_ids
  security_group_id = module.aws_security_group_web.aws_security_group_id
  certificate_arn   = module.acm_api.certificate_arn
  instance_id       = module.ec2.instance_id
  target_port       = 5000
  health_check_path = var.health_check_path
}

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

---

## Usage from Another Module

Compose this module from a higher-level stack module that already owns the VPC, security group, certificate, and EC2 instance. Pass identifiers in directly and bubble outputs up to the caller.

```hcl
module "load_balancer" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-load-balancer.git?ref=main"

  app_name          = var.app_name
  environment       = var.environment
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  security_group_id = var.alb_security_group_id
  certificate_arn   = var.certificate_arn
  instance_id       = var.instance_id
  target_port       = var.target_port
  health_check_path = var.health_check_path
  tags              = var.tags
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}

output "alb_dns_zone_id" {
  value = module.load_balancer.alb_dns_zone_id
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |

---

## Notes

- The ALB is hardcoded to `internal = true`. It is not reachable from the public internet — pair it with a Route53 record in a private hosted zone, or front it with an external CloudFront/WAF if external exposure is required.
- The HTTPS listener uses `ELBSecurityPolicy-TLS13-1-2-2021-06` and forwards 100% of traffic to the single target group. There is no HTTP-to-HTTPS redirect listener.
- Only one EC2 target is registered. For multi-instance fleets, attach additional `aws_lb_target_group_attachment` resources outside this module against `target_group_arn`.
