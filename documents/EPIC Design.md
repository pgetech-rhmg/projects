# EPIC — Technical Architecture

*A walkthrough of the EPIC (Enterprise Pipeline for Infrastructure & Cloud) platform, following the architecture flow: User Experience → Source of Truth → CI/CD Control Plane → Multi-Cloud Workloads, with Centralized Quality & Security underpinning every run.*

![EPIC Technical Architecture](EPIC%20Technical%20Architecture.png)

## Overview

EPIC is an internal developer platform (IDP) that gives every application team a single, standardized CI/CD pipeline. Teams do not build, maintain, or debug their own pipelines. They publish a contract file — `.pipeline/epic.json` — that declares *what* to build and *where* to deploy, and EPIC owns everything else: build, test, scan, infrastructure provisioning, approval, deploy, and integration testing across AWS, Azure, and SAP BTP.

The architecture diagram reads left-to-right as a flow, with a cross-cutting band along the bottom:

1. **EPIC Interface (UX)** — the developer-facing surface, hosted in AWS account `514712703977`.
2. **Source of Truth (GitHub)** — the contract and the pipeline code itself.
3. **CI/CD Control Plane (Azure DevOps)** — the orchestrator, engine, agent pools, and stage flow.
4. **Multi-Cloud Workloads** — the AWS, Azure, and BTP targets where applications actually run.
5. **Centralized Quality & Security** — scanning, approval, tagging, and observability that every run passes through.

The five colored chips along the very bottom — **Network & Perimeter**, **Identity & Access**, **Secrets & Encryption**, **Code & Supply Chain**, and **Governance & Audit** — are the security domains that each component in the diagram is mapped against.

---

## 1. EPIC Interface (UX) — AWS account 514712703977 / us-west-2

This is the layer developers and operators actually touch. It lives in a single AWS account and is composed of four building blocks plus its supporting network.

### epic-web — Angular 20 SPA
The dashboard for managing applications and pipeline runs.

- **Hosting:** static hosting on **S3 + CloudFront** (no server).
- **DNS:** `epic{-env}.ncnprod.pge.com` (Route 53 private alias to CloudFront).
- **TLS:** public ACM certificate, `us-east-1`.
- **WAF:** v2 (CLOUDFRONT scope, `us-east-1`) — IP allow-list plus PG&E public-egress CIDRs only.
- **Identity:** today the SPA sends an `X-Epic-User` header as a placeholder until MSAL/JWT auth is wired in.

### epic-api — .NET 10 REST API
The brains of the UX layer; it reconciles GitHub and Azure DevOps state and serves it to the SPA.

- **Runtime:** EC2, deployed behind an internal ALB, listening on `:5000`.
- **ALB:** internal ALB with a `/health` health check.
- **DNS:** `epic-api{-env}.ncnprod.pge.com` (Route 53 private).
- **Ingress:** SG-WEB → `5000`, plus PG&E corp CIDRs; the SG-API ingress on `5000` comes from SG-WEB.

### Aurora PostgreSQL Serverless v2
The API's datastore.

- Engine **16.11**, serverless, `storage_encrypted = true`.
- `manage_master_user_password = true` (master secret held in Secrets Manager).
- Tables: `apps`, `pipeline_runs`, `user_apps`.
- **EF Core auto-migrates on startup**, connecting on `5432` from SG-API.

### AWS Secrets Manager
The secret store for the UX layer.

- Holds application settings: `GITHUB_BASE_URL`, `GITHUB_TOKEN`, `ADO_PAT`.
- Auto-merged from the Aurora cluster: `AWS_RDS_SECRET_ARN`, `AWS_RDS_ENDPOINT` — so the API assembles its connection string at runtime rather than storing a static DB password.

### Networking (CCOE-managed)
The shared VPC that the UX layer runs inside.

- VPC `vpc-8c57a5f4`, **3 subnets** consumed as inputs.
- Allowed PG&E corp CIDRs: `10/8`, `172.16/12`, `172.30/16`, `192.168/16`, `131.89/16`, `131.90/16`.
- Route 53 **private** zone `Z1PO7XO596QKJW` and **public** zone `Z184J8PGMR81S`.

---

## 2. Source of Truth (GitHub — pgetech org)

Everything EPIC executes originates in GitHub. There is no hidden state: the contract, the pipeline, and the infrastructure modules are all versioned here.

### Application Repositories (N teams)
Each application team owns a repo containing the EPIC contract.

- `.pipeline/epic.json` is **the contract** — it is the only file teams must author.
- Protected by **branch protection**, **CodeQL**, and **secret scanning**.

The orchestrator actually consumes these keys from `epic.json`:

- **`app` section:** `appName`, `appType`, `codePath`, `infraPath`, `runtimeVersion`, `scanTool`, `buildTestTool`, `integrationTestTool`, `approvalEnvironments`, `appServiceName`, `appExecutable`.
- **`cloud` section (AWS):** `awsAccountId`, `awsRegion`, `s3`, `cloudfront`, `ec2InstanceId`.
- **`cloud` section (Azure):** `azureSubscriptionId`, `azureRegion`, `resourceGroupName`.
- **`cloud` section (BTP):** `secretsManager.name`, `secretsManager.keys[]`.

### epic-pipeline (1 repo)
The pipeline framework itself.

- `epic-orchestrator.yml` and `epic-engine.yml` are the two top-level pipelines.
- Stage templates: `build/`, `test/`, `scan/`, `infra/`, `deploy/`.
- Build dispatch: `build/{angular,react,dotnet,…}` · scan: `scan/{sonarqube,wiz,jfrog}` · infra: `infra/{aws.yml,azure.yml,btp.yml}` · deploy: `deploy/{aws,azure}`.

### Terraform Modules (versioned)
Reusable infrastructure building blocks.

- Source: `https://github.com/pgetech/epic-pipeline-module-aws-….git?ref=main`.
- Tags/modules include: `secretsmanager`, `certificate`, `security-group`, `s3`, `ec2`, `load-balancer`, `route53`, `cloudfront`, `acm`.

### Auth
`GITHUB_PAT` (sourced via the ADO variable group **`GV-account-access`**) is used both for the orchestrator's `git clone` and for the epic-api GitHub API calls.

---

## 3. CI/CD Control Plane (Azure DevOps — pgetech / EPIC-Pipeline)

This is where pipelines actually run. The control plane is split into a lightweight **orchestrator** (the entry point) and a heavyweight **engine** (the execution plane), backed by agent pools.

### Orchestrator (`epic-orchestrator.yml`)
The thin, auditable entry point. It contains no Terraform or build logic.

