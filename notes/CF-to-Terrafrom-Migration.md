# CloudFormation to Terraform Migration — Process and Proof of Concept

## Executive Summary

This document outlines an end-to-end process for discovering, analyzing, and converting CloudFormation infrastructure across PG&E's GitHub organization (`pgetech`) to Terraform, using PG&E's existing Terraform module library as the target standard.

The process was built and validated using automated bash scripts for discovery and analysis, and Claude Code for the actual conversion work. A proof-of-concept conversion was completed against the `aws-oih-fis` repository.

### Key Findings

| Metric | Value |
|--------|-------|
| Total active repos scanned | 3,817 |
| Repos containing CloudFormation | 436 |
| Total CloudFormation template files | 2,182 |
| Total AWS resource declarations | 17,404 |
| Total lines of CloudFormation code | 902,241 |
| Repos using AWS SAM | 113 |
| Repos with existing Terraform | 24 |
| Repos with cross-stack references | 55 |
| Repos with custom resources | 87 |
| Unique AWS account IDs found | 92 |

---

## The Problem

PG&E has hundreds of repositories in the `pgetech` GitHub organization that use AWS CloudFormation for infrastructure provisioning. There is no centralized inventory of what CloudFormation exists, what AWS resources it manages, or how complex each stack is. Meanwhile, PG&E has invested in a standardized Terraform module library (`pge-terraform-modules`) published to the Terraform Cloud registry at `app.terraform.io/pgetech`, with modules covering 110+ AWS services, mandatory PG&E tagging, and built-in compliance validation.

The goal is to migrate CloudFormation infrastructure to Terraform using PG&E's existing modules, bringing all infrastructure under a single, governed standard.

---

## The Solution — Three-Stage Pipeline

A fully automated, repeatable pipeline was built to handle discovery and analysis at organization scale. The CloudFormation-to-Terraform conversion is then performed by Claude Code using the pipeline's output data and PG&E's Terraform module examples as the conversion standard.

```
Stage 1          Stage 2            Stage 3
search.sh   -->  analyze.sh   -->  Claude Code
(discover)       (classify)        (convert)
```

Stages 1 and 2 are idempotent — safe to re-run at any time without duplicating work. Completed repos are automatically skipped.

---

## Stage 1 — Discovery (`search.sh`)

### What It Does

Scans every non-archived repository in the `pgetech` GitHub organization and identifies which ones contain CloudFormation templates.

### How It Works

1. Fetches the full list of non-archived repos via `gh repo list` (3,817 repos)
2. Shallow-clones each repo
3. Searches for `AWSTemplateFormatVersion` in YAML, JSON, and `.template` files
4. Excludes dependency directories (`node_modules/`, `vendor/`, `.terraform/`)
5. Records matches to `cfn-repos.txt`
6. Tracks progress for resume on interruption

### Output

`cfn-repos.txt` — 436 repositories containing CloudFormation:

```
agentcore_strands
aws-oih-fis
Meteorology-Model-Integration
eweb-auth-lambda
meteorology-alpha
meteorology-operations
...
```

### Result

**436 out of 3,817 repos (11.4%) contain CloudFormation.**

---

## Stage 2 — Analysis (`analyze.sh`)

### What It Does

For each of the 436 CloudFormation repos, produces two CSV files — one for repository metadata and category classification, one for migration complexity signals.

### How It Works

1. Fetches repo metadata via the GitHub API (created date, last push, default branch)
2. Clones and locates all CloudFormation templates
3. Classifies AWS resource types into categories using weighted signal detection
4. Extracts migration complexity signals from the templates
5. Checks for existing Terraform (`.tf` files) in the repo
6. Identifies AWS account IDs from ARN patterns
7. Extracts application identifiers from CFN tags and `APP-nnnn` patterns

### Output 1 — `cfn-repo-analysis.csv` (What Exists)

```
repo_name,created_at,last_pushed_at,default_branch,cfn_file_count,
platform_pct,application_pct,data_pct,other_pct
```

Categorizes each repo's infrastructure intent:

| Category | Strong Signals (4x weight) | Supporting Signals (1x weight) |
|----------|---------------------------|-------------------------------|
| Platform | CodePipeline, CodeBuild, CodeDeploy, StackSets | IAM, SSM, Logs, S3 |
| Application | ECS, EKS, Lambda, ALB, API Gateway | — |
| Data | RDS, DynamoDB, Glue, Redshift, Kinesis, Athena | — |

**Portfolio breakdown (repos where category exceeds 50%):**

| Category | Repos |
|----------|-------|
| Platform-dominant | 295 |
| Application-dominant | 90 |
| Data-dominant | 13 |

### Output 2 — `cfn-migration-complexity.csv` (How Hard to Convert)

```
repo_name,total_resources,resource_types,nested_stacks,cross_stack_refs,
custom_resources,sam_transforms,parameters,conditions,has_terraform,
cfn_lines,aws_account_ids,app_ids
```

Each column answers a specific migration planning question:

| Column | Migration Question It Answers |
|--------|-------------------------------|
| `total_resources` | How big is this conversion? |
| `resource_types` | Which Terraform provider resources are needed? |
| `nested_stacks` | Does this need Terraform module decomposition? |
| `cross_stack_refs` | Are there inter-stack dependencies requiring `terraform_remote_state`? |
| `custom_resources` | Are there Lambda-backed custom resources with no Terraform equivalent? |
| `sam_transforms` | Does SAM shorthand expand to multiple real resources? |
| `parameters` / `conditions` | How parameterized and conditional is the logic? |
| `has_terraform` | Is there a partial migration already in progress? |
| `cfn_lines` | Raw size of the conversion effort |
| `aws_account_ids` | Which AWS accounts does this touch? |
| `app_ids` | Which PG&E applications own this infrastructure? |

### Combined Report

Both CSVs are joined into `cfn-combined-report.csv` (and `.xlsx`) sorted by most recently pushed, giving a single prioritized view of the entire CloudFormation portfolio.

**Sample rows (key columns):**

| Repository | Last Pushed | CFN Files | Resources | Nested Stacks | Cross-Stack Refs | SAM | Has TF | CFN Lines |
|---|---|---|---|---|---|---|---|---|
| agentcore_strands | 03/26/2026 | 2 | 21 | 0 | 0 | true | false | 425 |
| aws-oih-fis | 03/26/2026 | 2 | 27 | 0 | 0 | false | false | 1,113 |
| Meteorology-Model-Integration | 03/26/2026 | 14 | 441 | 0 | 0 | true | false | 12,488 |
| meteorology-operations | 03/26/2026 | 28 | 947 | 0 | 1 | true | false | 28,575 |

### Largest Repos by Resource Count

| Repository | Resources | CFN Lines | CFN Files |
|---|---|---|---|
| cscoe-config-rules | 2,152 | 74,789 | 134 |
| meteorology-serverless-api | 952 | 26,528 | 7 |
| meteorology-operations | 947 | 28,575 | 28 |
| pge-ecm-crm-eks-cicd | 565 | — | — |
| Meteorology-Model-Integration | 441 | 12,488 | 14 |

### Migration Complexity Summary

| Signal | Count | Impact |
|--------|-------|--------|
| Repos using SAM | 113 | Each SAM resource expands to multiple Terraform resources |
| Repos with cross-stack references | 55 | Require state dependency planning |
| Repos with custom resources | 87 | No direct Terraform equivalent — need rewrite |
| Repos with nested stacks | 8 | Each nested stack becomes a Terraform module |
| Repos with existing Terraform | 24 | Partial migration or hybrid state to reconcile |

---

## Stage 3 — Conversion with Claude Code

### What It Does

Converts a repository's CloudFormation templates into a Terraform project that follows PG&E's standards, using the analysis data from Stage 2 and PG&E's Terraform module examples as the target.

### How It Works

Claude Code is provided three inputs for each conversion:

1. **The CloudFormation templates** — the source code to convert
2. **The complexity data from Stage 2** — tells Claude Code what resource types are involved, what to watch out for (nested stacks, cross-stack refs, custom resources, SAM), and context like AWS account IDs
3. **PG&E Terraform module examples** (`pge-terraform-modules/aws/modules/*/examples/`) — the target standard showing how PG&E wants Terraform structured, which modules to use, mandatory tagging, variable patterns, and file layout

