# EPIC Infrastructure Steering Document

This document is the single source of truth for AI agents (and humans) generating the
`.infra/` Terraform code and `.pipeline/epic.json` config for **any** project that runs
through the EPIC pipeline. It is self-contained — point an AI at this file along with
the project repo and it should have everything it needs.

---

## 0. How this document interacts with other steering docs

This is a **platform reference**, not a prescription. It tells you *which modules
exist*, *what they do*, and *how to wire them into EPIC*. It does not dictate which
modules a particular project must use.

When this document is used alongside project-specific steering docs (architecture
decisions, design docs, ADRs, team conventions, etc.), apply this precedence:

1. **Project steering docs win on technology choice.** If the project's docs call for
   Aurora and this document's "decision guide" suggests something simpler — use Aurora.
   If the project mandates SQS + Lambda fan-out and this doc shows a single SNS topic —
   follow the project docs.
2. **This document wins on *how* to invoke EPIC modules.** Module sources, required
   inputs, the `epic.json` contract, the `.infra/` file layout, the pipeline-injected
   variables, the tags-first pattern, and the BTP secrets flow are non-negotiable —
   they're how EPIC actually runs. A project doc that says "use the `hashicorp/aws`
   `aws_s3_bucket` resource directly" should be overridden by EPIC's `aws-s3` module.
3. **If a project wants a service EPIC has a module for, use the EPIC module.** Don't
   reach for raw `resource "aws_*"` blocks when an `epic-pipeline-module-aws-<name>`
   module covers the same ground — the modules carry tagging, encryption, and SAF
   compliance defaults that raw resources don't.
4. **If a project wants a service EPIC does *not* have a module for, raw resources are
   fine** — but still apply EPIC's tagging (`module.tags.tags`), file layout, and
   `epic.json` contract.
5. **Surface conflicts, don't paper over them.** If a project doc demands something
   that breaks an EPIC contract (e.g. hardcoding a backend config, skipping tags,
   committing secrets), call it out before generating code — don't silently choose
   one and ship.