- **Pool:** `vmImage: ubuntu-latest` (Microsoft-hosted).
- **Validates** the runtime parameters (repo, branch, config, environment).
- **`git clone`**s the app repo (via `GITHUB_PAT`) to read `.pipeline/epic.json`.
- **Builds the engine payload** with `jq` — normalizing booleans, detecting the cloud provider, resolving whether infrastructure exists, and resolving the approval gate.
- **Triggers the engine** with `POST /_apis/pipelines/194/runs` (the engine's pipeline ID) and returns a clean, clickable run URL.
- **Tags its own build** with `epicRepo` and `epicAppName`.

**Cloud detection logic** (resolved in the orchestrator): `appType == "btp"` → BTP; else `cloud.awsAccountId` → AWS; else `cloud.azureSubscriptionId` → Azure; default AWS.

**Infra resolution:** if the `infraPath` folder is absent *and* the app is not BTP, `terraformAction` is forced to `none`; otherwise it honors the requested `apply`/`destroy`.

### Engine (`epic-engine.yml`, parameterized YAML)
The control plane that wires up the stages with correct dependency ordering.

- **Default pool:** `vmImage: ubuntu-latest`.
- **Tags every build** with `epicRepo`, `epicAppName`, `epicAppType`, `epicEnvironment`, and `epicCloud` — these tags are what the epic-api and dashboard later read back to populate the Technology / Cloud / Environment columns.

### Agent Pools
- **Microsoft-hosted (`ubuntu-latest`)** — the default for Build / Test / Deploy / Infra.
- **`windows-latest`** — used for .NET builds when `scanTool` is SonarQube.
- **Pool `EPIC - Self-hosted`** — reserved for Wiz / SonarQube scans.

### Engine Stage Flow
The engine assembles up to eight stages, each conditionally included based on the payload. Dependency ordering is enforced so that scan/infra/approval/deploy fan in correctly.

1. **Download** — pulls the app source.
2. **Build** — `build/{appType}/main.yml`.
3. **Build Tests** — `test/{tool}` (only when a `buildTestTool` is set).
4. **Scan** — `sonarqube` · `wiz` · `jfrog` *(purple = SaaS/centralized scanning)*.
5. **Infra** — `infra/{aws · azure · btp}.yml` — Terraform.
6. **Approval** — `ManualValidation@0` (only when the target env is in `approvalEnvironments`).
7. **Deploy** — `deploy/{aws · azure}/*` — to the target cloud.
8. **Integration Tests** — post-deploy verification.

The **Scan** stage (and the **Approval** invocation) reach out to the centralized Quality & Security band at the bottom of the diagram, rather than being self-contained.

---

## 4. Multi-Cloud Workloads

This is where the applications actually land. EPIC dispatches to one of three target families, *per app, per environment*, based on the detected cloud provider. Each target uses a workload-specific identity, never a shared static credential.

### AWS Workload Account (per app · per env)
- **Trust:** the ADO "AWS" service connection assumes `sts:AssumeRole`.
- **Role:** `arn:aws:iam::{cloud.awsAccountId}:role/pge-epic-deployment-role`.
- **Session:** `EPIC-DEPLOY-ADO-{BuildId}` · region `cloud.awsRegion` (default `us-west-2`).
- **Workload patterns:**
  - **static** (html · angular · react) — `aws s3 sync` → bucket → `cloudfront create-invalidation`.
  - **ec2** (dotnet · python · java) — `aws s3 cp zip` → bucket → SSM `send-command` (`AWS-RunShellScript`), then wait for instance-status-ok / stop/start systemd unit / is-active check.
  - **ami** — AWS Image Builder pipeline.
- **Terraform:** `aws.yml` (S3 backend + DynamoDB lock) runs as `pge-epic-deployment-role`.

### Azure Workload Subscription (per app · per env)
- **Trust:** the ADO Service Connection / Service Principal.
- **Subscription:** `cloud.azureSubscriptionId` · region `cloud.azureRegion` (default `westus2`).
- **app-service** (any appType): Resource Group `cloud.resourceGroupName`, App Service `cloud.appServiceName` — single template.
- **Available via Terraform modules:** Function · Key Vault · PostgreSQL Flex · SQL · Storage.
- **Terraform:** `azure.yml` (AzureRM provider · S3 backend reused).

### SAP BTP Subaccounts & Cloud Foundry (per app · per env)
- **Auth:** `BTP_USERNAME` · `BTP_PASSWORD` · `CF_USER` · `CF_PASSWORD`, pulled from AWS Secrets Manager — the secret name and key list come from `epic.json`'s `cloud.secretsManager.name` and `cloud.secretsManager.keys[]`.
- **`infra/btp.yml` flow:** secrets → temp env file → terraform `init` / `fmt` / `validate` / `test` / `plan` / `apply` / `destroy` → `cf push` for the app tier.
- **Providers:** `SAP/btp` · `cloudfoundry/cloudfoundry`.

---

## 5. Centralized Quality & Security (Scan + Approval invocations)

Rather than each app re-implementing quality gates, EPIC routes every run through a shared set of services. These are invoked from the engine's Scan and Approval stages.

- **Wiz** — `scan/wiz/main.yml`; Pool `EPIC - Self-hosted`; CSPM · IaC scanning.
- **SonarQube** — `scan/sonarqube/{prepare,scan,normalize}`; Pool `EPIC - Self-hosted`; coverage normalization for .NET.
- **JFrog Xray** — `scan/jfrog` (where used); default pool `ubuntu-latest`; SCA · artifact registry.
- **GitHub Advanced Security** — branch protection · CodeQL · secret scanning · Dependabot.
- **ADO Manual Validation** — `ManualValidation@0` task, triggered by the `approvalEnvironments[]` array in `epic.json`.
- **ADO Build Tags** — `PUT _apis/build/builds/{id}/tags?api-version=7.1`; the 5 EPIC tags form the audit trail and the data source for the dashboard.
- **CloudWatch + ADO Logs** — EC2/Aurora logs and ADO run logs, surfaced back in the EPIC dashboard.

---

## End-to-End Flow Summary

Putting the layers together, a single deployment travels through the platform like this:

1. A developer (or the epic-web dashboard via epic-api) triggers the **orchestrator** in Azure DevOps.
2. The orchestrator clones the app repo from **GitHub**, reads `.pipeline/epic.json`, detects the cloud provider, resolves the infra and approval gates, and builds a payload.
3. The orchestrator `POST`s that payload to the **engine** (pipeline 194) and returns a run URL.
4. The engine downloads the source, then conditionally runs **Build → Build Tests → Scan → Infra → Approval → Deploy → Integration Tests**, tagging the build with `epicRepo` / `epicAppName` / `epicAppType` / `epicEnvironment` / `epicCloud` along the way.
5. Scans route through the **centralized** Wiz / SonarQube / JFrog services; approval (when required) goes through ADO Manual Validation.
6. Deploy dispatches to the detected **cloud workload** — AWS (assume-role), Azure (service principal), or BTP (Cloud Foundry) — provisioning infrastructure via the versioned Terraform modules when `terraformAction` is not `none`.
7. **epic-api** reads the build tags and ADO run state back, persists them to Aurora, and **epic-web** surfaces the live status in the dashboard.

The result is one pipeline, one set of guarantees (auth, tagging, networking, scanning, audit), and 100% coverage — with the only per-team variation living in a single declarative `epic.json` contract.
