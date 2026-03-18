# EPIC Pipeline (Azure DevOps)

## Overview

EPIC is an enterprise-grade Azure DevOps pipeline framework for building, testing, scanning, and deploying applications — and optionally provisioning the infrastructure they run on.

It is designed to be orchestrated by an upstream engine or IDP and executed consistently across projects using a standardized pipeline contract.

Applications define their intent in a single config file. EPIC handles execution.

---

![Workflow](CICD.png)

---

## High-Level Flow

1. Orchestrator triggers EPIC (via pipeline run or REST)
2. Infrastructure is provisioned if `/.infra` is present (independent stage)
3. Application source is downloaded
4. Build is executed based on project type
5. Tests are executed
6. Security and quality scans are performed
7. Application is deployed
8. Optional integration tests are run

---

## Repository Structure

```
EPIC-Pipeline/
├── epic-orchestrator.yml        # Primary orchestration pipeline
├── epic-engine.yml              # Engine-facing pipeline entry
├── common/
│   └── download.yml             # Shared download logic
├── infra/
│   └── main.yml                 # Infrastructure provisioning (Terraform)
├── build/
│   ├── main.yml                 # Build dispatcher
│   ├── angular/
│   ├── dotnet/
│   ├── dotnet_framework/
│   ├── java/
│   └── python/
├── test/
│   ├── main.yml                 # Test dispatcher
│   ├── jest/
│   ├── junit/
│   ├── playwright/
│   ├── pytest/
│   └── xunit/
├── scan/
│   ├── main.yml                 # Scan dispatcher
│   ├── jfrog/
│   ├── sonarqube/
│   └── wiz/
├── deploy/
│   ├── main.yml                 # Deployment dispatcher
│   ├── basic/
│   ├── dotnet/
│   ├── java/
│   └── python/
└── .gitignore
```

---

## Design Principles

- **Modular** — Everything is a template
- **Cloud-agnostic** — No hard dependency on AWS or Azure
- **Engine-driven** — Designed for orchestration, not manual runs
- **Secure by default** — Scanning and testing are first-class citizens
- **Infrastructure-aware** — Can provision and manage cloud resources directly
- **Enterprise-ready** — Predictable, repeatable, auditable

---

## Intended Usage

Applications are not expected to copy or modify this pipeline. Instead:

- Applications conform to the EPIC contract
- Orchestrators supply configuration
- EPIC executes consistently across teams

---

## Core Pipelines

### `epic-orchestrator.yml`

Designed to be invoked by an external engine via REST or pipeline-to-pipeline trigger. Typical use cases include IDP or wizard-driven deployments and dynamic execution based on JSON payloads.

### `epic-engine.yml`

The primary ADO pipeline that controls execution flow. It accepts parameters from the calling system, determines which stages are required, calls modular templates, and enforces ordering and gating. It contains no business logic — it wires stages together.

---

## Infrastructure Stage

### Overview

EPIC supports automated infrastructure provisioning via Terraform. This stage is independent — it does not block or gate the build stage, and runs as a separate concern.

When a `/.infra` folder is present in the application repository, EPIC will automatically run `terraform init`, `terraform plan`, and `terraform apply` against it. If `/.infra` is absent, the infra stage is skipped and EPIC uses the resource values provided directly in `epic.json`.

### `/.infra` Folder Structure

EPIC expects a standard Terraform layout (example shown below):

```
.infra/
├── versions.tf                 # Verions declarations
├── main.tf                     # Resource definitions
├── data.tf                     # Data declarations
├── variables.tf                # Input variable declarations
├── terraform.auto.tfvars.tf    # Input variable values
└── outputs.tf                  # Output values (used by EPIC for deployment)
```

EPIC handles backend configuration, state management, and credential injection automatically. Applications should not define backend configuration in their Terraform code.

### Behavior

| Condition | EPIC Behavior |
|-----------|---------------|
| `/.infra` present | Runs `terraform init`, `plan`, and `apply` automatically |
| `/.infra` absent | Skips infra stage; uses resource values from `epic.json` |

### Outputs

Terraform outputs defined in `outputs.tf` are captured by EPIC and made available to the deploy stage. If you are managing your own infrastructure and skipping `/.infra`, you must supply the equivalent values directly in `epic.json`.

---

## Common Components

### `common/download.yml`

Shared logic used across stages to download application source, retrieve artifacts, and normalize working directories.

---

## Build Stage

### `build/main.yml`

Dispatcher that selects the correct build implementation based on `appType`. Responsibilities include installing tooling and dependencies, running the build, and normalizing output into a `build` folder.

**Supported types:** Angular, .NET Core, .NET Framework, Python, Java

---

## Test Stage

### `test/main.yml`

Executes unit tests, generates reports, and fails the pipeline on test failure (configurable). Output is normalized into a `reports` folder.

**Supported frameworks:** Jest, Playwright, pytest, xUnit

---

## Scan Stage

### `scan/main.yml`

Security and quality scan dispatcher. Scanner selection is data-driven, not hard-coded. Enforces quality gates when configured.