6. **Surface every raw resource you write.** Whenever you use `resource "aws_*"`,
   `resource "azurerm_*"`, or any other raw provider resource because EPIC has no
   module for it, you must:
   - **Tell the user up front, before generating code.** List each resource type and
     why no EPIC module covers it (e.g. "EPIC has no module for AWS EventBridge —
     using `aws_cloudwatch_event_rule` and `aws_cloudwatch_event_target` directly").
   - **Add a short comment in the `.tf` file** above the raw resource(s) noting the
     same — one line, marker pattern: `# NOTE: raw resource — no EPIC module for <service>`.
   - **List every raw-resource block in the final summary** when you finish generating
     the `.infra/`. The user should never have to grep the diff to discover that a
     raw resource was used.

   This rule applies even when project steering docs explicitly request the raw
   resource. The user gets full visibility into which parts of the infra are EPIC-
   compliant module calls and which are bespoke.

   **Companion-resource allowlist (no flagging required).** Some raw resources are
   normal, expected wiring around an EPIC module — they don't *replace* a module,
   they *wire it up*. Don't flag these:

   ```
   aws_lambda_permission              aws_api_gateway_base_path_mapping
   aws_lambda_event_source_mapping    aws_api_gateway_domain_name
   aws_lambda_layer_version           aws_api_gateway_api_key
   aws_cloudwatch_log_group           aws_api_gateway_usage_plan
   aws_cloudwatch_event_rule          aws_api_gateway_usage_plan_key
   aws_cloudwatch_event_target        aws_ses_email_identity
   aws_scheduler_schedule             aws_ses_domain_identity
   aws_security_group_rule            aws_ses_event_destination
   ```

   Only flag raw resources that stand in for a missing module (e.g. an EPIC service
   that has no published `epic-pipeline-module-aws-*` yet).

7. **Never fork or vendor an EPIC module.** If a module is missing functionality, the
   right answer is "raise it to the EPIC platform team" — not a sidecar `resource`
   block that re-implements what the module is supposed to do, and not a copy of the
   module in the project tree. The whole point of EPIC modules is centralized SAF
   compliance; forking breaks that.

8. **All EPIC modules use `?ref=main`.** The source-string pattern is always:
   `git::https://github.com/pgetech/epic-pipeline-module-<cloud>-<name>.git?ref=main`.
   Do not pin to a different branch, commit SHA, or version tag — that's a future
   policy change to this document, not a runtime decision.

The decision guide in §10 is a **default starting point** for projects with no other
guidance. Project steering docs always override it.

---

## 1. What you are producing

For any application repo that runs through EPIC, you are producing two things:

1. **`.pipeline/epic.json`** — the EPIC contract (what kind of app this is, where the
   code/infra lives, what cloud it deploys to).
2. **`.infra/`** — a directory of Terraform files that the EPIC engine runs through
   `terraform init / plan / apply` against the target cloud.

The path of `.infra/` and `.pipeline/` can be overridden via `epic.json` (`infraPath`,
`configPath`). Defaults are `.infra` and `.pipeline` at the repo root.

---

## 2. The `epic.json` contract

`.pipeline/epic.json` has two top-level sections: `app` and `cloud`.

### 2.1 `app` section

| Field | Required | Notes |
|---|---|---|
| `appName` | yes | Short kebab-case slug. Used in resource names, ADO build tags, and Terraform state keys. |
| `appType` | yes | One of: `react`, `angular`, `node`, `dotnet`, `python`, `java`, `infra`, `btp`. Drives stage template selection in the pipeline. |
| `codePath` | yes | Path (relative to repo root) where the app source code lives. |
| `infraPath` | no | Path to the `.infra` Terraform directory. Defaults to `.infra`. |
| `configPath` | no | Path to the `.pipeline` directory containing `epic.json`. Defaults to `.pipeline`. |
| `runtimeVersion` | no | Runtime version pinned for build stages (e.g. `"18"`, `"22"`, `"8.0"`). |
| `scanTool` | no | Override for the security scan tool. |
| `buildTestTool` | no | Override for the build-test tool (e.g. `vitest`, `jest`, `xunit`). |
| `integrationTestTool` | no | Override for integration tests. |
| `approvalEnvironments` | no | Array of environments that require manual approval before deploy (e.g. `["qa","prod"]`). |

### 2.2 `cloud` section

The cloud provider is auto-detected by the orchestrator using these rules **in order**:

1. `app.appType == "btp"` → BTP (uses AWS Secrets Manager for credentials)
2. `cloud.awsAccountId` present → AWS
3. `cloud.azureSubscriptionId` present → Azure
4. fallback → AWS

#### AWS (`app.appType` is anything except `btp`)
```json
"cloud": {
  "awsAccountId": "123456789012",
  "awsRegion": "us-west-2"
}
```

#### Azure
```json
"cloud": {
  "azureSubscriptionId": "00000000-0000-0000-0000-000000000000",
  "azureRegion": "westus2"
}
```

#### BTP (`app.appType: "btp"`)
```json
"cloud": {
  "awsAccountId": "123456789012",
  "awsRegion": "us-west-2",
  "secretsManager": {
    "name": "<aws-secrets-manager-secret-name>",
    "keys": ["BTP_USERNAME", "BTP_PASSWORD", "CF_USER", "CF_PASSWORD"]
  }
}
```

For BTP, `secretsManager.name` is the AWS Secrets Manager secret to fetch, and
`secretsManager.keys` is the subset of keys to materialize as env vars. The pipeline
writes these into a sourced env file before each Terraform step.

### 2.3 Minimal examples by app shape

**Angular/React SPA → S3 + CloudFront on AWS:**
```json
{
  "app": {
    "appName": "my-spa",
    "appType": "angular",
    "codePath": "/",
    "buildTestTool": "vitest"
  },
  "cloud": { "awsAccountId": "123456789012", "awsRegion": "us-west-2" }
}
```

**Node/Lambda backend on AWS:**
```json
{
  "app": {
    "appName": "my-api",
    "appType": "node",
    "codePath": "/",
    "runtimeVersion": "22",
    "approvalEnvironments": ["qa", "prod"]
  },
  "cloud": { "awsAccountId": "123456789012", "awsRegion": "us-west-2" }
}
```

**.NET app on Azure App Service:**
```json
{
  "app": { "appName": "my-svc", "appType": "dotnet", "codePath": "/", "runtimeVersion": "8.0" },
  "cloud": { "azureSubscriptionId": "00000000-0000-0000-0000-000000000000", "azureRegion": "westus2" }
}
```

**SAP BTP subaccount:**
```json
{
  "app": { "appName": "my-btp-env", "appType": "btp", "infraPath": "/", "configPath": "/.pipeline" },
  "cloud": {
    "awsAccountId": "123456789012", "awsRegion": "us-west-2",
    "secretsManager": {
      "name": "pge-epic-btp-secrets",
      "keys": ["BTP_USERNAME","BTP_PASSWORD","CF_USER","CF_PASSWORD"]
    }
  }
}
```

---

## 3. `.infra/` file layout

Use the following layout for **AWS** and **Azure** projects. (BTP layout differs — see
§7.) The split into "standard files" + "per-service files" is mandatory: it keeps each
file small enough to reason about and matches how every existing EPIC project is
organized.

### 3.1 Standard files (always present)

| File | Purpose |
|---|---|
| `terraform.tf` | `terraform { required_version, required_providers, backend "<s3\|azurerm>" {} }` block + `provider` blocks. Backend is left empty — the pipeline injects `-backend-config` flags. |
| `variables.tf` | Every `variable` declaration used anywhere in `.infra/`. |
| `terraform.auto.tfvars` | Concrete values for every variable. Loaded automatically by Terraform. |
| `main.tf` | Top-level wiring: `module "tags"`, shared security groups, ACM certs, things that don't justify their own file. |
| `outputs.tf` | Every `output` declaration. |

### 3.2 Per-service `.tf` files (one per logical service/module group)

Create **one `.tf` file per logical service** so the file name describes what's in it
at a glance. Examples:

- `lambda.tf` — all Lambda function definitions and layers
- `api_gateway.tf` — API Gateway + Lambda permissions + custom domain
- `dynamodb.tf` — all DynamoDB tables (often using `for_each` over a `locals` map)
- `s3_cloudfront.tf` — S3 bucket + CloudFront distribution + OAC
- `kms.tf` — CMKs for encryption
- `aurora.tf` — Aurora PostgreSQL cluster
- `rds_proxy.tf` — RDS Proxy fronting Aurora
- `cloudwatch.tf` — log groups, metric filters, dashboards
- `sns.tf` — topics + subscriptions
- `app_service.tf`, `function.tf`, `key_vault.tf`, `postgresql.tf`, `storage.tf` (Azure)

Rule of thumb: if a file would exceed ~150 lines or mix two unrelated services, split
it. If you only have one or two modules total (e.g. a static SPA), it's fine to keep
everything in `main.tf` — but as soon as you add a third concern, split.

### 3.3 Why this layout

- The pipeline runs `terraform init/plan/apply` from `infraPath` — there is no
  per-environment directory; environments are differentiated by **state key + tfvars**,
  not by directory.
- The pipeline injects `-var="aws_account_id=..."`, `-var="environment=..."`,
  `-var="aws_region=..."` (AWS) or `-var="subscription_id=..."`, `-var="tenant_id=..."`,
  `-var="environment=..."`, `-var="azure_region=..."` (Azure) at plan time. These
  variables **must** be declared in `variables.tf`.
- Most other inputs come from `terraform.auto.tfvars` (loaded automatically).

---

## 4. `terraform.tf` templates

### 4.1 AWS
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# Required only if you use ACM with CloudFront (cert must be in us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
```

### 4.2 Azure
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

### 4.3 BTP
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "~> 1.0"
    }
  }

  backend "s3" {}
}

# Provider auth is via env vars sourced by the pipeline:
#   BTP_USERNAME, BTP_PASSWORD (btp provider)
#   CF_USER, CF_PASSWORD       (cloudfoundry provider)
provider "btp" {
  globalaccount = var.globalaccount
}

provider "cloudfoundry" {
  api_url = var.cf_api_url
}
```

---

## 5. Required variables

These **must** be declared in `variables.tf` because the pipeline passes them via
`-var=` flags. Missing any of these will fail `terraform plan`.

### AWS / BTP (uses S3 backend in an AWS account)
```hcl
variable "aws_account_id" { type = string }
variable "aws_region"     { type = string }
variable "environment"    { type = string }   # dev | test | qa | prod
```

### Azure
```hcl
variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }
variable "azure_region"    { type = string }
variable "environment"     { type = string }
```

### Standard EPIC tagging vars (required by the `tags` module)

Every project should declare these and pass them to `module "tags"`:

```hcl
variable "appid"              { type = number }                  # AMPS application ID
variable "notify"             { type = list(string) }            # email addresses
variable "owner"              { type = list(string) }            # exactly 3 LANIDs
variable "order"              { type = number }                  # 7-9 digit cost center order
variable "dataclassification" { type = string  default = "Internal" }
variable "compliance"         { type = list(string) default = ["None"] }
variable "cris"               { type = string  default = "Low" }   # Cyber Risk Impact Score
variable "principal_orgid"    { type = string  default = "o-7vgpdbu22o" }  # AWS only — fixed PG&E AWS Org ID
variable "project_tag"        { type = string }                  # short PascalCase resource-name prefix
```

> **`principal_orgid` is a fixed value — always `o-7vgpdbu22o`.** This is the PG&E AWS Organization ID, identical for every account in scope of EPIC. Any module that needs it (`aws-kms` for the org-membership condition in DenyFromInternet, `aws-static-web`, anything else that takes an org-id input) gets the same literal. Always set `principal_orgid = "o-7vgpdbu22o"` in `terraform.auto.tfvars` (or rely on the default above). Never leave a `TODO_*` placeholder for it, and never source it per-environment.

---

## 6. Standard `main.tf` skeleton (AWS)

Every AWS `.infra/main.tf` should start with the tags module — everything else then
references `module.tags.tags`:

```hcl
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
```

For Azure, swap `aws-tags` for `azure-tags` and `aws_account_id` for `subscription_id`.

---

## 7. BTP layout (special case)

BTP projects do **not** use the AWS/Azure module catalog. They use the SAP/btp and
cloudfoundry/cloudfoundry providers directly. Layout:

| File | Purpose |
|---|---|
| `provider.tf` | `terraform { required_providers, backend "s3" {} }` + `provider "btp" {}` + `provider "cloudfoundry" {}` |
| `variables.tf` | `globalaccount`, `subaccount_name`, `cf_api_url`, etc. |
| `main.tf` | `btp_subaccount`, `btp_subaccount_entitlement`, `cloudfoundry_space`, `cloudfoundry_service_instance` resources |
| `outputs.tf` | Subaccount ID, CF org/space GUIDs, service binding URLs |
| `<appName>.tfvars` | Concrete values; the pipeline runs `terraform plan -var-file="${appName}.tfvars"` |

The pipeline retrieves keys listed in `cloud.secretsManager.keys` from AWS Secrets
Manager and exports them as env vars (e.g. `BTP_USERNAME`, `BTP_PASSWORD`, `CF_USER`,
`CF_PASSWORD`) before each Terraform step. Do not commit credentials.

---

## 8. AWS module catalog

All AWS modules live at `git::https://github.com/pgetech/epic-pipeline-module-aws-<name>.git?ref=main`.

### aws-api-gateway
- **Purpose**: REST API with optional Lambda authorizer, CORS, and VPC/edge endpoints.
- **Required**: `api_name`, `stage_name`
- **Key optional**: `endpoint_type` (default `PRIVATE`), `description`, `enable_authorizer` (false), `authorizer_function_arn`, `authorizer_function_invoke_arn`, `authorizer_result_ttl`, `cors_allow_origins`, `cors_allow_methods`, `cors_allow_headers`, `gateway_responses`, `tags`
- **Outputs**: `rest_api_id`, `rest_api_arn`, `execution_arn`, `root_resource_id`, `stage_invoke_url`, `authorizer_id`
- **Notes**: For PRIVATE endpoints, pass `vpc_endpoint_ids = [var.vpc_endpoint_id]` (the transit VPCE). Wire Lambda permissions via `execution_arn` (use a direct `aws_lambda_permission` resource per non-stream Lambda). For custom domains, pair with `aws-certificate` and `aws-route53`.
- **Footguns**:
  - **`cors_allow_origins` / `cors_allow_methods` / `cors_allow_headers` are `string`, NOT `list(string)`.** They must be quoted-CSV form: `cors_allow_origins = "'*'"` or `cors_allow_origins = "'https://a.com,https://b.com'"`. Note the **inner single quotes** — these are the values API Gateway emits as response headers.
  - **`gateway_responses` is `list(string)`** of response-type names (e.g. `["UNAUTHORIZED", "ACCESS_DENIED", "DEFAULT_4XX", "DEFAULT_5XX"]`), NOT a map of objects.
  - **Output is `rest_api_id`, NOT `api_id`** — referencing `module.api_gateway.api_id` fails `terraform validate`.

### aws-aurora-postgresql
- **Purpose**: Aurora PostgreSQL cluster (Serverless v2 default), TLS-enforced, SAF-aligned.
- **Required**: `app_name`, `environment`, `tags`, `vpc_id`, `subnet_ids` (≥ 2 AZs)
- **Key optional**: `engine_version` (16.4), `instance_class` (db.serverless), `instance_count` (1), `database_name`, `master_username` (epic_master), `manage_master_user_password` (true), `kms_key_id`, `backup_retention_period` (30, ≥15 required), `deletion_protection` (true), `serverlessv2_scaling_configuration`, `iam_database_authentication_enabled` (false), `performance_insights_enabled` (true), `enabled_cloudwatch_logs_exports`, `cluster_parameters`, `ingress_security_group_ids`
- **Outputs**: `cluster_id`, `cluster_identifier`, `cluster_arn`, `cluster_resource_id`, `cluster_endpoint`, `reader_endpoint`, `port`, `database_name`, `master_username`, `master_user_secret_arn`, `instance_endpoints`, `instance_identifiers`, **`security_group_id`** (NOT `cluster_security_group_id`), `security_group_arn`, `db_subnet_group_name`, `db_cluster_parameter_group_name`, `db_parameter_group_name`
- **Notes**: Typically fronted by `aws-rds-proxy`. Pair with `aws-kms` when data class is Confidential/Restricted.
- **Footguns**:
  - **For Serverless v2, do NOT set `engine_mode = "serverless"`** — that is **Aurora Serverless v1**, a different product. Use `engine_mode = "provisioned"` (the module's default) plus `serverlessv2_scaling_configuration = { min_capacity = ..., max_capacity = ... }` for v2.
  - **Cluster-side IAM auth is OFF when fronted by RDS Proxy.** Set `iam_database_authentication_enabled = false` (the default). The proxy authenticates as master via the RDS-managed master secret; the proxy is the IAM-auth boundary for clients.
  - **Use `manage_master_user_password = true`** so RDS manages the master secret in Secrets Manager. Do NOT also provision a Secrets Manager entry for the master password.

### aws-certificate
- **Purpose**: ACM cert with DNS validation in Route53; supports CloudFront (us-east-1).
- **Required**: `domain_name`, `public_hosted_zone_id`
- **Key optional**: `certificate_type` (`default`, or `public` for CloudFront in us-east-1), `tags`
- **Outputs**: `certificate_arn`, `certificate_domain_name`, `certificate_status`, `validation_record_fqdns`
- **Footguns**:
  - **Every call to this module REQUIRES a `providers = { aws = aws, aws.us_east_1 = aws.us_east_1 }` block at the call site** — even when the cert is regional (API Gateway, ALB), not just for CloudFront. The module's `versions.tf` declares both providers as required configuration; calling without this block fails `terraform init` with `Error: Missing required provider configuration`.
  - This means `provider "aws" { alias = "us_east_1", region = "us-east-1" }` is **always present** in `terraform.tf` whenever any certificate is provisioned, regardless of whether the workload uses CloudFront.

### aws-cloudfront
- **Purpose**: CloudFront distribution fronting an S3 origin via OAC, secure defaults.
- **Required**: `app_name`, `environment`, `bucket_name`, `bucket_arn`, `bucket_regional_domain_name`, `tags`, `principal_orgid`
- **Key optional**: `price_class` (PriceClass_100), `custom_domain_aliases` ([]), `custom_acm_certificate_arn` (must be us-east-1), `cors_allowed_origins` (["*"]), `web_acl_id`
- **Outputs**: `distribution_id`, `distribution_arn`, `distribution_domain_name`
- **Notes**: OAC-only, no public S3. For end-to-end static site, `aws-static-web` packages S3 + CloudFront + deploy.
- **Footguns**:
  - **No `distribution_hosted_zone_id` is exported.** For Route 53 alias records pointing at CloudFront, use the CloudFront-global hosted-zone ID `Z2FDTNDATAQYW2` (this is a fixed AWS-published value, not a per-distribution one) — wire it via a local or a variable; do not invent a module output.
  - For a centrally-managed WebACL (e.g. Firewall-Manager-managed), pass its ARN as `web_acl_id`. Do NOT create your own `aws_wafv2_web_acl` or `aws_wafv2_ip_set` if one is supplied.
  - **`principal_orgid` is required** because this module owns the `aws_s3_bucket_policy` on the backing bucket and overwrites whatever `aws-s3` wrote. The cloudfront module re-emits the CCOE-TFE `DenyNonOrgAccess` (using `principal_orgid`) and `DenyNonSecureAccess` statements alongside the CloudFront read-allow, so the org-membership and TLS-only guardrails survive. Always pass `principal_orgid = "o-7vgpdbu22o"` (the fixed PG&E AWS Org ID).

### aws-cloudtrail
- **Purpose**: App-specific CloudTrail with multi-region, log file validation, optional CW Logs.
- **Required**: `app_name`, `environment`, `tags`, `s3_bucket_name`
- **Key optional**: `custom_trail_name`, `s3_key_prefix`, `include_global_service_events` (true), `is_multi_region_trail` (true), `is_organization_trail` (false), `enable_log_file_validation` (true), `enable_logging` (true), `kms_key_id`, `sns_topic_name`, `cloudwatch_logs_group_arn`, `cloudwatch_logs_role_arn`, `event_selectors`, `advanced_event_selectors`
- **Outputs**: `trail_id`, `trail_arn`, `trail_name`, `trail_home_region`
- **Notes**: Caller owns S3 bucket policy, KMS key, CW role.

### aws-cloudwatch
- **Purpose**: Log groups with retention, metric filters, dashboards.
- **Required**: `app_name`, `environment`, `tags`
- **Key optional**: `log_group_name`, `custom_log_group_name`, `retention_in_days` (90), `log_group_kms_key_id`, `metric_filters`, `dashboard_body`, `log_group_skip_destroy` (false)
- **Outputs**: `log_group_name`, `log_group_arn`, `metric_filter_names`, `dashboard_name`, `dashboard_arn`
- **Notes**: Lambda log groups must use this module. Pair with `aws-cloudwatch-alarm`.

### aws-cloudwatch-alarm
- **Purpose**: CloudWatch metric alarm with thresholds and SNS/Lambda actions.
- **Required**: `alarm_name`, `namespace`, `metric_name`, `threshold`
- **Key optional**: `alarm_description`, `statistic` (Average), `comparison_operator` (GreaterThanThreshold), `period` (300), `evaluation_periods` (1), `dimensions` ({}), `alarm_actions`, `ok_actions`, `treat_missing_data` (missing), `tags`
- **Outputs**: `alarm_arn`, `alarm_name`
- **Notes**: Wire `alarm_actions` to an SNS topic from `aws-sns`.

### aws-deploy-static-site
- **Purpose**: Upload static files to an existing S3 bucket (deployment-only, no infra).
- **Required**: `app_name`, `bucket_name`
- **Key optional**: `app_path` (`/`), `cache_control`, `content_type_overrides`
- **Outputs**: `deployed_bucket`, `file_count`
- **Notes**: Files resolved from `${path.root}/${app_name}/${app_path}`. Usually you don't need this directly — `aws-static-web` includes it.

### aws-dynamodb
- **Purpose**: DynamoDB table (Standard or FIFO) with optional GSIs, streams, TTL.
- **Required**: `table_name`, `hash_key`
- **Key optional**: `billing_mode` (PAY_PER_REQUEST), `hash_key_type` (S), `range_key`, `range_key_type` (S), `global_secondary_indexes` ([]), `additional_attributes` ([]), `stream_enabled` (false), `stream_view_type` (NEW_AND_OLD_IMAGES), `ttl_attribute`, `deletion_protection_enabled` (false), `point_in_time_recovery` (false), `tags`
- **Outputs**: `table_name`, `table_arn`, `table_id`, `stream_arn`
- **Notes**: For multiple tables, drive with `for_each` over a `locals` map.

### aws-ec2
- **Purpose**: EC2 instance with optional IAM profile, KMS-encrypted root volume, user data.
- **Required**: `app_name`, `environment`, `ami`, `instance_type`, `network` ({subnet_id, security_group_ids}), `root_volume` ({size, type, kms_key_id?})
- **Key optional**: `iam`, `user_data`, `tags`
- **Outputs**: `instance_id`, `private_ip`, `private_dns`, `iam_role_name`

### aws-elastic-beanstalk
- **Purpose**: Elastic Beanstalk app + environment with ALB, autoscaling, S3 artifact deploy.
- **Required**: `app_name`, `environment`, `solution_stack`, `artifact` ({bucket, key}), `network` ({vpc_id, private_subnets, alb_subnets})
- **Key optional**: `health_check_path` (`/`), `environment_variables`, `secrets_manager_arn`, `security` ({public=false}), `scaling`, `tags`
- **Outputs**: `eb_application_name`, `eb_environment_name`, `eb_endpoint_url`, `eb_cname`

### aws-iam-role
- **Purpose**: IAM role with intent-based access (Level 1 simple, Level 2 capabilities, Level 3 expert).
- **Required**: `role_name`
- **Key optional**: `role_type` (`terraform`/`cicd`/`lambda`/`ecs`/`readonly` — drives the auto-generated trust policy), `capabilities` ([]), `custom_trust` (false), `trusted_principals` (**list of objects: `{type = string, provider = optional(string), subject = optional(string), account = optional(string)}`** — used only when `custom_trust = true`), `policy_arns` (managed-policy ARNs), `inline_policies` (**map of `name → json-policy-string`**), `tags`
- **Outputs**: `role_name`, `role_arn`
- **Notes**: Prefer `role_type` + `capabilities` (Levels 1–2). Level 3 is for platform/security teams.
- **Footguns**:
  - **Do not pass `assume_role_policy`, `managed_policy_arns`, or `inline_policy`** — those are raw `aws_iam_role` attributes; the module does NOT expose them. Use `role_type` (or `custom_trust = true` + `trusted_principals`), `policy_arns`, and `inline_policies` (plural, map shape).
  - **`inline_policies` is a map**, not a single JSON string: `inline_policies = { my_policy_name = jsonencode({...}) }`.
  - **For service-trust roles where the service ISN'T Lambda** (EventBridge Scheduler, ECS task, Step Functions, API Gateway logs, etc.): use `custom_trust = true` and `trusted_principals = [{ type = "service", provider = "<service>.amazonaws.com" }]`. The field is **`provider`**, not `identifiers` / `service`. Common values: `scheduler.amazonaws.com`, `events.amazonaws.com`, `ecs-tasks.amazonaws.com`, `states.amazonaws.com`, `apigateway.amazonaws.com`.
  - **Do NOT use `role_type = "lambda"` for non-Lambda services** — that hard-codes `lambda.amazonaws.com` and the assume-role from EventBridge / ECS / etc. will be denied.

### aws-kms
- **Purpose**: KMS CMK with SAF-aligned default policy and rotation enabled.
- **Required**: `app_name`, `environment`, `tags`, `purpose` (e.g. `aurora`, `secrets`, `lambda-env`), `description`
- **Key optional**: `custom_alias`, `key_usage` (ENCRYPT_DECRYPT), `customer_master_key_spec` (SYMMETRIC_DEFAULT), `deletion_window_in_days` (30), `enable_key_rotation` (true), `multi_region` (false), `is_enabled` (true), `bypass_policy_lockout_safety_check` (false), `policy_json`, `security_admin_role_name`, `prisma_role_name`, `internal_cidr_blocks`, `principal_org_id`
- **Outputs**: `key_id`, **`key_arn`** (NOT `kms_key_arn`), `alias_name`, `alias_arn`, `key_rotation_enabled`
- **Notes**: Mandatory for Confidential/Restricted data. DenyFromInternet baked into default policy. Alias is derived from `app_name`+`environment`+`purpose` unless `custom_alias` overrides — produces `alias/<app>-<env>-<purpose>`.
- **Footguns**: One CMK per **data-classification boundary** (typical: one for the database, one for Lambda env-var encryption on Confidential-data Lambdas, one for Secrets Manager). Don't share a CMK across boundaries — Prisma rotation policy and SecurityAdmin lifecycle grants are evaluated per CMK.

### aws-lambda
- **Purpose**: Lambda function with explicit log group, VPC support, exec role.
- **Required**: `function_name`, `handler`, `s3_bucket`, `s3_key`
- **Key optional**: `description`, `runtime` (nodejs22.x), `memory_size` (256), `timeout` (30), `environment_variables`, `layers`, `vpc_config` ({subnet_ids, security_group_ids}), `reserved_concurrent_executions` (-1), `additional_policy_arns`, `inline_policy`, `log_retention_days` (30), `tracing_mode` (PassThrough), `tags`
- **Outputs**: `function_name`, `function_arn`, `invoke_arn`, `role_arn`, `role_name`, `log_group_name`
- **Notes**: For many functions, drive with `for_each` over a `locals.functions` map.

### aws-load-balancer
- **Purpose**: ALB with target group, HTTPS listener, health checks.
- **Required**: `app_name`, `environment`, `vpc_id`, `subnet_ids`, `security_group_id`, `certificate_arn`, `instance_id`
- **Key optional**: `target_port` (5000), `health_check_path` (`/health`), `health_check_port` (5000), `tags`
- **Outputs**: `alb`, `alb_arn`, `alb_dns_name`, `alb_dns_zone_id`, `target_group`, `target_group_arn`, `listener_arn`
- **Notes**: HTTPS-only. Pair with `aws-certificate` for TLS.

### aws-network
- **Purpose**: Read-only — fetches VPC + subnet IDs from SSM Parameter Store.
- **Required**: `ssm_vpc_id_parameter`, `ssm_private_subnet_a_parameter`, `ssm_private_subnet_b_parameter`
- **Outputs**: `vpc_id`, `private_subnet_ids`
- **Notes**: VPCs are pre-provisioned at the account level; this module surfaces them.

### aws-rds-proxy
- **Purpose**: RDS Proxy with IAM auth, TLS, connection pooling.
- **Required**: `app_name`, `environment`, `tags`, `engine_family` (POSTGRESQL/MYSQL/SQLSERVER), `secret_arns` (≥1), `role_arn`, `vpc_subnet_ids` (≥ 2 AZs), `vpc_security_group_ids`, `connection_pool_config`, exactly one of `target_db_cluster_identifier` or `target_db_instance_identifier`
- **Key optional**: `custom_proxy_name`, `require_tls` (true), `iam_auth` (REQUIRED), `client_password_auth_type`, `auth_description`, `username`, `idle_client_timeout` (1800), `debug_logging` (false)
- **Outputs**: `proxy_name`, `proxy_arn`, **`proxy_endpoint`**, `target_group_name`, `target_group_arn`, `target_endpoint`
- **Notes**: Pair with `aws-aurora-postgresql`. Caller composes proxy IAM role and `rds-db:connect` grants on consumer roles.
- **Footguns**:
  - **No `proxy_resource_id` output exists**, and there is no `resource_id` attribute on the underlying `aws_db_proxy` resource OR on the `data "aws_db_proxy"` data source either. The proxy resource ID (shape `prx-XXXXXXXXX`) lives only inside the proxy ARN: `arn:aws:rds:<region>:<account>:db-proxy:<resource-id>`. For IAM `rds-db:connect` policies that need it, **parse it from the ARN**: `local.proxy_resource_id = element(split(":", module.rds_proxy.proxy_arn), 6)`. Do NOT reach for `data.aws_db_proxy.x.resource_id` — that attribute does not exist and `terraform validate` will fail with `Unsupported attribute`.
  - **`secret_arns` must be the cluster's RDS-managed master secret** (`module.aurora_postgresql.master_user_secret_arn`) — the proxy authenticates to Aurora as master via this secret, then accepts IAM auth from clients.

### aws-route53
- **Purpose**: Route53 records (CNAME/A) — typically for ACM validation or service aliases.
- **Required**: `domain_name`, `zone_id`, `record_type`, `target_domain_name`, `target_zone_id`
- **Key optional**: `domain_validation_options`, `evaluate_target_health` (false)
- **Outputs**: `validation_record_fqdns`

### aws-s3
- **Purpose**: S3 bucket with secure defaults (encryption on, versioning optional, public access fully blocked).
- **Required**: `app_name`, `environment`, `tags`
- **Key optional**: `custom_bucket_name`, `force_destroy` (false), `object_ownership` (BucketOwnerEnforced), `enable_public_access_block` (true), `enable_versioning` (false), `sse_algorithm` (AES256), `kms_key_arn`, `enable_access_logging` (false), `access_log_bucket`, `access_log_prefix`, `lifecycle_rules`, `bucket_policy_json`
- **Outputs**: **`bucket_name`** (NOT `bucket_id`), `bucket_arn`, `bucket_domain_name`, `bucket_regional_domain_name`
- **Notes**: No embedded policies; caller wires via `bucket_policy_json` if needed.

### aws-secretmanager
- **Purpose**: Secrets Manager secret with optional rotation/encryption/versioning.
- **Required**: `app_name`, `environment`, `tags`, `secrets_description`
- **Key optional**: `prefix_name`, `custom_policy`, `recovery_window_in_days` (30), `kms_key_id`, `rotation_enabled` (false), `rotation_lambda_arn`, `rotation_after_days`, `secret_version_enabled` (false), `secrets`
- **Outputs**: **`arn`** (NOT `secret_arn`), `rotation_enabled`, `version_ids`, `secrets`, `secret_read_arn`
- **Notes**: For credentials and API keys. Use `aws-ssm-parameter-store` for non-secret config.
- **Footguns**: Do NOT provision a Secrets Manager entry for the Aurora master password — `manage_master_user_password = true` on the cluster makes RDS manage that secret.

### aws-security-group
- **Purpose**: VPC security group with CIDR-based and SG-to-SG rules.
- **Required**: `app_name`, `environment`, `label`, `description`, `vpc_id`, `tags`
- **Key optional**: `cidr_ingress_rules`, `cidr_egress_rules`, `security_group_ingress_rules`, `security_group_egress_rules`
- **Outputs**: `aws_security_group` (full object), **`aws_security_group_id`** (NOT `security_group_id`), `aws_security_group_arn`
- **Footguns**:
  - **`cidr_ingress_rules` / `cidr_egress_rules` object shape (all fields required, no `optional()`):** `{from = number, to = number, protocol = string, cidr_blocks = list(string), ipv6_cidr_blocks = list(string), prefix_list_ids = list(string), description = string}`. Use **`from`/`to`**, NOT `from_port`/`to_port`. Pass `[]` for `ipv6_cidr_blocks` and `prefix_list_ids` when unused — they cannot be omitted.
  - **`security_group_ingress_rules` / `security_group_egress_rules` object shape (for SG-to-SG references):** `{from = number, to = number, protocol = string, source_security_group_id = string, description = string}`.
  - **Output is `aws_security_group_id`** — referencing `module.x.security_group_id` fails `terraform validate`.

### aws-ses
- **Purpose**: SES configuration set with TLS enforcement and reputation metrics.
- **Required**: `app_name`, `environment`
- **Key optional**: `custom_configuration_set_name`, `reputation_metrics_enabled` (true), `sending_enabled` (true), `custom_redirect_domain`, `event_destination` (object: `{name, enabled, matching_types, default_value, dimension_name, value_source}`, default null)
- **Outputs**: `configuration_set_name`, `configuration_set_arn`, `event_destination_name`
- **Notes**: Outbound only. SES not approved for Confidential/Restricted data.
- **Footguns**:
  - **The module declares NO `tags` variable** — do NOT pass `tags = module.tags.tags` (SES configuration sets don't support tags via this module). Apply tags on the email/domain identity instead.
  - **The module does NOT manage email or domain identities** — for `aws_ses_email_identity` / `aws_ses_domain_identity`, use a direct `resource` block.

### aws-sns
- **Purpose**: SNS topic with optional email subscriptions.
- **Required**: `topic_name`
- **Key optional**: `display_name`, `email_subscriptions` ([]), `tags`
- **Outputs**: `topic_arn`, `topic_name`
- **Notes**: Common alarm target. Pair with `aws-cloudwatch-alarm`.

### aws-sqs
- **Purpose**: SQS queue (Standard or FIFO) with encryption, access policy, optional DLQ.
- **Required**: `app_name`, `environment`, `tags`, `queue_name`
- **Key optional**: `custom_queue_name`, `fifo_queue` (false), `content_based_deduplication`, `deduplication_scope`, `fifo_throughput_limit`, `delay_seconds` (0), `max_message_size` (262144), `message_retention_seconds` (1209600), `receive_wait_time_seconds` (0), `visibility_timeout_seconds` (30), `kms_master_key_id`, `kms_data_key_reuse_period_seconds`, `sqs_managed_sse_enabled` (false), `redrive_policy`, `redrive_allow_policy`, `queue_policy_json`, `allowed_principal_arns`, `internal_cidr_blocks`
- **Outputs**: `queue_id`, `queue_url`, `queue_arn`, `queue_name`
- **Notes**: Default policy enforces TLS and DenyFromInternet when `queue_policy_json` is null.
- **Footguns**: The variable is **`visibility_timeout_seconds`**, NOT `visibility_timeout`.

### aws-ssm-parameter-store
- **Purpose**: SSM parameter (String/StringList/SecureString) for config (not secrets).
- **Required**: `app_name`, `environment`, `tags`, `parameter_name`, `value`
- **Key optional**: `custom_name`, `description`, `type` (String), `tier` (Standard), `data_type` (text), `kms_key_id`, `allowed_pattern`, `overwrite` (true)
- **Outputs**: `parameter_name`, `parameter_arn`, `parameter_version`, `parameter_type`
- **Notes**: Not a secrets store. Rejects Confidential/Restricted/Privileged data.

### aws-static-web
- **Purpose**: Composite — packages S3 + CloudFront + static-site deploy with EPIC tagging baked in.
- **Required**: `principal_orgid`, `aws_account_id`, `app_name`, `environment`, `appid`, `notify`, `owner`, `order`
- **Key optional**: `dataclassification` (Internal), `compliance` (["None"]), `cris` (Low), `custom_bucket_name`, `enable_versioning` (false), `price_class` (PriceClass_100), `custom_domain_aliases`, `custom_acm_certificate_arn`, `app_path` (`/`), `cache_control`, `content_type_overrides`
- **Outputs**: `bucket_name`, `bucket_arn`, `bucket_domain_name`, `bucket_regional_domain_name`, `distribution_id`, `distribution_arn`, `distribution_domain_name`
- **Notes**: Use this for any vanilla SPA. Don't bolt together S3+CloudFront+deploy yourself.

### aws-tags
- **Purpose**: Standardized EPIC tag map (data-only module — no resources).
- **Required**: `aws_account_id` (string), `environment` (string), `appid` (**number** — `appid = 1234`, NOT `"1234"`), `notify` (**`list(string)`**), `owner` (**`list(string)` of exactly 3 LANIDs** — module validates `length == 3`)
- **Key optional**: `dataclassification` (Internal), `compliance` (**`list(string)`**, default `["None"]`), `cris` (Low), `order` (**number**, validates 7–9 digits)
- **Outputs**: `tags`
- **Notes**: Always invoke first. Every other module gets `tags = module.tags.tags`.
- **Footguns**:
  - **Pass `var.notify` and `var.owner` straight through** — never `join(...)` or index (`var.notify[0]`) when feeding the tags module. The module rejects scalar inputs.
  - **`appid` and `order` are numbers**, not strings. In `terraform.auto.tfvars` write `appid = 1234`, `order = 1234567` (no quotes).
  - Per-resource overrides go through `tags = merge(module.tags.tags, { DataClassification = "Confidential" })` — never build a parallel tags map.

---

## 9. Azure module catalog

All Azure modules live at `git::https://github.com/pgetech/epic-pipeline-module-azure-<name>.git?ref=main`.

### azure-app-service
- **Purpose**: App Service for Node/.NET/Python/Java/PHP on Linux or Windows.
- **Required**: `resource_group_name`, `azure_region`, `service_plan_name`, `app_name`
- **Key optional**: `os_type` (Linux), `runtime` (node), `runtime_version`, `sku_name` (B1), `app_settings` ({}), `key_vault_secret_refs` ({}), `tags`
- **Outputs**: `app_service_id`, `app_service_name`, `default_hostname`, `service_plan_id`, `principal_id`
- **Notes**: Python and PHP are Linux-only. Pair with `azure-key-vault` for secret refs (uses managed identity).

### azure-function
- **Purpose**: Function App (Consumption Y1, Premium EP, or Dedicated) for Node/.NET/Python.
- **Required**: `resource_group_name`, `azure_region`, `function_app_name`, `storage_account_name`, `storage_account_access_key`
- **Key optional**: `service_plan_name`, `sku_name` (Y1), `runtime` (node), `runtime_version`, `app_settings` ({}), `key_vault_secret_refs` ({}), `https_only` (true), `functions_extension_version` (~4), `tags`
- **Outputs**: `function_app_id`, `function_app_name`, `default_hostname`, `service_plan_id`, `principal_id`
- **Notes**: Linux-only. Must pair with `azure-storage` for backing storage.

### azure-key-vault
- **Purpose**: Key Vault with RBAC, soft delete, purge protection.
- **Required**: `resource_group_name`, `azure_region`, `key_vault_name`, `tags`
- **Key optional**: `sku_name` (standard), `soft_delete_retention_days` (90), `purge_protection_enabled` (true), `enable_rbac_authorization` (true), `enabled_for_deployment` (false), `enabled_for_disk_encryption` (false), `enabled_for_template_deployment` (false), `network_acls`, `secrets` ({})
- **Outputs**: `key_vault_id`, `key_vault_name`, `key_vault_uri`, `secret_uris`
- **Notes**: `secret_uris` are versionless URIs ready for App Service Key Vault references.

### azure-postgresql
- **Purpose**: PostgreSQL Flexible Server with optional VNet integration.
- **Required**: `resource_group_name`, `azure_region`, `server_name`, `tags`
- **Key optional**: `postgresql_version` (16), `sku_name` (B_Standard_B1ms), `storage_mb` (32768), `storage_tier` (P4), `backup_retention_days` (7), `geo_redundant_backup_enabled` (false), `zone`, `admin_username` (epicadmin), `admin_password`, `databases` ([]), `firewall_rules` ([]), `delegated_subnet_id`, `private_dns_zone_id`
- **Outputs**: `server_id`, `server_name`, `server_fqdn`, `admin_username`, `admin_password` (sensitive), `database_names`
- **Notes**: Admin password auto-generated (24 chars) if not supplied.

### azure-sql
- **Purpose**: Azure SQL Server + databases with Azure AD auth and firewall rules.
- **Required**: `resource_group_name`, `azure_region`, `server_name`, `tags`
- **Key optional**: `sql_version` (12.0), `admin_username` (epicadmin), `admin_password`, `minimum_tls_version` (1.2), `public_network_access_enabled` (false), `azuread_admin`, `databases` ([]), `firewall_rules` ([]), `enable_auditing` (false)
- **Outputs**: `server_id`, `server_name`, `server_fqdn`, `admin_username`, `admin_password` (sensitive), `database_ids`

### azure-storage
- **Purpose**: Storage Account with blob containers, soft delete, network ACLs.
- **Required**: `resource_group_name`, `azure_region`, `storage_account_name`, `tags`
- **Key optional**: `account_tier` (Standard), `account_replication_type` (LRS), `account_kind` (StorageV2), `min_tls_version` (TLS1_2), `allow_blob_public_access` (false), `enable_versioning` (false), `enable_blob_soft_delete` (true), `blob_soft_delete_days` (7), `enable_container_soft_delete` (true), `container_soft_delete_days` (7), `containers` ([]), `network_rules`
- **Outputs**: `storage_account_id`, `storage_account_name`, `primary_blob_endpoint`, `primary_access_key` (sensitive), `primary_connection_string` (sensitive)
- **Notes**: Names must be 3–24 chars, lowercase alphanumeric, globally unique.

### azure-tags
- **Purpose**: Standardized EPIC tag map for Azure (data-only module).
- **Required**: `subscription_id`, `environment`, `appid`, `notify`, `owner` (3), `order`
- **Key optional**: `dataclassification` (Internal), `compliance` (["None"]), `cris` (Low)
- **Outputs**: `tags`
- **Notes**: Always invoke first. Every other module gets `tags = module.tags.tags`.

---

## 10. Decision guide — which modules for which app shape

Use this as the first pass. The per-module sections above are the source of truth for
inputs/outputs.

| App shape | AWS modules | Azure modules |
|---|---|---|
| Static SPA (Angular/React/Vue) | `tags`, `static-web` *(or `s3` + `cloudfront` + `deploy-static-site` + `certificate` + `route53` if you need fine-grained control)* | `tags`, `storage` (static website), `app-service` (only if dynamic) |
| Lambda/Function backend (REST API) | `tags`, `lambda`, `api-gateway`, `dynamodb`, `cloudwatch`, `cloudwatch-alarm`, `sns`, `security-group`, `certificate` + `route53` (if custom domain) | `tags`, `function`, `storage`, `key-vault` |
| Container/EC2 web app | `tags`, `ec2`, `load-balancer`, `certificate`, `route53`, `security-group`, `cloudwatch` | `tags`, `app-service` |
| Beanstalk-deployed app | `tags`, `elastic-beanstalk`, `s3` (artifacts), `secretmanager`, `route53` | (Azure equivalent: `app-service`) |
| Relational DB-backed service | `tags`, `kms`, `aurora-postgresql`, `rds-proxy`, `secretmanager`, `lambda` or `ec2` | `tags`, `postgresql` or `sql`, `key-vault` |
| Event-driven (SQS/SNS) | `tags`, `sqs`, `sns`, `lambda`, `kms` | `tags`, `function`, `storage` (queues) |
| Audit/compliance overlay | `cloudtrail`, `cloudwatch`, `kms` | (use Azure Activity Log + diagnostic settings) |
| Config/secrets | `ssm-parameter-store` (config), `secretmanager` (secrets), `kms` | `key-vault` |
| BTP subaccount | n/a — use SAP/btp + cloudfoundry providers directly | n/a |

### Rules of thumb

- **Tagging is mandatory.** Always include `module "tags"` first; every resource gets `tags = module.tags.tags`.
- **Encryption.** If `dataclassification` is Confidential or Restricted, you must use `aws-kms` and pass the CMK to consuming modules (`s3.kms_key_arn`, `aurora.kms_key_id`, `secretmanager.kms_key_id`, etc.).
- **CloudFront + ACM** requires the `aws.us_east_1` provider alias — the cert must live in us-east-1 even when the rest of the stack is in another region. (And `aws-certificate` requires the `providers = {...}` block on every call — see §8 module entry.)
- **Aurora is almost always fronted by RDS Proxy** when consumed by Lambda — pool reuse and IAM auth.
- **Lambda log groups** should be created via `aws-cloudwatch` (with explicit retention) when you need >30 days of logs; otherwise the `aws-lambda` module's built-in log group is fine.
- **Don't reach for `aws-cloudtrail`** for general account audit — that's centrally managed. Use it only for tenant-scoped audit or narrow data-event capture.
- **Use `for_each` over a `locals` map** when you have many same-shaped resources (Lambda functions, DynamoDB tables, SSM parameters). Keeps each `.tf` file small and reduces copy-paste drift.

---

## 11. EPIC composition rules — wiring modules together

Module-by-module compliance is necessary but not sufficient. Wiring between modules is where most regressions land. The rules below apply whenever the listed services appear together in the same `.infra/`.

### 11.1 Aurora ↔ RDS Proxy ↔ Lambda

- **Lambdas connect to the proxy, never to the cluster endpoint.** Publish the proxy endpoint to SSM Parameter Store so Lambdas resolve it at cold start without coupling to Terraform output ordering.
- **The proxy authenticates to Aurora as the master user** — set `manage_master_user_password = true` on `aws-aurora-postgresql`, then pass the cluster's `master_user_secret_arn` as `secret_arns = [...]` on `aws-rds-proxy`. The proxy then accepts **IAM auth** from clients (`iam_auth = "REQUIRED"`).
- **Cluster-side IAM auth is OFF** (`iam_database_authentication_enabled = false` on the Aurora module — the default). The proxy is the auth boundary; the cluster trusts the proxy by master credential. Setting it `true` while the proxy uses master is a no-op + a Prisma noise generator.
- **`require_tls = true`** on the proxy (the module default). Don't override.
- **Per-consumer `rds-db:connect` grants live on each consumer's IAM role** — one IAM policy statement of the form: `Effect=Allow, Action=rds-db:connect, Resource=arn:aws:rds-db:${region}:${account}:dbuser:${proxy_resource_id}/${pg_role_name}`. The `proxy_resource_id` is parsed from the proxy ARN: `local.proxy_resource_id = element(split(":", module.rds_proxy.proxy_arn), 6)` (see `aws-rds-proxy` footguns).
- **Three security groups, no CIDR ingress:**
  - **Lambda SG** — egress 443 + egress to proxy SG on the DB port (5432 PG / 3306 MySQL); ingress empty.
  - **Proxy SG** — ingress on DB port from Lambda SG only; egress on DB port to Aurora SG only.
  - **Aurora SG** — ingress on DB port from Proxy SG only.

### 11.2 API Gateway ↔ Lambda

- **Use `endpoint_type = "PRIVATE"` + `vpc_endpoint_ids = [var.vpc_endpoint_id]`** when the API is internal-only. Use `REGIONAL` (or `EDGE`) only when the design explicitly requires public exposure.
- **Resource policy** on a PRIVATE API: Allow `execute-api:Invoke` from `aws:sourceVpce = ${var.vpc_endpoint_id}`, Deny everything else. The `aws-api-gateway` module emits this when given a VPCE — verify after generation.
- **Lambda invoke permissions** are direct `aws_lambda_permission` resources (one per non-stream Lambda). Drive with `for_each` over the API-fronted Lambdas:
  ```hcl
  resource "aws_lambda_permission" "api_gateway" {
    for_each      = local.api_functions
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = module.lambda[each.key].function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${module.api_gateway.execution_arn}/*"
  }
  ```
- **Authorizer wiring (when the design specifies a Lambda Authorizer):** set `enable_authorizer = true` + `authorizer_function_arn` + `authorizer_function_invoke_arn` on the api-gateway module. Don't compose `aws_api_gateway_authorizer` resources separately.
- **Custom domain + base path mapping + Route 53 alias** are companion raw resources (`aws_api_gateway_domain_name`, `aws_api_gateway_base_path_mapping`) wired to the api-gateway module's `rest_api_id` / `stage_name`.

### 11.3 SPA ↔ CloudFront ↔ S3 ↔ WAF

- The SPA bucket is **private** (Block Public Access on); CloudFront accesses it via OAC (NOT OAI, NOT website-hosting endpoint).
- **WAF posture:** if a centrally-managed WebACL ARN is supplied (e.g. by Firewall Manager), pass it as `web_acl_id` on the cloudfront module. Do NOT create your own `aws_wafv2_web_acl` or `aws_wafv2_ip_set` when a managed one exists.
- **SPA cert** is `us-east-1` ACM, validated via the public hosted zone. The certificate module call uses `providers = { aws = aws, aws.us_east_1 = aws.us_east_1 }` (mandatory — see `aws-certificate` footguns).
- **For Route 53 alias records pointing at CloudFront**, use the CloudFront-global hosted-zone ID `Z2FDTNDATAQYW2` (fixed AWS-published value) — `aws-cloudfront` does not export a `distribution_hosted_zone_id`.

### 11.4 Per-Lambda log groups + alarms

- Every Lambda gets an explicit `aws_cloudwatch_log_group` resource with:
  ```hcl
  resource "aws_cloudwatch_log_group" "lambda" {
    for_each          = local.functions
    name              = "/aws/lambda/${module.lambda[each.key].function_name}"
    retention_in_days = 90
    tags              = module.tags.tags
  }
  ```
  Lambda's auto-created log group defaults to "Never Expire", which fails SAF retention controls.
- For per-function alarms, prefer Lambda-namespace alarms with a function-dimension (`Errors`, `Throttles`, `Duration`) wired to an SNS observability-alerts topic, rather than one alarm per function manually.

### 11.5 KMS keys — one per data-classification boundary

- Typical: one CMK for the database, one for Lambda env-var encryption (Confidential-data Lambdas), one for Secrets Manager. Don't share a CMK across boundaries.
- Each CMK gets an alias of shape `alias/<app>-<env>-<purpose>` (handled automatically when you pass `purpose` to `aws-kms`).

### 11.6 Service-trust IAM roles (non-Lambda)

When the design needs an IAM role assumed by an AWS service that **isn't** Lambda — EventBridge Scheduler, ECS, Step Functions, API Gateway logs, etc. — use `aws-iam-role` with `custom_trust = true` + `trusted_principals = [{ type = "service", provider = "<service>.amazonaws.com" }]`. The field is **`provider`**, not `identifiers`. See `aws-iam-role` footguns for the principal-string lookup.

Do NOT use `role_type = "lambda"` for non-Lambda services — it hard-codes `lambda.amazonaws.com` and the service's assume-role call will be denied.

### 11.7 VPC / subnet IDs come from SSM, not tfvars

In EPIC accounts, VPCs and subnets are pre-provisioned at the account level and exposed via SSM Parameter Store under `/vpc/*`. **Resolve these at plan time via `data "aws_ssm_parameter"` blocks — do NOT declare `vpc_id` / `subnet_ids` as variables and do NOT put them in `terraform.auto.tfvars`.**

Standard SSM paths:

| SSM path | Value |
|---|---|
| `/vpc/id` | VPC ID |
| `/vpc/privatesubnet1/id` | Private subnet (AZ a) |
| `/vpc/privatesubnet2/id` | Private subnet (AZ b) |
| `/vpc/privatesubnet3/id` | Private subnet (AZ c) |
| `/vpc/privateroutetable/id` | Private route table |

Pattern:

```hcl
data "aws_ssm_parameter" "vpc_id"           { name = "/vpc/id" }
data "aws_ssm_parameter" "private_subnet_1" { name = "/vpc/privatesubnet1/id" }
data "aws_ssm_parameter" "private_subnet_2" { name = "/vpc/privatesubnet2/id" }
data "aws_ssm_parameter" "private_subnet_3" { name = "/vpc/privatesubnet3/id" }

module "lambda_security_group" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  # ...
}

module "aurora_postgresql" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  subnet_ids = [
    data.aws_ssm_parameter.private_subnet_1.value,
    data.aws_ssm_parameter.private_subnet_2.value,
    data.aws_ssm_parameter.private_subnet_3.value,
  ]
  # ...
}
```

This keeps each project's `terraform.auto.tfvars` free of VPC IDs (which can change when the account-baseline VPC is rebuilt) and means there's no input to override — the SSM path is the source of truth.

The `aws-network` module is a thin wrapper over the same `data "aws_ssm_parameter"` calls; either approach is fine. Prefer raw `data` blocks when you only need a couple of parameters; prefer the module when consuming all of them.

---

---

## 12. End-to-end example: `.infra/` skeleton for a Lambda + API Gateway + DynamoDB app on AWS

This is a structural example only — fill in real values for your project.

### `terraform.tf`
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.90" }
  }
  backend "s3" {}
}

provider "aws" { region = var.aws_region }
```

### `variables.tf`
```hcl
variable "principal_orgid"    { type = string  default = "o-7vgpdbu22o" }
variable "aws_account_id"     { type = string }
variable "aws_region"         { type = string }
variable "environment"        { type = string }
variable "project_tag"        { type = string }
variable "appid"              { type = number }
variable "notify"             { type = list(string) }
variable "owner"              { type = list(string) }
variable "order"              { type = number }
variable "dataclassification" { type = string  default = "Internal" }
variable "compliance"         { type = list(string) default = ["None"] }
variable "cris"               { type = string  default = "Low" }

variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }

variable "lambda_s3_bucket"     { type = string }
variable "lambda_s3_key_prefix" { type = string default = "" }
```

### `terraform.auto.tfvars`
```hcl
principal_orgid = "o-7vgpdbu22o"  # PG&E AWS Org ID — fixed value
aws_account_id  = "123456789012"
aws_region      = "us-west-2"
environment     = "dev"
project_tag     = "MyApp"
appid           = 1234
notify          = ["team@example.com"]
owner           = ["abc1", "def2", "ghi3"]
order           = 1234567

vpc_id     = "vpc-xxxxxxxx"
subnet_ids = ["subnet-aaaa", "subnet-bbbb", "subnet-cccc"]

lambda_s3_bucket     = "my-deploy-bucket"
lambda_s3_key_prefix = "lambdas/"
```

### `main.tf`
```hcl
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

module "lambda_security_group" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-security-group.git?ref=main"

  app_name    = var.project_tag
  environment = var.environment
  label       = "lambda-shared"
  description = "Shared egress-only SG for ${var.project_tag} Lambdas"
  vpc_id      = var.vpc_id
  tags        = module.tags.tags

  cidr_egress_rules = [{
    description      = "HTTPS egress"
    from             = 443
    to               = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }]
}
```

### `dynamodb.tf`
```hcl
locals {
  tables = {
    items  = { hash_key = "itemId" }
    audit  = { hash_key = "entityKey", range_key = "timestamp" }
  }
}

