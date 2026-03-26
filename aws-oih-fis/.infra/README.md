# AWS OIH-FIS — Terraform Infrastructure

This directory contains the Terraform conversion of the CloudFormation templates in `cfn/`. The original two CFN stacks have been consolidated into a single Terraform project using PG&E's standard module library from the TFC Registry (`app.terraform.io/pgetech`).

---

## What Was Converted

### Source: `cfn/FIS_plumbing.yaml`

The core FIS chaos engineering infrastructure for SQL Server HA/DR testing.

| CloudFormation Resource | Terraform Resource | PG&E Module |
|---|---|---|
| 3 SSM Parameters (`/fis/oih/primary-az`, `secondary-az`, `tertiary-az`) | `aws_ssm_parameter` | Native resource (no module needed) |
| S3 Bucket (`oih-dev-fis-logs`) with versioning, encryption, lifecycle, bucket policy | `module.fis_logs_bucket` | `pgetech/s3/aws` v0.1.0 |
| CloudWatch Log Group (`/aws/fis/experiments`, 30-day retention) | `aws_cloudwatch_log_group.fis_experiments` | Native resource |
| IAM Role (`FISExperimentRole`) + Managed Policy (8 permission statements) | Auto-created by first FIS module call | `pgetech/iam/aws` v0.1.1 (via FIS module) |
| 7 FIS Experiment Templates | 7 `module.fis_*` calls | `pgetech/fis/aws` |

### Source: `cfn/FIS_test_harness.yaml`

Temporary validation infrastructure deployed into an isolated AZ-D subnet to verify FIS network disruption isolation.

| CloudFormation Resource | Terraform Resource | PG&E Module |
|---|---|---|
| Security Group (HTTPS + ICMP ingress, all egress) | `module.test_harness_sg` | `pgetech/security-group/aws` v0.1.2 |
| Lambda IAM Role (VPCAccessExecutionRole + CloudWatch logs) | `module.test_lambda_role` | `pgetech/iam/aws` v0.1.1 |
| VPC Lambda (`FIS-Test-VPC-Lambda`, Python 3.11, VPC-attached) | `module.test_vpc_lambda` | `pgetech/lambda/aws` |
| Regional Lambda (`FIS-Test-Regional-Lambda`, Python 3.11, no VPC) | `module.test_regional_lambda` | `pgetech/lambda/aws` |
| 2 CloudWatch Log Groups (7-day retention) | `aws_cloudwatch_log_group` | Native resource |
| EC2 IAM Role + Instance Profile (SSMManagedInstanceCore) | `module.test_ec2_role` | `pgetech/iam/aws` v0.1.1 |
| EC2 Instance (t3.micro, Amazon Linux 2, httpd user data) | `module.test_ec2` | `pgetech/ec2/aws` |

---

## FIS Experiment Templates

Seven experiments covering three failure scenarios for SQL Server HA/DR validation:

| Experiment | Type | Target | Duration |
|---|---|---|---|
| `OIH-Primary-EC2-Stop` | EC2 Stop | Primary SQL Server instances (`FISDBRole=Primary`) | 5 min auto-restart |
| `OIH-Secondary-EC2-Stop` | EC2 Stop | Secondary SQL Server instances (`FISDBRole=Secondary`) | 5 min auto-restart |
| `OIH-Primary-EBS-IO-Pause` | EBS I/O Pause | EBS volumes on Primary instances | 5 min |
| `OIH-Secondary-EBS-IO-Pause` | EBS I/O Pause | EBS volumes on Secondary instances | 5 min |
| `OIH-Subnet-Disrupt-Primary-AZ` | Network Disruption | Subnets in Primary AZ (`FISAZRole=Primary`) | 5 min |
| `OIH-Subnet-Disrupt-Secondary-AZ` | Network Disruption | Subnets in Secondary AZ (`FISAZRole=Secondary`) | 5 min |
| `OIH-Subnet-Disrupt-Tertiary-AZ` | Network Disruption | Subnets in Tertiary AZ (`FISAZRole=Tertiary`) | 5 min |

