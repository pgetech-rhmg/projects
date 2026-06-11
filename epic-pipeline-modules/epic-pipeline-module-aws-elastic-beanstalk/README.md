# EPIC Module — AWS Elastic Beanstalk

## Overview

Provisions an AWS Elastic Beanstalk application and environment for an EPIC-managed workload. The module wires the EB application, application version (sourced from an S3 artifact), service and instance IAM roles, instance profile, ALB and instance security groups, and the EB environment with explicit VPC, listener, scaling, logging, and (optionally) Secrets Manager integration.

Designed to be consumed from an application's `.infra/` Terraform layout. The application's intent is declared in `.pipeline/epic.json`; this module receives the resolved values as inputs and is invoked by the EPIC engine's infrastructure stage.

---

## Resources

- `aws_elastic_beanstalk_application`
- `aws_elastic_beanstalk_application_version`
- `aws_elastic_beanstalk_environment`
- `aws_iam_role` (EB service role, EC2 instance role)
- `aws_iam_role_policy_attachment` (managed EB service, enhanced health, web tier, worker tier, multicontainer Docker)
- `aws_iam_role_policy` (Secrets Manager `GetSecretValue`, conditional)
- `aws_iam_instance_profile`
- `aws_security_group` (ALB, instances)
- `aws_elastic_beanstalk_solution_stack` (data source, regex lookup)

Resources are named with the prefix `pge-epic-{app_name}-{environment}-...` for deterministic identification.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Logical application name. Used as the basis for all resource names. |
| `environment` | `string` | Deployment environment (`dev`, `test`, `qa`, `prod`). |
| `solution_stack` | `string` | Elastic Beanstalk solution stack name regex (resolved via `aws_elastic_beanstalk_solution_stack` data source, `most_recent = true`). |
| `artifact` | `object({ bucket = string, key = string })` | S3 location of the deployable artifact used to create the EB application version. |
| `network` | `object({ vpc_id = string, private_subnets = list(string), alb_subnets = list(string) })` | VPC and subnet placement for instances and the ALB. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `health_check_path` | `string` | `"/"` | ALB health check path. Must return `200` without authentication. |
| `secrets_manager_arn` | `string` | `null` | ARN of a JSON secret. When set, an inline IAM policy grants `secretsmanager:GetSecretValue` to the EC2 role and the secret is bound to the EB environment via `aws:elasticbeanstalk:application:environmentsecrets` under the `APPSETTINGS` key. |
| `environment_variables` | `map(string)` | `{}` | Application environment variables injected via `aws:elasticbeanstalk:application:environment`. |
| `security` | `object({ public = bool, certificate_arn = optional(string) })` | `{ public = false, certificate_arn = null }` | `public = true` makes the ALB internet-facing; `false` makes it internal. When `certificate_arn` is set, the HTTPS listener on `:443` is enabled with the supplied ACM certificate. |
| `scaling` | `object({ min_size = optional(number), max_size = optional(number), instance_type = optional(string) })` | `{}` | Auto-scaling group sizing. Defaults applied by the module: `min_size = 1`, `max_size = 2`, `instance_type = "t3.medium"`. |
| `tags` | `map(string)` | `{}` | Tags applied to all created resources. |

---

## Outputs

| Name | Description |
|------|-------------|
| `eb_application_name` | Name of the created Elastic Beanstalk application. |
| `eb_environment_name` | Name of the created Elastic Beanstalk environment. |
| `eb_endpoint_url` | Endpoint URL of the EB environment's load balancer. |
| `eb_cname` | CNAME of the EB environment. |

---

## Usage in a Terraform project

Typical placement in an application's `.infra/main.tf`:

```hcl
module "beanstalk" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-elastic-beanstalk.git?ref=main"

  app_name       = "my-api"
  environment    = "dev"
  solution_stack = "^64bit Amazon Linux 2023 .* running .NET 8$"

  artifact = {
    bucket = "pge-epic-my-api-artifacts-dev"
    key    = "builds/my-api-1.2.3.zip"
  }

  network = {
    vpc_id          = data.aws_vpc.this.id
    private_subnets = data.aws_subnets.private.ids
    alb_subnets     = data.aws_subnets.alb.ids
  }

  security = {
    public          = false
    certificate_arn = data.aws_acm_certificate.this.arn
  }

  scaling = {
    min_size      = 2
    max_size      = 4
    instance_type = "t3.medium"
  }

  health_check_path   = "/health"
  secrets_manager_arn = data.aws_secretsmanager_secret.app.arn

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Development"
  }

  tags = {
    Application = "my-api"
    Environment = "dev"
    ManagedBy   = "EPIC"
  }
}
```

The `app_name` and `environment` should match the values resolved by the EPIC engine (`epicAppName`, `epicEnvironment`) so resources line up with the engine's build tags and downstream deploy expectations.

---

## Usage from another module

Compose this module from a higher-level workload module by re-exposing its outputs:

```hcl
module "beanstalk" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-elastic-beanstalk.git?ref=main"

  app_name       = var.app_name
  environment    = var.environment
  solution_stack = var.solution_stack
  artifact       = var.artifact
  network        = var.network
  security       = var.security
  scaling        = var.scaling
  tags           = var.tags
}

output "app_url" {
  value = "https://${module.beanstalk.eb_cname}"
}

output "eb_environment_name" {
  value = module.beanstalk.eb_environment_name
}
```

Exposing `app_url` from the parent module lets EPIC's integration test stage resolve `BASE_URL` from Terraform outputs (see the engine README's IntegrationTest section).

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` provider | `~> 5.90` |

---

## Notes

- The HTTPS listener on `:443` is only created when `security.certificate_arn` is non-null and non-empty; otherwise only the `:80` listener is enabled.
- ALB scheme is derived from `security.public`: `true` → `internet-facing`, `false` → `internal`.
- ALB ingress CIDRs are resolved from `network.allowed_ingress_cidrs`, then `network.private_subnet_cidrs`, falling back to `0.0.0.0/0`. These keys are not declared on the `network` object type and must be added to the variable definition before they can be supplied.
- When `secrets_manager_arn` is set, the secret is mapped into the environment under the EB-native `APPSETTINGS` key — the application reads individual values from that JSON blob at runtime.
- CloudWatch log streaming (`aws:elasticbeanstalk:cloudwatch:logs.StreamLogs`) is always enabled.
- No real EPIC consumer of this module exists in `epic-web/.infra/`, `epic-api/.infra/`, or `projects/`; the example above is synthetic and reflects the module's current variable surface.