Claude Code then:

1. Identifies which PG&E modules to use for each CFN resource type
2. Reads the module interfaces (`variables.tf`, `main.tf`) to understand input/output contracts
3. Creates the `.infra/` project following the PG&E example file layout
4. Maps every CFN resource to its Terraform equivalent
5. Carries over all parameter defaults to `terraform.auto.tfvars`
6. Extracts inline code (e.g., Lambda functions) to standalone files
7. Applies PG&E mandatory tagging to every resource

### Output

A complete Terraform project in `.infra/` ready for `terraform init`, `plan`, and `apply`.

---

## Proof of Concept — Converting `aws-oih-fis`

### Why This Repo

`aws-oih-fis` is an AWS Fault Injection Simulator project for SQL Server HA/DR chaos engineering testing. It was selected because it:

- Has a manageable scope (2 CFN templates, 27 resources, 1,113 lines)
- Uses multiple AWS service types (EC2, FIS, IAM, S3, Lambda, CloudWatch, SSM)
- Has no SAM, no nested stacks, and no cross-stack references
- Represents a clean, self-contained conversion target

### Conversion Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| CloudFormation templates | `cfn/FIS_plumbing.yaml`, `cfn/FIS_test_harness.yaml` | Source of truth — what to convert |
| Complexity data | `cfn-combined-report.csv` row for `aws-oih-fis` | 27 resources, 14 unique types, no nested stacks/cross-stack refs/custom resources |
| PG&E module examples | `pge-terraform-modules/aws/modules/*/examples/` | Target standard — TFC Registry modules, mandatory tagging, file layout |

### Conversion Output

```
aws-oih-fis/.infra/
├── terraform.tf                        # Provider config (AWS with assume_role)
├── variables.tf                        # PG&E required tags + project variables
├── main.tf                             # All resources and module calls
├── outputs.tf                          # All outputs
├── terraform.auto.tfvars               # Values from original CFN defaults
└── templates/
    ├── fis_s3_bucket_policy.json       # S3 bucket policy for FIS log delivery
    ├── vpc_lambda.py                   # Test harness VPC Lambda source
    └── regional_lambda.py              # Test harness Regional Lambda source
```

### Resource Mapping

**From `cfn/FIS_plumbing.yaml` (core infrastructure):**

| CloudFormation Resource | Terraform | PG&E Module |
|---|---|---|
| 3 SSM Parameters | `aws_ssm_parameter` | Native resource |
| S3 Bucket (versioning, encryption, lifecycle, policy) | `module.fis_logs_bucket` | `pgetech/s3/aws` |
| CloudWatch Log Group (30-day retention) | `aws_cloudwatch_log_group` | Native resource |
| IAM Role + Managed Policy (8 statements) | Auto-created by FIS module | `pgetech/iam/aws` via FIS |
| 7 FIS Experiment Templates | 7 `module.fis_*` calls | `pgetech/fis/aws` |

**From `cfn/FIS_test_harness.yaml` (validation infrastructure):**

| CloudFormation Resource | Terraform | PG&E Module |
|---|---|---|
| Security Group (HTTPS + ICMP) | `module.test_harness_sg` | `pgetech/security-group/aws` |
| Lambda IAM Role | `module.test_lambda_role` | `pgetech/iam/aws` |
| VPC Lambda (Python 3.11, VPC-attached) | `module.test_vpc_lambda` | `pgetech/lambda/aws` |
| Regional Lambda (Python 3.11, no VPC) | `module.test_regional_lambda` | `pgetech/lambda/aws` |
| 2 CloudWatch Log Groups (7-day retention) | `aws_cloudwatch_log_group` | Native resource |
| EC2 IAM Role + Instance Profile | `module.test_ec2_role` | `pgetech/iam/aws` |
| EC2 Instance (t3.micro, user data) | `module.test_ec2` | `pgetech/ec2/aws` |

### What the Output Looks Like

**PG&E tagging (applied to every resource):**

```hcl
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}
```

**FIS experiment template (using PG&E FIS module):**