module "dynamodb" {
  source   = "git::https://github.com/pgetech/epic-pipeline-module-aws-dynamodb.git?ref=main"
  for_each = local.tables

  table_name                  = "${var.project_tag}-${title(each.key)}-${var.environment}"
  hash_key                    = each.value.hash_key
  range_key                   = try(each.value.range_key, null)
  deletion_protection_enabled = var.environment == "prod"
  tags                        = module.tags.tags
}
```

### `lambda.tf`
```hcl
locals {
  functions = {
    getItems    = { handler = "getItems/handler.handler" }
    postItem    = { handler = "postItem/handler.handler" }
    deleteItem  = { handler = "deleteItem/handler.handler" }
  }
}

module "lambda" {
  source   = "git::https://github.com/pgetech/epic-pipeline-module-aws-lambda.git?ref=main"
  for_each = local.functions

  function_name = "${var.project_tag}-${each.key}-${var.environment}"
  handler       = each.value.handler
  runtime       = "nodejs22.x"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = "${var.lambda_s3_key_prefix}${each.key}.zip"

  vpc_config = {
    subnet_ids         = var.subnet_ids
    security_group_ids = [module.lambda_security_group.aws_security_group_id]
  }

  environment_variables = {
    ENVIRONMENT  = var.environment
    ITEMS_TABLE  = module.dynamodb["items"].table_name
    AUDIT_TABLE  = module.dynamodb["audit"].table_name
  }

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:Query","dynamodb:DeleteItem"]
      Resource = [for t in module.dynamodb : t.table_arn]
    }]
  })

  tags = module.tags.tags
}
```

### `api_gateway.tf`
```hcl
module "api_gateway" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-api-gateway.git?ref=main"

  api_name      = "${var.project_tag}-Api-${var.environment}"
  description   = "${var.project_tag} REST API"
  endpoint_type = "REGIONAL"
  stage_name    = var.environment
  tags          = module.tags.tags
}

