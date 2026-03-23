# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a multi-project workspace for PG&E's **EPIC** (Enterprise Pipeline for Integration and Continuous delivery) platform. It contains the CI/CD framework, its supporting infrastructure, and the applications it deploys.

### Projects

| Project | Purpose | Stack |
|---------|---------|-------|
| **EPIC-Pipeline** | Azure DevOps CI/CD framework — template-based, data-driven pipeline engine | ADO YAML templates, AWS CLI, Terraform |
| **epic-pipeline-modules** | Reusable Terraform modules for AWS/Azure infrastructure | Terraform (HCL) |
| **epic-web** | Angular frontend for EPIC — app management, pipeline tracking, onboarding | Angular 20, TypeScript, SCSS |
| **paige-api** | Backend API for PAIGE (AI governance platform) — chat, repo analysis, CfnConvertor | .NET 10, C# 12, ASP.NET Core |
| **paige-web** | Angular frontend for PAIGE — chat UI, repo analysis, IaC conversion | Angular 20, TypeScript, SCSS, Jest |
| **paige-mcp** | Terraform knowledge base builder for PAIGE AI context | Python 3.11, FastAPI, MCP |
| **gis-enterprise-ami** | GIS Enterprise AMI factory — Image Builder, SSM automation, Terraform | Terraform, SSM, EC2 Image Builder |
| **EPIC AWS Resources** | Shared AWS infra (deployment role, Terraform state bucket) | Terraform |
| **pge-python-example** | Example Python app for EPIC onboarding | Python 3.11, pytest |
| **pge-website-example** | Example static HTML site for EPIC onboarding | HTML/CSS |

## Build & Test Commands

### epic-web
```bash
cd epic-web
npm install
npm start          # dev server
npm run build      # production build → dist/epic-web/browser/
npm test           # Karma + Jasmine
```

### paige-web
```bash
cd paige-web
npm install
./scripts/web.sh        # dev server
npm run build            # production build
./scripts/test.sh        # Jest tests
npm run test:coverage    # Jest with coverage
```

### paige-api
```bash
cd paige-api
dotnet build
dotnet test              # xUnit
dotnet publish           # self-contained executable
```

### paige-mcp
```bash
cd paige-mcp
pip install -e .
python -m terraform_kb build              # build knowledge base
python -m terraform_kb stats              # view KB stats
python -m pytest tests/                   # run tests
```

### pge-python-example
```bash
cd pge-python-example
pip install -e .
python -m pytest tests/
python -m build          # build wheel
```

### Terraform modules (epic-pipeline-modules, .infra/ folders)
```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Architecture

### EPIC-Pipeline Engine

The pipeline is a dispatcher-based ADO YAML framework. Applications declare intent in `.pipeline/epic.json`; EPIC routes to the correct templates:

```
epic-orchestrator.yml   ← REST entry point (reads epic.json, invokes engine)
epic-engine.yml         ← Control plane (conditional stages, dependency ordering)
build/main.yml          ← Dispatcher → build/{appType}/main.yml
test/main.yml           ← Dispatcher → test/{unitTestTool}/main.yml
scan/main.yml           ← Dispatcher → scan/{scanTool}/*
infra/main.yml          ← Terraform lifecycle (init/plan/apply/destroy)
deploy/main.yml         ← Dispatcher → deploy/{appType}/main.yml
```

**Stage execution:** Download → Build → UnitTest → Scan → DeployInfra → Deploy → IntegrationTest (each conditional on epic.json settings).

**Supported appTypes:** `angular`, `html`, `python`, `java`, `dotnet`, `dotnet_framework`, `ami` (in progress).

**Key artifacts:** `epic-app` (source), `epic-build` (build output), `epic-unit-tests`, `terraform-outputs`.

### EPIC Pipeline Contract

Every application provides `.pipeline/epic.json` with two sections — `app` (identity, build config, tooling) and `cloud` (deployment targets):
```json
{
  "app": {
    "appName": "my-app",
    "appType": "angular|dotnet|python|java|html|ami",
    "codePath": ".",
    "scanTool": "sonarqube",
    "unitTestTool": "jest|pytest|junit|xunit"
  },
  "cloud": {
    "awsAccountId": "514712703977",
    "awsRegion": "us-west-2"
  }
}
```

The orchestrator reads `app` fields and passes them as engine template parameters. Cloud fields are read at runtime by infra and deploy stages directly from the file in the `epic-app` artifact.

### AWS Credential Pattern

All AWS operations follow: ADO service connection → `sts assume-role` into `pge-epic-deployment-role` → export temp creds. This pattern appears in every `AWSShellScript@1` task.

### Terraform State

Remote backend: `s3://pge-epic-terraform-state` with DynamoDB locking and KMS encryption. State key pattern: `{awsAccountId}/{appName}-{appType}/{environment}/terraform.tfstate`.

### Terraform Module Convention

All projects with infrastructure use `.infra/` containing: `terraform.tf` (backend config), `main.tf`, `variables.tf`, `outputs.tf`, `terraform.auto.tfvars`. Modules come from `epic-pipeline-modules`.

### PAIGE Stack

`paige-api` (.NET) + `paige-web` (Angular) + `paige-mcp` (Python) form the AI governance platform. The API orchestrates LLM calls via a PortKey abstraction, injects context packs, and streams responses via SSE. The MCP server provides Terraform module knowledge for IaC conversion.

### GIS Enterprise AMI

`gis-enterprise-ami` manages ArcGIS component AMIs (Server, Portal, DataStore, WebAdaptor) plus FME Flow/Form. Currently uses AWS CodePipeline + Step Functions + Lambda — being migrated to EPIC-Pipeline's new `ami` appType. EPIC will trigger EC2 Image Builder, poll for completion, write AMI IDs to SSM, and run SSM config/test documents.

## ADO Template Conventions

- **Dispatchers** route via compile-time conditionals: `${{ if eq(parameters.appType, 'ami') }}`
- **Build output** always goes to `.build/` directory — `build/main.yml` validates and publishes as `epic-build`
- **Agent pools:** `ubuntu-latest` (default), `windows-latest` (.NET Framework), `EPIC - Self-hosted` (.NET + SonarQube)
- **Variable group:** `GV-account-access` (contains `GITHUB_PAT`, AWS service connection)

## Existing Sub-Project CLAUDE.md Files

- `EPIC-Pipeline/CLAUDE.md` — detailed AMI appType architecture, build/deploy flows, config format
- `epic-web/CLAUDE.md` — Angular 20 patterns, mock data layer, UI features, component state