**Supported scanners:** SonarQube, JFrog, Wiz

---

## Deploy Stage

### `deploy/main.yml`

Handles application deployment to the target runtime environment. No infrastructure creation occurs here — the infra stage handles that. Assumes infrastructure already exists, whether provisioned by EPIC or provided externally.

---

## Pipeline Contract

Each application must include a configuration file at:

```
.pipeline/epic.json
```

This file defines how EPIC builds, tests, scans, and deploys the application. If `/.infra` is absent, all AWS or Azure resource values must also be provided here.

---

## Example `epic.json`

```json
{
  "appName": "my-app",
  "appType": "angular",
  "codePath": "/src",

  "nodeVersion": "18",

  "scanTool": "sonarqube",
  "unitTestTool": "jest",
  "integrationTestTool": "playwright",

  "awsAccountId": "999999999999",
  "s3": "pge-epic-my-app-web-dev",
  "cloudfront": "X9X9X9XX99XX9X"
}
```

If `/.infra` is present and outputs `s3` and `cloudfront`, those values do not need to be hardcoded in `epic.json` — EPIC will resolve them from Terraform output automatically.

---

## Contract Parameters

### Application Configuration

| Parameter | Required | Description |
|-----------|----------|-------------|
| `appName` | Yes | Logical application name. Alphanumeric, hyphens, or underscores. No spaces. |
| `appType` | Yes | Determines build implementation. See allowed values below. |
| `codePath` | Yes | Relative path from repo root to application source (e.g., `/src`, `.`). |
| `buildType` | No | Defines packaging behavior. Omit for standard build. |

**`appType` allowed values:**

| Value | Description |
|-------|-------------|
| `angular` | Angular frontend application |
| `dotnet` | .NET Core / .NET 6+ application |
| `dotnet_framework` | .NET Framework application |
| `java` | Java application |
| `python` | Python application |

---

### Build Runtime Versions

| Parameter | Default | Description |
|-----------|---------|-------------|
| `dotnetVersion` | `9.x` | .NET SDK version |
| `javaVersion` | `17` | Java version |
| `nodeVersion` | `18` | Node.js version |
| `pythonVersion` | `3.11` | Python version |

---

### Tool Configuration

| Parameter | Description | Allowed Values |
|-----------|-------------|----------------|
| `scanTool` | Scan tool to execute | `sonarqube`, `jfrog`, `wiz`, omit to skip |
| `unitTestTool` | Unit test framework | `jest`, `junit`, `pytest`, `xunit`, omit to skip |
| `integrationTestTool` | Integration test framework | `playwright`, omit to skip |

---

### AWS Deployment Parameters

Required when deploying to AWS and `/.infra` is absent. If `/.infra` is present, EPIC resolves these from Terraform outputs automatically.

| Parameter | Description |
|-----------|-------------|
| `awsAccountId` | Target AWS account ID (12 digits) |
| `s3` | Target S3 bucket name |
| `cloudfront` | CloudFront distribution ID (static/Angular apps) |
| `ec2InstanceId` | EC2 instance ID (.NET, Python, Java apps) |
| `appExecutable` | Executable name (.NET, Python, Java apps) |

---

### Azure Deployment Parameters

| Parameter | Description |
|-----------|-------------|
| `azureSubscription` | Azure subscription name or service connection reference |
| `azureResourceGroup` | Azure resource group for deployment |

---

## Parameter Categories Summary

| Category | Required | Parameters |
|----------|----------|------------|
| Application Identity | Yes | `appName`, `appType`, `codePath` |
| Packaging | Optional | `buildType` |
| Runtime Versions | Optional | `nodeVersion`, `pythonVersion`, `dotnetVersion`, `javaVersion` |
| Scanning | Optional | `scanTool` |
| Unit Testing | Optional | `unitTestTool` |
| Integration Testing | Optional | `integrationTestTool` |
| AWS Deployment | Conditional | `awsAccountId`, `s3`, `cloudfront`, `ec2InstanceId`, `appExecutable` |
| Azure Deployment | Conditional | `azureSubscription`, `azureResourceGroup` |

---

## Validation Rules

EPIC enforces validation at runtime:

- Missing required fields fail early
- Unsupported values fail during stage dispatch
- Version fields default if omitted
- Deployment parameters are validated only when the deploy stage executes
- If `/.infra` is present, Terraform outputs are validated before the deploy stage runs

---

## Contract Philosophy

The EPIC contract is declarative, modular, cloud-agnostic, engine-driven, and version-controllable.

Applications define intent. EPIC determines execution flow.

---

## Extending EPIC

To add support for a new build, scan, test, or infrastructure type:

1. Add a new folder under the appropriate stage
2. Implement the script or template
3. Register it in the stage dispatcher (`main.yml`)

No changes to the orchestrator are required.

---

## Summary

EPIC provides a standardized CI/CD backbone for enterprise application delivery.

It separates:

- Infrastructure provisioning (`/.infra` + Terraform)
- Application lifecycle (build, test, scan, deploy)
- Orchestration logic (engine + orchestrator)

This keeps pipelines clean, scalable, and governable across teams.