resource "aws_lambda_permission" "api_gateway" {
  for_each      = local.functions
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*"
}
```

### `outputs.tf`
```hcl
output "api_invoke_url" { value = module.api_gateway.stage_invoke_url }
output "api_id"         { value = module.api_gateway.rest_api_id }
output "table_arns"     { value = { for k, t in module.dynamodb : k => t.table_arn } }
```

---

## 13. Common pitfalls

- **Don't forget the three pipeline-injected vars.** AWS needs `aws_account_id`, `aws_region`, `environment`. Azure needs `subscription_id`, `tenant_id`, `azure_region`, `environment`. They MUST be declared in `variables.tf` even if you don't use them all directly — the pipeline passes them on every plan.
- **Don't put a `backend "s3"` block with config.** Leave it `backend "s3" {}` (or `backend "azurerm" {}`). The pipeline injects the config via `-backend-config` flags so different environments / accounts get different state keys without code changes.
- **Don't pin module refs to a branch other than `main`.** All EPIC modules use `?ref=main`.
- **Don't fork or vendor an EPIC module.** If a module is missing functionality, raise it to the EPIC platform team.
- **Don't put secrets in `terraform.auto.tfvars`.** Use `aws-secretmanager` (or BTP secrets manager flow) and reference ARNs.
- **Don't create your own tag map.** Always use the `tags` module — it ensures AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order are all present and normalized.
- **Don't `join()` or index `var.notify` / `var.owner` / `var.compliance` when feeding the tags module.** Those variables are `list(string)` — passing a scalar fails the module's validation.
- **Don't write `appid` or `order` as strings.** Both are numbers; `appid = 1234` (no quotes) in `terraform.auto.tfvars`.
- **Don't omit the `providers = { aws = aws, aws.us_east_1 = aws.us_east_1 }` block on `aws-certificate` calls.** It's required even for regional certs (API Gateway, ALB) — see the module entry for why.
- **Don't provision Aurora with `engine_mode = "serverless"`** — that's Aurora Serverless v1 (a different product). Use `engine_mode = "provisioned"` (the module default) + `serverlessv2_scaling_configuration = {...}` for v2.
- **Don't connect Lambdas to the Aurora cluster endpoint** when an RDS Proxy is in scope — connect to the proxy.
- **Don't enable cluster-side IAM auth** (`iam_database_authentication_enabled = true` on Aurora) when the proxy is the auth boundary. The proxy authenticates as master; the cluster trusts the proxy.
- **CloudFront cert must be in us-east-1.** Set up the `aws.us_east_1` provider alias.
- **CloudFront alias records use the global hosted-zone ID `Z2FDTNDATAQYW2`** — `aws-cloudfront` does not export a per-distribution hosted-zone ID.
- **Don't declare `vpc_id` / `subnet_ids` as variables in EPIC accounts** — resolve them via `data "aws_ssm_parameter"` against `/vpc/*` paths (see §11.7).
- **`appName` in `epic.json` is the canonical app slug** — it appears in the Terraform state key (`<account>/<appName>-<appType>/<env>/terraform.tfstate`), so don't change it casually after the first apply.