All experiments target resources by tag (`FISTarget=True`) and log to S3 (`oih-dev-fis-logs/experiments/<experiment-name>`).

A single shared IAM role is created by the first experiment module call and referenced by the remaining six.

---

## File Layout

```
.infra/
├── terraform.tf              # Provider config (AWS with assume_role)
├── variables.tf              # PG&E required tags + FIS + test harness variables
├── main.tf                   # All resources and module calls
├── outputs.tf                # SSM params, IAM, logging, experiment IDs, test harness
├── terraform.auto.tfvars     # Example values (from original CFN defaults)
└── templates/
    ├── fis_s3_bucket_policy.json   # S3 bucket policy for FIS log delivery
    ├── vpc_lambda.py               # Test harness: VPC-attached Lambda source
    └── regional_lambda.py          # Test harness: Regional Lambda source
```

---

## Prerequisites

- Terraform >= 1.1.0
- AWS provider >= 5.0
- Authenticated to Terraform Cloud (`app.terraform.io/pgetech`) for module access
- AWS credentials with permissions to assume the deployment role

---

## Usage

```bash
cd .infra
terraform init
terraform plan
terraform apply
```

---

## Configuration

All values in `terraform.auto.tfvars` were extracted from the original CFN parameter defaults:

| Variable | Default | Source |
|---|---|---|
| `account_num` | `302263046280` | CFN `test-subnet-disruption.yaml` |
| `aws_region` | `us-west-2` | CFN parameter defaults |
| `AppID` | `3554` | CFN `AppID` parameter |
| `Environment` | `Dev` | CFN `Environment` parameter |
| `s3_bucket_name` | `oih-dev-fis-logs` | CFN `S3BucketName` parameter |
| `primary_az` | `us-west-2b` | CFN `PrimaryAZ` parameter |
| `secondary_az` | `us-west-2a` | CFN `SecondaryAZ` parameter |
| `tertiary_az` | `us-west-2c` | CFN `TertiaryAZ` parameter |
| `vpc_id` | `REPLACE_ME` | Environment-specific (not in CFN defaults) |
| `test_subnet_id` | `REPLACE_ME` | Environment-specific (not in CFN defaults) |
| `test_subnet_cidr` | `100.64.0.0/24` | CFN `TestSubnetCIDR` parameter |

---

## What Was NOT Converted

The following items from the original repo are **not** part of this Terraform project:

| Item | Reason |
|---|---|
| `fis-templates/*.yaml` / `*.json` | Standalone FIS experiment definition files used for manual CLI execution — not CFN resources. The equivalent experiments are created as Terraform-managed `aws_fis_experiment_template` resources via the PG&E FIS module. |
| `ssm-documents/discover-sql-dag-primary.yaml` | SSM Command Document (PowerShell) for discovering SQL Server DAG primaries. This is an operational runbook, not infrastructure. It can be managed separately or added as an `aws_ssm_document` resource if desired. |
| `scripts/`, `docs/`, `powershell/` | Operational scripts and documentation — not infrastructure. |

---

## Design Decisions

**Single project, not two.** The original CFN had two separate stacks (`FIS_plumbing` and `FIS_test_harness`). They are combined here because they share the same tags, account, and region. The test harness section is clearly separated in `main.tf` with a banner comment.

**Shared IAM role.** The first FIS module call (`fis_primary_ec2_stop`) creates the IAM role with `fis_role_name = ""`. All other experiments reference that role by its auto-generated name (`fis-role-OIH-Primary-EC2-Stop`). This matches the original CFN pattern of a single shared `FISExperimentRole`.

**S3 bucket policy as template.** The FIS log delivery bucket policy is stored in `templates/fis_s3_bucket_policy.json` and injected via `templatefile()`, matching the PG&E S3 module's `policy` parameter pattern.

**Lambda source as files.** The original CFN embedded Python code inline in the template. The Terraform version stores the Lambda source in `templates/*.py` and reads it with `file()`, keeping the infrastructure code and application code separate.

**PG&E tagging.** All resources use the `pgetech/tags/aws` module with the mandatory tag set (AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order). Tag values were carried over from the original CFN parameter defaults.