```hcl
module "fis_primary_ec2_stop" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Primary-EC2-Stop"
  description         = "Stop Primary SQL Server instances and auto-restart after 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-EC2-Stop" })
  fis_role_name       = ""

  target = [{
    name           = "primaryDBInstances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISDBRole", value = "Primary" }
    ]
    filter = [{ path = "State.Name", values = ["running"] }]
  }]

  action = [{
    name        = "stopInstances"
    action_id   = "aws:ec2:stop-instances"
    description = "Stop primary SQL Server instances with auto-restart"
    parameter   = { startInstancesAfterDuration = "PT5M" }
    target      = [{ key = "Instances", value = "primaryDBInstances" }]
  }]

  log_type       = "s3"
  s3_bucket_name = module.fis_logs_bucket.id
  s3_logging     = { prefix = "experiments/primary-ec2-stop" }
  # ...
}
```

**Variable values carried from CFN defaults:**

```hcl
# terraform.auto.tfvars
account_num = "302263046280"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
AppID       = 3554
Environment = "Dev"
s3_bucket_name = "oih-dev-fis-logs"
primary_az     = "us-west-2b"
secondary_az   = "us-west-2a"
tertiary_az    = "us-west-2c"
```

---

## Proposed Workflow for Full Migration

Based on the proof of concept, the recommended workflow for converting each repository is:

### Step 1 — Prioritize Using the Combined Report

Use `cfn-combined-report.xlsx` to sort and filter repos. Suggested prioritization:

| Priority | Criteria | Rationale |
|----------|----------|-----------|
| High | Recently pushed + low complexity | Quick wins, active projects benefit immediately |
| Medium | High resource count but no cross-stack refs or custom resources | Bigger effort but straightforward mapping |
| Low | Cross-stack refs + custom resources + SAM | Requires architectural decisions beyond 1:1 mapping |
| Skip | Repos with `has_terraform = true` | Already partially migrated — assess manually |

### Step 2 — Convert with Claude Code (Stage 3)

Provide Claude Code the three inputs described in Stage 3:

1. The repo's CloudFormation templates
2. The complexity row from the CSV (`resource_types` column tells you which PG&E modules to reference)
3. The PG&E module examples for the relevant resource types

Claude Code creates a complete `.infra/` Terraform project following PG&E standards.

### Step 3 — Validate and Deploy

```bash
cd .infra
terraform init      # Download PG&E modules from TFC Registry
terraform validate  # Syntax and type checking
terraform plan      # Review what will be created
terraform apply     # Deploy
```

---

## Tools and Dependencies

| Tool | Purpose |
|------|---------|
| `gh` (GitHub CLI) | Repo discovery and metadata fetching |
| `rg` (ripgrep) | Fast content search across cloned repos |
| `jq` | JSON parsing for GitHub API responses |
| Claude Code | CloudFormation-to-Terraform conversion using PG&E module standards |
| Terraform >= 1.1.0 | Validation and deployment of converted code |

---

## File Inventory

```
ccoe-cfn-terraform-migration/
├── search.sh                       # Stage 1: Discover CFN repos
├── analyze.sh                      # Stage 2: Classify and extract complexity signals
├── repos.txt                       # All 3,817 non-archived repos (generated)
├── cfn-repos.txt                   # 436 repos with CloudFormation (generated)
├── cfn-repo-analysis.csv           # Analysis: metadata + categories (generated)
├── cfn-migration-complexity.csv    # Complexity: migration signals (generated)
├── cfn-combined-report.csv         # Joined + sorted report (generated)
└── cfn-combined-report.xlsx        # Excel version with formatting (generated)
```

---

## Conclusion

This process provides:

1. **Complete visibility** into PG&E's CloudFormation footprint — 436 repos, 17,404 resources, 902K lines of code across 92 AWS accounts
2. **Data-driven prioritization** — repos ranked by recency, complexity, and migration risk factors
3. **Standardized conversion** — every output uses PG&E's TFC Registry modules, mandatory tagging, and approved patterns
4. **Repeatable and scalable** — the discovery and analysis pipeline runs unattended; the conversion step uses Claude Code with consistent inputs producing consistent outputs
5. **Proven** — the `aws-oih-fis` proof of concept converted 2 CFN templates (27 resources) into a complete Terraform project using 7 PG&E modules in a single session
