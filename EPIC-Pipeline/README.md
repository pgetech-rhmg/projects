# EPIC (Enterprise Pipeline for Infrastructure and Cloud) ADO Pipeline

## Overview

EPIC is an enterprise-grade Azure DevOps pipeline framework for building, testing, scanning, and deploying applications — and optionally provisioning the infrastructure they run on.

It is designed to be orchestrated by an upstream engine or IDP and executed consistently across projects using a standardized pipeline contract.

Applications define their intent in a single config file. EPIC handles execution.

---

![Workflow](CICD.png)

---

## High-Level Flow

1. Orchestrator validates parameters and reads the `app` section of `.pipeline/epic.json` from the application repository
2. Orchestrator invokes the EPIC Engine pipeline via Azure DevOps REST API
3. Application source is downloaded from GitHub
4. The source is reviewed against PG&E's AIDLC compliance controls (compliance gate; blocks the pipeline on failure)
5. Build is executed based on project type
6. Build tests are executed
7. Security and quality scans are performed
8. Infrastructure is provisioned if `/.infra` is present (Terraform)
9. Application is deployed to the target environment (AWS, Azure, or SAP)
10. Integration tests are run (optional)

Stages that need cloud/deployment configuration (infra, deploy, AMI build) read the `cloud` section of `.pipeline/epic.json` directly from the downloaded source at runtime.

---

## Repository Structure

```
EPIC-Pipeline/
├── epic-orchestrator.yml        # REST-driven entry point; reads epic.json .app section, invokes engine
├── epic-engine.yml              # Control plane; wires stages, enforces ordering and gating
├── common/
│   ├── gh-app-token.yml         # Mints a GitHub App installation token (PAT fallback) → $(GH_TOKEN)
│   ├── download.yml             # Clones application source from GitHub
│   ├── github-status.yml        # Posts a rollup "EPIC" commit status to GitHub (CI merge-gating)
│   └── jfrog/
│       ├── upload.yml           # Uploads build artifacts to JFrog Artifactory
│       └── download.yml         # Downloads artifacts from JFrog Artifactory
├── review/
│   └── main.yml                 # PG&E compliance gate (epic-compliance CLI pulled from S3)
├── infra/
│   ├── main.yml                 # Infrastructure dispatcher (routes by cloud provider)
│   ├── aws.yml                  # AWS Terraform provisioning (S3 backend, STS role assumption)
│   ├── azure.yml                # Azure Terraform provisioning (Storage Account backend)
│   └── sap.yml                  # SAP BTP Terraform provisioning (Secrets Manager + BTP/CF providers)
├── build/
│   ├── main.yml                 # Build dispatcher
│   ├── ami/                     # EC2 Image Builder orchestration
│   ├── angular/
│   ├── react/
│   ├── cap/                     # SAP CAP → MTA archive (cds build + mbt build)
│   ├── dotnet/
│   ├── dotnet_framework/
│   ├── go/                      # Go module → static linux/amd64 binary (CGO disabled)
│   ├── java/
│   ├── node/                    # Generic Node runtime → App Service zip, or Azure Functions v4 package (buildType: function)
│   ├── php/
│   └── python/
├── test/
│   ├── main.yml                 # Test dispatcher (build + integration)
│   ├── jest/
│   ├── karma/                   # Angular unit tests (headless Chrome + coverage)
│   ├── vitest/
│   ├── junit/
│   ├── phpunit/
│   ├── pytest/
│   ├── xunit/
│   ├── gotestsum/               # Go unit tests + coverage (JUnit XML for SonarQube)
│   └── playwright/              # Integration tests (browser E2E against deployed app)
├── scan/
│   ├── main.yml                 # Scan dispatcher
│   ├── sonarqube/
│   │   ├── prepare.yml          # SonarQube prepare (sets properties per framework)
│   │   ├── normalize.yml        # Normalizes coverage paths for multi-agent builds
│   │   └── scan.yml             # SonarQube analyze + quality gate
│   └── wiz/
│       └── main.yml             # Wiz CLI dir scan (IaC, secrets, vulnerabilities)
├── deploy/
│   ├── main.yml                 # Deployment dispatcher (cloud-aware)
│   ├── aws/
│   │   ├── static/              # HTML/Angular/React → S3 + CloudFront
│   │   ├── ec2/                 # dotnet, python, java, go → S3 + EC2 via SSM
│   │   └── ami/                 # SSM-based AMI publish + config/test
│   ├── azure/
│   │   ├── static/              # Storage $web static site (html, angular, react) + runtime config.js injection
│   │   ├── app-service/         # App Service zip deploy (all other runtimes)
│   │   └── function/            # Azure Functions config-zip deploy (buildType: function)
│   └── sap/
│       └── cap.yml              # SAP CAP → cf deploy MTA to Cloud Foundry
└── .gitignore
```

---

## Design Principles

- **Modular** — Every stage is a composable template
- **Declarative** — Applications define intent; EPIC determines execution
- **Cloud-aware** — Supports AWS, Azure, and SAP deployments from the same pipeline
- **Engine-driven** — Designed for programmatic orchestration, not manual runs
- **Secure by default** — Compliance review, scanning, and testing are first-class citizens
- **Infrastructure-aware** — Can provision and manage cloud resources directly
- **Enterprise-ready** — Predictable, repeatable, auditable

---

## Intended Usage

Applications are not expected to copy or modify this pipeline. Instead:

- Applications conform to the EPIC contract (`.pipeline/epic.json`)
- Orchestrators supply configuration and trigger execution
- EPIC executes consistently across teams

---

## Core Pipelines

### `epic-orchestrator.yml`

The entry point for external systems. It can be started three ways:

- **REST / IDP** — the EPIC API (or any caller) POSTs to the ADO Pipelines REST API with explicit parameters (the normal web-UI path).
- **Manual** — run directly in Azure DevOps with parameters.
- **GitHub webhook push (CI)** — an incoming-webhook service connection (`epicHook`) fires the orchestrator on push. The repo/branch/owner/commit come from the push payload, and a safe CI toggle set is applied automatically (see [GitHub CI Trigger & Commit-Status Gating](#github-ci-trigger--commit-status-gating)).

**What it does:**
1. Validates `repo`, `branch`, `config`, and `environment` parameters (a webhook push fills `repo`/`branch`/`owner` from the `epicHook` payload instead)
2. Shallow-clones the application repository (from the resolved GitHub `owner`/`githubHost` — see [Multi-org GitHub](#multi-org-github-sources); auth via a GitHub App installation token minted by `common/gh-app-token.yml`, PAT fallback) and reads the `app` section of the specified epic.json config. If the repo/branch has **no `epic.json`**, it synthesizes a minimal Review-only payload instead of failing (see [Contract-less runs](#contract-less-review-only-runs))
3. Detects cloud provider from `epic.json` (`appType: "btp"` or `"cap"` → SAP, then `awsAccountId` → AWS, then an Azure service connection — `azureServiceConnection` flat or per-environment, or a legacy `azureSubscriptionId` — → Azure)
4. Resolves `infraPath` (defaults to `.infra`) and checks whether infrastructure exists
5. Resolves `requireApproval` from `approvalEnvironments` array if the target environment is listed
6. Tags its own build with `epicRepo.{repo}` and `epicAppName.{appName}`
7. Builds a deployment payload (merges `app` fields with orchestrator parameters including `cloudProvider` and `terraformAction`)
8. POSTs to the Azure DevOps Pipelines REST API to trigger the EPIC Engine
9. Returns a clickable URL to the triggered pipeline run

### `epic-engine.yml`

The control plane. Accepts parameters from the orchestrator, determines which stages execute, and wires modular templates with proper dependency ordering. Contains no business logic — it is purely structural.

The engine receives `app`-level parameters (identity, build config, tooling) and runtime parameters (`repo`, `branch`, `environment`, `cloudProvider`, `terraformAction`, `requireApproval`, stage toggles). Cloud/deployment parameters are not passed through the engine — stages read them directly from `epic.json` at runtime.

The engine also defines `defaultRuntimeVersion` as a compile-time variable based on `appType`. Because that variable is not in scope inside included templates, the engine passes its value down to the build, test, and scan stage templates as a `defaultRuntimeVersion` **parameter**. The templates then resolve the effective version via `coalesce(parameters.runtimeVersion, parameters.defaultRuntimeVersion)` — using `runtimeVersion` from `epic.json` if present, otherwise the engine's per-appType default.

**Build Tags:** During the Download stage, the engine tags its build with metadata for traceability and IDP integration:
- `epicRepo.{repo}` — source repository
- `epicAppName.{appName}` — logical application name
- `epicAppType.{appType}` — application type
- `epicEnvironment.{environment}` — target environment
- `epicCloud.{cloudProvider}` — cloud provider (`aws`, `azure`, `sap`)

> **Note:** The SAP cloud provider value is `sap` (both `btp` and `cap` appTypes resolve to it). Pipeline runs prior to this rename emitted `epicCloud.btp`; consumers of these tags (e.g. the EPIC API) treat the legacy `btp` value and the current `sap` value identically, so historical runs remain correctly attributed.

---

## Stage Execution Order and Gating

Stages execute in dependency order. Conditional stages are skipped entirely when their corresponding tool parameter is omitted.

```
Download
└── Review            (if review=true; PG&E compliance gate — blocks everything downstream on failure)
    ├── Build             (if build=true)
    ├── BuildTest         (if buildTestTool is set)
    ├── Scan              (if scanTool is set; depends on Build and BuildTest if enabled)
    ├── DeployInfra       (if terraformAction != none; depends on Build, BuildTest, Scan if enabled)
    ├── Approval          (if requireApproval=true; depends on Build, BuildTest, Scan, DeployInfra)
    └── Deploy            (depends on Build, BuildTest, Scan, DeployInfra, Approval if each enabled)
        └── IntegrationTest  (if integrationTestTool is set; depends on Deploy)
```

The **Review** stage runs immediately after Download and before Build. Build, BuildTest, Scan, and DeployInfra all `dependsOn: Review` (when `review=true`), so a failing compliance gate blocks the entire downstream pipeline.

On webhook-push (CI) runs the engine also emits three meta-stages — `ReportPending`, `ReportSuccess`, `ReportFailure` — that post a rollup commit status to GitHub. They are compile-gated on a non-empty `commitSha`, so they never appear on manual/REST runs. See [GitHub CI Trigger & Commit-Status Gating](#github-ci-trigger--commit-status-gating).

---

## GitHub CI Trigger & Commit-Status Gating

EPIC can be driven by a GitHub push, not just the IDP/REST path, and report a single pass/fail status back so branch protection can gate PR merges.

**Trigger.** `epic-orchestrator.yml` declares `resources.webhooks` bound to an incoming-webhook ADO service connection (`epicHook`). On push, `repo`/`branch`/`owner` are resolved from the push payload (`epicHook.repository.name`, `epicHook.ref`, `epicHook.repository.owner.login`) when the equivalent explicit parameters are empty; manual/REST runs supply them directly and take precedence.

> **Naming gotcha:** the YAML `connection:` binds to the ADO **Service Connection Name**, while the GitHub Payload URL path segment is the **WebHook Name** — two different ADO fields that may share a value (both `epic-github` here).

**CI toggle defaults.** A webhook push carries no stage toggles, so when the run is a resource-trigger the orchestrator forces a safe set: **review + build + tests + scan on, deploy + infra off**. Manual/REST runs keep their exact toggles. CI runs are also stamped `triggeredBy = "Github CI"`.

**Commit-status rollup.** The orchestrator captures the pushed head SHA (`epicHook.after`) and threads it into the engine as `commitSha`. The engine then emits three status stages (all gated on `commitSha != ''`):

| Stage | When | Posts |
|-------|------|-------|
| `ReportPending` | immediately (no `dependsOn`) | `state=pending` |
| `ReportSuccess` | `condition: succeeded()`, `dependsOn` every created stage | `state=success` |
| `ReportFailure` | `condition: not(succeeded())`, same deps | `state=failure` |

All three call the reusable `common/github-status.yml` job, which POSTs to the GitHub Commit Statuses API (`/repos/{owner}/{repo}/statuses/{sha}`) with context **`EPIC`** and a `target_url` linking back to the ADO run. Auth is a **GitHub App installation token** minted by `common/gh-app-token.yml` (App needs *Commit statuses: Read & Write*), falling back to `GITHUB_PAT` (`repo:status`) for orgs without an App install; it computes the API base (`api.github.com` for `github.com`, else `https://<host>/api/v3` for GitHub Enterprise), and fails the run only on a non-201 **pending** post (catches a bad token early without masking real results). Mark the `EPIC` context a required status check on the target branch in GitHub to block merges on a failing pipeline.

> ⚠️ Never send `""` for a string templateParameter through the ADO runs REST API — it is rejected (`PipelineValidationException`). The orchestrator **omits** `commitSha` when empty so the engine's `default: ""` applies and the report stages stay off.

---

## Multi-org GitHub Sources

EPIC is not hardwired to one GitHub org. Every GitHub-touching stage threads an `owner` (org) and `githubHost` (default `pgetech` / `github.com`), so the orchestrator can clone, the download stage can fetch, and the commit-status job can post against whichever org a given app lives in. The EPIC API resolves the source from its named source registry and passes `owner`/`githubHost` into the orchestrator; a webhook push derives them from `epicHook.repository.owner.login`.

Auth is per-org via a **GitHub App**: each pipeline job mints a short-lived installation token (`common/gh-app-token.yml` resolves the install for the repo's org at runtime), and the EPIC API mints per-source installation tokens keyed by each source's `InstallationId`. An org without an App installation falls back to the shared `GITHUB_PAT` (whose owner must be a member of that org). Currently `pgetech` runs on the App; `PGEDigitalCatalyst` remains on the PAT until its install lands.

---

## Contract-less (Review-only) runs

A trigger (webhook, REST, or manual) for a repo/branch that has **no `.pipeline/epic.json`** does not fail. The orchestrator's `NO_CONFIG` branch synthesizes a minimal payload: `review=true`, every other stage toggle off, `terraformAction=none`, `appType=""`, `appName=`the repo name, `codePath=""`. Every non-Review stage self-disables via its toggle + tool guard, and the compliance gate profiles the repo and runs without a contract (`--app-type ""` is valid). This gives any repo a compliance gate with zero onboarding. The EPIC web UI surfaces this: a repo with no config still offers a **Review App**-only run.

---

## Pipeline Artifacts

Each stage publishes a named artifact consumed by downstream stages:

| Artifact | Published By | Consumed By |
|----------|-------------|-------------|
| `epic-app` | Download | Build, Test, Scan, Infra, Deploy, Review |
| `epic-compliance-review` | Review | — (SARIF + JSON + Markdown compliance report; surfaced by the EPIC API/UI) |
| `epic-build` | Build | Scan, Deploy |
| `epic-build-tests` | BuildTest | Scan |
| `epic-integration-tests` | IntegrationTest | — |
| `terraform-outputs` | DeployInfra | Deploy, IntegrationTest (resolves `BASE_URL`) |
| `epic-scan` | Scan (.NET only) | — |
| `epic-wiz-scan` | Scan (Wiz only) | — |

---

## Agent Pools

| Pool | Used For |
|------|----------|
| `ubuntu-latest` | Default for all non-.NET languages and basic deployments |
| `windows-latest` | .NET Framework builds without SonarQube |
| `EPIC - Self-hosted` | .NET builds with SonarQube, Wiz scans (requires SQ scanner and Wiz CLI pre-installed) |

---

## Prerequisites

The following secrets and variable groups must be configured in Azure DevOps:

| Secret / Variable | Variable Group | Purpose |
|-------------------|----------------|---------|
| `GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY` | `GV-account-access` | GitHub App used to clone application repos, read `epic.json`/infra, and post the `EPIC` commit status. `common/gh-app-token.yml` mints a short-lived installation token per job (resolved for the repo's org). App needs *Contents: Read* + *Commit statuses: Read & Write*. |
| `GITHUB_PAT` | `GV-account-access` | Fallback for orgs without a GitHub App installation (e.g. not-yet-migrated). Needs `repo` + `repo:status`; owner must be a member of every such org (see [Multi-org GitHub](#multi-org-github-sources)). |
| `epic-github` (webhook) | Service connection | Incoming GitHub webhook connection bound to the `epicHook` resource for push-triggered CI runs |
| `WIZ_CLIENT_ID` | `GV-account-access` | Wiz service account client ID |
| `WIZ_CLIENT_SECRET` | `GV-account-access` | Wiz service account client secret |
| `COMPLIANCE_REVIEWER_VERSION` | `GV-account-access` | Pinned epic-compliance CLI version pulled from S3 by the Review stage |
| `PORTKEY_API_KEY` | `GV-account-access` | PG&E Portkey gateway key for the compliance gate's LLM checks |
| `PORTKEY_BASE_URL` | `GV-account-access` | Portkey gateway base URL |
| `PORTKEY_MODEL` | `GV-account-access` | LLM model routed via Portkey (Opus 4.8) |
| AWS credentials | `AWS` service connection | Base credentials for STS role assumption |
| Azure credentials | `Azure` service connection (default) | Azure deployments. Apps targeting a non-default subscription/tenant reference their own connection by name via `cloud.azureServiceConnection` (or the per-environment `cloud.environments.<env>.azureServiceConnection`). Both **Workload Identity Federation (WIF/OIDC)** and **App registration (manual) + secret** connections work — EPIC auto-detects the scheme at run time (see [Credential Flow](#credential-flow)). WIF is the recommended/default approach; secret-based connections remain fully supported. |
| `SYSTEM_ACCESSTOKEN` | Built-in | REST API call from orchestrator to engine |

---

## Review Stage (Compliance Gate)

### Overview

The Review stage runs the **epic-compliance** CLI against the checked-out repo to verify it against PG&E's AIDLC steering docs (the T&S R&C Unified Controls Framework, keyed to NIST 800-53 control IDs). It runs after Download and before Build. It is a **peer of Wiz and SonarQube** with a distinct scope: Wiz covers cloud security posture, SonarQube covers code quality, and the Review stage covers PG&E-specific policy-as-code from the AIDLC steering docs.

The stage is enabled by default (`review=true`) and can be toggled off per run. It is applicable to app builds; infra-only appTypes (`btp`, `infra`) do not run it.

### How It Works (`review/main.yml`)

- Runs on the `EPIC - Self-hosted` pool (already has AWS creds + S3/KMS read on the artifact bucket).
- Pulls a **version-pinned, self-contained Go binary** from S3 (`s3://pge-epic-compliance-reviewer/compliance/epic-compliance-<version>-linux-amd64`) into the cleaned run workspace — no global install, no drift. The version is pinned via the `COMPLIANCE_REVIEWER_VERSION` variable.
- Runs a **hybrid engine**: deterministic regex/heuristic checks plus an LLM (Opus 4.8 via the PG&E Portkey gateway, `--llm`) for interpretive controls. The LLM falls back to deterministic per-control evaluation on gateway error.
- Profiles the app first (kind / auth-model / server-handling / IaC) and emits an attributed **N/A** for controls the app can't own under that profile (e.g. an SSO-delegated SPA is not failed for account-lockout controls).
- The CLI's **exit code gates the stage**: `0` = compliant, `1` = a hard-gating finding (fail), `2` = tool error. `--fail-on hard-fail` means only HARD-mapped control failures gate; PARTIAL/MANUAL/N/A surface as informational.

### Outputs

The stage publishes the `epic-compliance-review` artifact containing the report in three formats — findings are keyed to NIST control IDs:

| File | Purpose |
|------|---------|
| `compliance-report.sarif` | SARIF 2.1.0 (standard findings interchange) |
| `compliance-report.json` | Machine-readable report — consumed by the EPIC API/UI for the inline summary table and native report view |
| `compliance-report.md` | Human-readable report — offered as a downloadable report in the EPIC UI |

Reports are published on `succeededOrFailed()` so findings are available even when the gate fails — which is exactly when a developer needs to see them.

---

## Infrastructure Stage

### Overview

EPIC supports automated infrastructure provisioning via Terraform. This stage runs independently and does not block the build stage.

The infra stage executes when `terraformAction` is not `none`. The orchestrator determines this based on the presence of an infrastructure folder (resolved from `app.infraPath`, defaulting to `.infra`) and the user's requested action (`apply` or `destroy`). If no infrastructure folder exists or the action is `none`, the infra stage is skipped and EPIC uses the resource values provided in the `cloud` section of `epic.json`.

Cloud credentials are read from the `cloud` section of `.pipeline/epic.json` at runtime.

### `/.infra` Folder Structure

EPIC expects a standard Terraform layout:

```
.infra/
├── terraform.tf                # Backend + provider config
├── main.tf                     # Resource definitions
├── data.tf                     # Data source declarations
├── variables.tf                # Input variable declarations
├── terraform.auto.tfvars       # Input variable values
└── outputs.tf                  # Output values (used by EPIC for deployment)
```

### Backend Configuration

**AWS applications:**

| Setting | Value |
|---------|-------|
| Backend | S3 (`pge-epic-tfstate`) |
| Encryption | Server-side (SSE-S3, `encrypt=true`) |
| Locking | S3 native lock file (`use_lockfile=true`) |
| State key | `{awsAccountId}/{appName}-{appType}/{environment}/terraform.tfstate` |

**Azure applications:**

| Setting | Value |
|---------|-------|
| Backend | Azure Storage — account `epictfstate{first-8-of-subscription-id}` (per-subscription convention; overridable via `cloud.stateStorageAccount`) |
| Resource group | `rg-epic-tfstate` (overridable via `cloud.stateResourceGroup`) |
| Container | `tfstate` (overridable via `cloud.stateContainer`) |
| Encryption | Storage account encryption |
| State key | `{subscriptionId}/{appName}-{appType}/{environment}/terraform.tfstate` |

The state account name is **derived from the target subscription** (one account per subscription; the state key namespaces every app + environment within it), so the state home follows the subscription automatically. Because `terraform init` runs under the app's own Azure service connection, it authenticates to a state account in the app's **own tenant** — which is what makes cross-tenant deploys work. The account is created out of band (one per subscription); all three backend settings are overridable in `epic.json` (per-environment or flat) for a non-conventional setup.

### Credential Flow

**AWS:**
1. EPIC base AWS credentials are loaded from the ADO service connection
2. EPIC assumes `arn:aws:iam::{awsAccountId}:role/pge-epic-deployment-role` via STS
3. Temporary credentials are injected into the Terraform environment

**Azure:**
1. EPIC selects the ADO service connection for this run — `cloud.environments.<env>.azureServiceConnection` if set, else the flat `cloud.azureServiceConnection`, else the default `Azure`. This lets different environments target different subscriptions/tenants from one config.
2. The connection's Service Principal authenticates to its tenant, and the **target subscription is taken from the connection itself** (`az account show`) — `epic.json` does not restate the subscription ID.
3. A **resource group** is passed to Terraform as `-var="resource_group_name=<rg>"` when `epic.json` provides one (per-environment `cloud.environments.<env>.resourceGroup`, or flat `cloud.resourceGroupName`); otherwise the `.infra`'s own default applies.
4. **Terraform auth scheme is auto-detected** from the connection type (WIF is the default/recommended approach). Each Terraform step runs under `AzureCLI@2` with `addSpnToEnvironment: true` and inspects the exposed variables: a **WIF/OIDC** connection exposes a federated `$idToken` (no stored secret) → EPIC exports `ARM_USE_OIDC=true` + `ARM_OIDC_TOKEN`; an **App-registration + secret** connection exposes `$servicePrincipalKey` → EPIC exports `ARM_CLIENT_SECRET`. Both the `azurerm` provider and the `azurerm` state backend honor these, so `init`/`plan`/`apply`/`destroy` all authenticate the same way with no per-app configuration. Non-Terraform Azure steps (state bootstrap, `az acr build` image builds, static `$web` upload, App Service / Function deploys) run inside `AzureCLI@2` and use the task's native login, so WIF is transparent to them.

### Behavior

| Condition | EPIC Behavior |
|-----------|---------------|
| `terraformAction = apply` | Runs `terraform init`, `plan`, and `apply` |
| `terraformAction = destroy` | Runs `terraform init`, `plan -destroy`, and `apply` |
| `terraformAction = none` | Skips infra stage; uses resource values from `cloud` section of `epic.json` |

### Outputs

Terraform outputs defined in `outputs.tf` are captured as `output.json` and published as the `terraform-outputs` artifact. The deploy stage reads this file and resolves deployment targets automatically — overriding any equivalent values in the `cloud` section.

**Conventional outputs consumed by EPIC:**

| Output | Consumed By | Purpose |
|--------|-------------|---------|
| `bucket_name` | Deploy (AWS static) | Target S3 bucket |
| `distribution_id` | Deploy (AWS static) | CloudFront distribution for cache invalidation |
| `instance_id` | Deploy (AWS EC2) | Target EC2 instance for SSM deploy |
| `app_service_name`, `resource_group_name` | Deploy (Azure App Service) | Target App Service |
| `app_url` | IntegrationTest | Deployed application URL — used as `BASE_URL` for integration tests |

---

## Build Stage

### `build/main.yml`

Dispatcher that selects the correct build implementation based on `appType`. Each implementation installs tooling, runs the build, and normalizes output into a `.build/` folder.

Runtime versions are resolved via `coalesce(parameters.runtimeVersion, parameters.defaultRuntimeVersion)` — the app can override with `runtimeVersion` in `epic.json`, otherwise the engine's per-appType default (passed down as `defaultRuntimeVersion`) is used.

| Type | Build Tool | Output |
|------|-----------|--------|
| `angular` | npm | `dist/` → `.build/` |
| `react` | npm | `build/` / `dist/` / `out/` → `.build/` |
| `cap` | `cds build` + `mbt build` | MTA archive → `.build/archive.mtar` |
| `ami` | EC2 Image Builder | AMI IDs → SSM → `.build/ami-manifest.json` |
| `dotnet` | dotnet CLI | Published self-contained executable or NuGet package |
| `dotnet_framework` | MSBuild | `.build/` |
| `go` | `go build` | Static linux/amd64 binary (CGO disabled) → `.build/{appName}` |
| `html` | (copy) | `.build/` |
| `java` | Maven or Gradle | JAR → `.build/` |
| `node` | npm | `.build/` (App Service zip), or Azure Functions v4 package when `buildType: function` |
| `php` | Composer | `.build/` (excludes tests, .infra, .pipeline) |
| `python` | pip / setuptools | Syntax check, wheel, egg, or sdist |

The `node` build is a generic Node runtime builder (`npm ci`/`npm install` → `npm run build --if-present` → prune dev deps). With `buildType: function` it instead assembles an **Azure Functions v4** package (`host.json` + `package.json` + a compiled `dist/` + production `node_modules`) for the Azure Function deploy target. It carries no framework-specific logic — use `angular`/`react` for SPA static builds.

### Runtime Version Defaults

If `runtimeVersion` is not specified in `epic.json`, the engine uses these defaults (defined in `epic-engine.yml` as `defaultRuntimeVersion`):

| appType | Default |
|---------|---------|
| `angular`, `react`, `html`, `cap`, `node` | `20` (Node.js) |
| `dotnet`, `dotnet_framework` | `9.x` (.NET SDK) |
| `python` | `3.11` |
| `java` | `17` |
| `go` | `1.23` |
| `php` | `8.3` |

### AMI Build

The `ami` build type triggers EC2 Image Builder pipelines, polls for completion, writes AMI IDs to SSM Parameter Store with a `LATEST` label, and produces an `ami-manifest.json` artifact. AMI-specific configuration (`components`, `imageBuilderPipelinePrefix`, `ssmParameterPrefix`) is read from the `cloud` section of `epic.json`.

---

## Test Stage

### `test/main.yml`

Executes unit or integration tests, generates reports, and fails the pipeline on test failure. Output is normalized into a `.reports/` folder and published as a pipeline artifact.

**Build test frameworks (`buildTestTool`):**

| Framework | Language | Report Format |
|-----------|----------|--------------|
| `jest` | JavaScript / TypeScript | JUnit XML + LCOV coverage |
| `karma` | Angular (TypeScript) | LCOV coverage (headless Chrome) |
| `vitest` | JavaScript / TypeScript | LCOV coverage |
| `junit` | Java | JUnit XML + JaCoCo coverage |
| `phpunit` | PHP | JUnit XML + Clover coverage |
| `pytest` | Python | JUnit XML + coverage XML |
| `xunit` | .NET | xUnit XML + OpenCover |
| `gotestsum` | Go | JUnit XML + Go coverage profile |

**Integration test frameworks (`integrationTestTool`):**

| Framework | Use Case | Report Format |
|-----------|----------|--------------|
| `playwright` | Browser-based end-to-end tests against the deployed app | JUnit XML + HTML report (+ traces/screenshots on failure) |

### Integration Tests

The `IntegrationTest` stage runs after `Deploy` (and `DeployInfra`, if present) and is gated by `integrationTestTool` being set. Tests run against the freshly-deployed application.

**`BASE_URL` resolution:** Before the integration test template runs, `test/main.yml` resolves a `BASE_URL` pipeline variable that points at the deployed app. Tests consume it via `process.env.BASE_URL` (or the equivalent in their framework).

Resolution order:

1. **Terraform output `app_url`** — if `terraform-outputs` artifact is published by the DeployInfra stage and contains an `app_url` output, that value is used.
2. **`cloud.appUrl` from `epic.json`** — fallback for apps deploying to pre-existing infrastructure (no `.infra` folder).

If neither is present, the integration test stage fails with a clear error.

#### Playwright

The `playwright` template:

1. Installs Node and runs `npm install --legacy-peer-deps`
2. Runs `npx playwright install --with-deps` to install browsers + system libraries on the agent
3. Runs `npx playwright test --reporter=list,junit,html` with `BASE_URL` exported as an env var
4. Copies `reports/` → `.reports/` for artifact publication
5. Publishes JUnit results to the ADO Tests tab via `PublishTestResults@2`

**App-side requirements:**

- `npm install -D @playwright/test`
- `playwright.config.ts` must:
  - Set `use.baseURL: process.env.BASE_URL` so tests target the deployed app
  - Emit JUnit reports to `reports/junit/` (e.g. `outputFile: 'reports/junit/results.xml'`)
  - Emit HTML reports to `reports/html/` (e.g. `outputFolder: 'reports/html'`)
- Set `integrationTestTool: "playwright"` in `.pipeline/epic.json`
- Expose the deployed app URL via **one** of:
  - A Terraform output named `app_url` in `.infra/outputs.tf` (preferred when EPIC provisions infra), e.g.:
    ```hcl
    output "app_url" {
      value = "https://${aws_cloudfront_distribution.this.domain_name}"
    }
    ```
  - A `cloud.appUrl` field in `epic.json` (when deploying to pre-existing infrastructure)

**Network access:** Microsoft-hosted `ubuntu-latest` agents must be able to reach `BASE_URL`. Apps deployed behind private networking, internal ALBs, or `*.lab.pge.com` URLs will require a self-hosted agent in the same network.

---

## Scan Stage

### `scan/main.yml`

Security and quality scan dispatcher. Scanner selection is data-driven. Enforces quality gates when configured. Consumes both build artifacts and test reports to provide full coverage analysis.

**Supported scanners:** SonarQube, Wiz

### SonarQube Integration

- Runs on `EPIC - Self-hosted` pool (in-house agent with SonarQube CLI available)
- **CLI mode** (ubuntu-latest): Used for Angular, React, Python, Java, PHP, Go
- **dotnet mode** (EPIC Self-hosted): Used for .NET; requires pre/post build instrumentation
- Test coverage and report paths are mapped automatically per framework
- Branch awareness is enabled via `sonar.branch.name`

### Wiz Integration

- Runs on `EPIC - Self-hosted` pool (in-house agent with Wiz CLI available)
- Authenticates via `WIZ_CLIENT_ID` and `WIZ_CLIENT_SECRET` from the `GV-account-access` variable group
- Performs a directory scan (IaC, secrets, and vulnerability detection)
- Policy is configured per-app via `scanPolicy` in `epic.json`
- Results are published as the `epic-wiz-scan` artifact in SARIF format

---

## Deploy Stage

### `deploy/main.yml`

Cloud-aware deployment dispatcher. Routes to the appropriate deploy implementation based on the `cloudProvider` resolved by the orchestrator (`aws`, `azure`, or `sap`) and the `appType`.

**Routing:** The dispatcher branches on `cloudProvider` (`aws` / `azure` / `sap`), reads the cloud-specific config from `epic.json`, and selects the per-`appType` template within that branch.

**Resolution order for deploy targets:**
1. Terraform outputs (from DeployInfra stage)
2. Cloud config from `epic.json` (fallback for pre-existing infrastructure)

### Deploy Structure

```
deploy/
├── main.yml              ← Branches on cloudProvider, reads config, routes
├── aws/
│   ├── static/           ← S3 + CloudFront (html, angular, react)
│   ├── ec2/              ← S3 + EC2 via SSM (dotnet, python, java)
│   └── ami/              ← Image Builder + SSM config/test
├── azure/
│   ├── static/           ← Storage $web static site (html, angular, react) + runtime config.js
│   ├── app-service/      ← az webapp deploy (all other runtimes)
│   └── function/         ← az functionapp config-zip (buildType: function)
└── sap/
    └── cap.yml           ← cf deploy MTA to Cloud Foundry (cap)
```

### AWS Deploy Targets

| appType | Target | Mechanism |
|---------|--------|-----------|
| `html`, `angular`, `react` | S3 + CloudFront | `aws s3 sync`, CloudFront invalidation |
| `dotnet` | EC2 via SSM | ZIP upload to S3, remote install + systemd restart |
| `python` | EC2 via SSM | ZIP upload to S3, remote install + venv + systemd restart |
| `java` | EC2 via SSM | JAR upload to S3, remote install + systemd restart |
| `go` | EC2 via SSM | Static binary upload to S3, remote install + systemd restart |
| `ami` | SSM Parameter Store + SSM Documents | Label SSM params, run config/test documents |

### Azure Deploy Targets

| Condition | Target | Mechanism |
|-----------|--------|-----------|
| `buildType: function` (any appType) | Azure Function App | `az functionapp deployment source config-zip` |
| `html`, `angular`, `react` (non-function) | Storage static website | `az storage blob upload-batch` into the `$web` container |
| All other runtimes (`node`, `php`, `dotnet`, `python`, `java`, …) (non-function) | App Service | `az webapp deploy --type zip` |

The deploy dispatcher checks `buildType: function` **first** (routes to the Function template regardless of appType), then branches by `appType`: static SPA/HTML types go to the Storage `$web` template, everything else to App Service. App Service and Function both handle runtime selection at the infrastructure level — those templates are runtime-agnostic. App Service / Function resolve their target from a Terraform `app_service_name` + `resource_group_name` output, falling back to `cloud.appServiceName` + `cloud.resourceGroup` (per-environment override first) from `epic.json`.

#### Runtime `config.js` injection (static SPA deploys)

For an SPA deployed to a Storage `$web` site, the static template can inject a **runtime config file** at deploy time so a single build serves every environment (no per-env rebuild). If `epic.json` provides `cloud.environments.<env>.appConfig` (or flat `cloud.appConfig`), the deploy step writes:

```js
window.__APP_CONFIG__ = <the appConfig JSON>;
```

to `config.js` in the build output before uploading. The SPA loads `/config.js` before its bundle and reads `window.__APP_CONFIG__` (e.g. `apiUrl`, per-environment OIDC client/tenant IDs) at runtime. When `appConfig` is absent the step is skipped and the app's own bundled default `config.js` is used unchanged. (Currently implemented for the Azure static path; the AWS static path does not yet inject it.)

**Static-site storage account resolution** (nothing hardcoded): Terraform output `frontend_storage_account` → `cloud.environments.<env>.staticStorageAccount` → flat `cloud.staticStorageAccount`. A code-only frontend (no `.infra` of its own) deploys via the `epic.json` value; when a separate backend pipeline provisions the account, both sides agree on a **deterministic** name per environment.

### Container image build (optional, for container targets)

When `epic.json` includes a `cloud.containerImage` block, the Azure **infra** stage performs a **staged apply** that builds and pushes the app's container image mid-provision — solving the chicken-and-egg where a Container App must reference an image that doesn't exist until the same run creates its registry:

1. `terraform apply -target=<registryTarget>` — creates just the container registry
2. `az acr build --registry <from registryOutput> --image <imageName>:<BuildId>` — builds + pushes from the app's own `Dockerfile`
3. full `terraform apply -var="<tagVariable>=<BuildId>"` — the container app now points at the freshly-built image (a unique tag forces a new revision)

When the block is absent, the apply is a normal single pass — apps that don't build an image are unaffected. All inputs come from `epic.json` (see the Azure `cloud` parameters below); nothing is app-specific in the template.

### AMI Deploy

The `ami` deploy type publishes AMIs by applying an environment label to SSM parameter versions, then optionally runs SSM configuration and test documents against pre-existing instances. AMI-specific deploy configuration (`configDocPrefix`, `testDocPrefix`, `componentDocSuffixes`, `instanceTags`) is read from the `cloud` section of `epic.json`. SSM document names are constructed as `{prefix}-{suffix}` where the suffix comes from `componentDocSuffixes` (or defaults to the component name if not mapped).

### SAP

Two appTypes target the SAP cloud provider. Both resolve to `cloudProvider: "sap"` and authenticate the same way — the EPIC deployment role is assumed in the target AWS account and SAP/CF credentials are pulled from AWS Secrets Manager — but they have different lifecycles.

| appType | What it does | Stages used |
|---------|--------------|-------------|
| `btp` | **SAP BTP infrastructure** — provisions the subaccount, environments, entitlements, and services via Terraform | DeployInfra (`infra/sap.yml`) only |
| `cap` | **SAP CAP application** — builds the project into an MTA archive and pushes it to a **pre-existing** Cloud Foundry space | Build (`build/cap`) + Deploy (`deploy/sap/cap.yml`) |

#### `btp` — SAP BTP infrastructure provisioning

SAP BTP infrastructure apps (`appType: "btp"`) do not use the Build or Deploy App stages — infrastructure provisioning via Terraform **is** the deployment. The entire lifecycle is handled by the `infra/sap.yml` template through the DeployInfra stage.

**Flow:**
1. Reads `cloud.secretsManager.name` and `cloud.secretsManager.keys` from `epic.json`
2. Assumes the EPIC deployment role in the target AWS account (secrets are stored in AWS Secrets Manager)
3. Retrieves BTP/CF credentials from Secrets Manager and writes them to a temporary env file
4. Runs Terraform init (S3 backend), fmt, and validate
5. If scan is enabled and action is apply: runs TFLint
6. If tests are enabled and action is apply: runs `terraform test`
7. If `terraformAction = apply`: runs `terraform plan` and `terraform apply`
8. If `terraformAction = destroy`: runs `terraform plan -destroy` and `terraform apply`

**Disabled stages:** Build App, Deploy App, and Integration Tests are not applicable for `btp` and should be disabled when triggering runs.

#### `cap` — SAP CAP application deploy

SAP CAP apps (`appType: "cap"`) deploy an application to a Cloud Foundry org/space that already exists — EPIC does **not** provision the underlying infrastructure for them. Use `cap` together with the Build stage (the Deploy Infrastructure stage is typically left off).

**Flow:**
1. **Build** (`build/cap`): installs the SAP toolchain (`@sap/cds-dk`, `mbt`), runs `cds build --production` and `mbt build`, and publishes the resulting `archive.mtar` as the `epic-build` artifact
2. **Deploy** (`deploy/sap/cap.yml`): assumes the EPIC deployment role, pulls CF credentials from Secrets Manager, installs the Cloud Foundry CLI + `multiapps` plugin, authenticates and targets the org/space, then runs `cf deploy archive.mtar`

The managed services the app needs (xsuaa, HANA hdi-shared, html5-apps-repo, destination) are declared in the project's `mta.yaml` and created by `cf deploy` at deploy time.

**Required `cloud` parameters for SAP:**

| Parameter | `btp` | `cap` | Description |
|-----------|-------|-------|-------------|
| `awsAccountId` | Yes | Yes | AWS account where SAP/CF secrets are stored |
| `awsRegion` | No | No | AWS region for Secrets Manager (defaults to `us-west-2`) |
| `secretsManager.name` | Yes | Yes | Name of the AWS Secrets Manager secret |
| `secretsManager.keys` | Yes | Yes | Array of secret keys to retrieve (e.g., `BTP_USERNAME`, `BTP_PASSWORD`, `CF_USER`, `CF_PASSWORD`) |
| `cfApi` | — | Yes | Cloud Foundry API endpoint |
| `cfOrg` | — | Yes | Target Cloud Foundry org |
| `cfSpace` | — | Yes | Target Cloud Foundry space |
| `cfOrigin` | — | Yes | Identity origin used for `cf auth` |

---

## Pipeline Contract

Each application must include a configuration file at:

```
.pipeline/epic.json
```

This file has two sections:

- **`app`** — Application identity, build configuration, and tooling. Read by the orchestrator and passed as engine template parameters.
- **`cloud`** — Cloud deployment targets and resource configuration. Read at runtime by infra and deploy stages directly from the downloaded source.

---

## Environments — One Contract, Any Environment

Every EPIC run targets a single **environment**, selected at trigger time (the `environment` parameter — `dev`, `test`, `qa`, `uat`, `stage`, `prod`, or `other`). **The same `.pipeline/epic.json` is used for all of them** — you do not maintain a separate config file per environment. This is cloud-agnostic: it applies identically to AWS, Azure, and SAP.

The selected environment flows everywhere it's needed automatically:

- **Terraform state is namespaced by environment.** The state key always includes the environment (`…/{appName}-{appType}/{environment}/terraform.tfstate`), so `dev` and `prod` have completely isolated state from one config.
- **The environment is passed to Terraform** as `-var="environment=<env>"`, so your `.infra` can name and size resources per environment (e.g. `"${var.project_name}-${var.environment}"`).
- **Build tags** record `epicEnvironment.{environment}` for traceability.
- **Approval gates** are environment-aware via `approvalEnvironments` (e.g. `["prod"]`).

### Two ways to configure environment-specific values

Most apps need **no per-environment configuration at all** — a single set of `cloud` values plus the environment-namespaced state is enough, because the `.infra` derives per-env resource names from the `environment` Terraform variable.

When an app genuinely needs *different values per environment* — most commonly because its environments live in **different accounts, subscriptions, or tenants** — use the optional **`cloud.environments`** map. Resolution is always **per-environment override → flat `cloud.*` value → built-in default**, so:

- Apps that omit `cloud.environments` behave exactly as before (fully backward-compatible).
- Apps that use it can key any supported `cloud.*` field by environment.

```jsonc
"cloud": {
  "azureRegion": "westus2",              // flat values apply to every environment…
  "environments": {                       // …unless overridden per environment here
    "dev":  { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-dev"  },
    "qa":   { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-qa"   },
    "uat":  { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-uat"  },
    "prod": { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-prod" }
  }
}
```

### Per-environment Terraform variable overrides (Azure)

Sometimes the values that differ per environment aren't EPIC's own well-known fields (connection, resource group, state) but **your `.infra`'s own Terraform variables** — e.g. per-environment Entra client IDs or security-group object IDs. The industry-standard pattern is *one codebase across all branches, dev defaults committed in `*.auto.tfvars`, and the pipeline injects per-environment overrides at plan/apply* — with no per-branch tfvars divergence. EPIC supports this via an optional **`terraformVars`** map (flat `cloud.terraformVars` and/or per-env `cloud.environments.<env>.terraformVars`):

```jsonc
"cloud": {
  "environments": {
    "dev":  { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-dev" },
    // dev keeps its defaults in the committed .infra/*.auto.tfvars — no override needed
    "qa": {
      "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-qa",
      "terraformVars": {                      // injected as a Terraform -var-file at plan/apply
        "entra_client_id": "…",
        "entra_group_prefix": "MyApp-QA-"
      }
    }
  }
}
```

How it works: the Azure infra stage merges `cloud.terraformVars` (flat) with `cloud.environments.<env>.terraformVars` (per-env wins), writes the result as a Terraform `*.tfvars.json`, and passes it via `-var-file` on `plan`, `apply` (including the staged container-image apply), and `plan -destroy`. Each value keeps its JSON type (string/number/bool/list/object). The `-var-file` is placed **before** EPIC's own managed `-var` flags (`subscription_id`, `tenant_id`, `environment`, `azure_region`, `resource_group_name`), so those can never be overridden by the map. Rules of thumb:

- **NON-SECRET values only.** Secrets belong in Key Vault, never in `epic.json`. Client IDs and group object IDs are not secrets; a client *secret* is.
- **Every key must be a declared `variable` in your `.infra`** — Terraform errors on an override for an undeclared variable.
- **Apps that define no `terraformVars` are completely unaffected** (no file is written; no flag is added).
- Currently implemented for the **Azure** infra path.

### Fail-fast on an unconfigured environment

If an app defines a `cloud.environments` map and a run selects an environment that the map **doesn't** contain (and there's no flat fallback for the field), the orchestrator **fails the run early** with a clear message listing the configured environments — rather than silently falling back to a default that could target the wrong account/tenant. The EPIC web UI reinforces this by restricting the environment dropdown to the environments the selected config actually defines.

---

## Example `epic.json`

### AWS — Angular (S3 + CloudFront)

```json
{
  "app": {
    "appName": "my-app",
    "appType": "angular",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "sonarqube",
    "buildTestTool": "jest"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-app-web-dev",
    "cloudfront": "X9X9X9XX99XX9X"
  }
}
```

### AWS — React (S3 + CloudFront)

```json
{
  "app": {
    "appName": "my-react-app",
    "appType": "react",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "sonarqube",
    "buildTestTool": "jest"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-react-app-web-dev",
    "cloudfront": "X9X9X9XX99XX9X"
  }
}
```

### AWS — React with Playwright Integration Tests

This example uses pre-existing infrastructure (no `.infra/` folder), so the deployed URL is provided via `cloud.appUrl`. When `.infra/` is present, prefer exposing it as a Terraform output named `app_url` instead.

```json
{
  "app": {
    "appName": "my-react-app",
    "appType": "react",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "sonarqube",
    "buildTestTool": "vitest",
    "integrationTestTool": "playwright"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-react-app-web-dev",
    "cloudfront": "X9X9X9XX99XX9X",
    "appUrl": "https://my-react-app-dev.example.com"
  }
}
```

### AWS — Python (EC2 via SSM)

```json
{
  "app": {
    "appName": "my-api",
    "appType": "python",
    "codePath": ".",
    "buildType": "wheel",
    "runtimeVersion": "3.11",
    "scanTool": "sonarqube",
    "buildTestTool": "pytest"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2"
  }
}
```

### AWS — Go (EC2 via SSM)

```json
{
  "app": {
    "appName": "my-go-service",
    "appType": "go",
    "codePath": "/",
    "runtimeVersion": "1.23",
    "scanTool": "sonarqube",
    "buildTestTool": "gotestsum"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-go-service-dev",
    "ec2InstanceId": "i-0123456789abcdef0"
  }
}
```

### AWS — AMI (Image Builder)

```json
{
  "app": {
    "appName": "gis-enterprise-ami",
    "appType": "ami",
    "codePath": "/"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "components": ["webadapter", "portal", "datastore", "server"],
    "imageBuilderPipelinePrefix": "ami-factory",
    "ssmParameterPrefix": "/ami_factory",
    "configDocPrefix": "ConfigDoc",
    "testDocPrefix": "TestDoc",
    "componentDocSuffixes": {
      "webadapter": "arcgiswebadaptor",
      "portal": "arcgisportal",
      "datastore": "arcgisdatastore",
      "server": "arcgisserver"
    },
    "instanceTags": {
      "webadapter": "sor-11-5-arcgis-webadaptor-sandbox",
      "server": "sor-11-5-arcgis-hosting-sandbox",
      "datastore": "sor-11-5-arcgis-datastore-sandbox",
      "portal": "sor-11-5-arcgis-portal-sandbox"
    }
  }
}
```

### AWS — Angular with Wiz Scanning

```json
{
  "app": {
    "appName": "my-secure-app",
    "appType": "angular",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "wiz",
    "scanPolicy": "Default IaC policy",
    "buildTestTool": "jest"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-secure-app-web-dev",
    "cloudfront": "X9X9X9XX99XX9X"
  }
}
```

### Azure — PHP (App Service, single subscription)

The subscription comes from the `Azure` service connection; the resource group applies to every environment (Terraform namespaces state per environment).

```json
{
  "app": {
    "appName": "my-php-app",
    "appType": "php",
    "codePath": "/",
    "runtimeVersion": "8.3"
  },
  "cloud": {
    "azureRegion": "westus2",
    "resourceGroup": "rg-my-app",
    "appServiceName": "my-app"
  }
}
```

### Azure — Infra + Container App (per-environment subscriptions, image build)

An `infra` backend whose non-prod and prod environments live in **different subscriptions** (selected by connection), building its container image during provisioning. The resource group is per environment; the subscription is taken from whichever connection the environment maps to.

```json
{
  "app": {
    "appName": "my-backend",
    "appType": "infra",
    "codePath": "backend",
    "infraPath": "backend/.infra"
  },
  "cloud": {
    "azureRegion": "westus2",
    "environments": {
      "dev":  { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-dev"  },
      "qa":   { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-qa"   },
      "uat":  { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-uat"  },
      "prod": { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-prod" }
    },
    "containerImage": {
      "registryTarget": "module.acr",
      "registryOutput": "container_registry_login_server",
      "imageName": "backend",
      "tagVariable": "backend_image_tag",
      "dockerfile": "Dockerfile",
      "context": "."
    }
  }
}
```

### Azure — React (Storage static website, per-environment)

A code-only frontend (no `.infra` of its own) deployed to a Storage `$web` site, with a distinct storage account per environment.

```json
{
  "app": {
    "appName": "my-frontend",
    "appType": "react",
    "codePath": "frontend",
    "runtimeVersion": "20"
  },
  "cloud": {
    "azureRegion": "westus2",
    "environments": {
      "dev":  { "azureServiceConnection": "MyConn-NonProd", "staticStorageAccount": "myappfedev"  },
      "qa":   { "azureServiceConnection": "MyConn-NonProd", "staticStorageAccount": "myappfeqa"   },
      "uat":  { "azureServiceConnection": "MyConn-Prod",    "staticStorageAccount": "myappfeuat"  },
      "prod": { "azureServiceConnection": "MyConn-Prod",    "staticStorageAccount": "myappfeprod" }
    }
  }
}
```

### Azure — App Service on pre-existing infrastructure (no EPIC-managed infra)

For an app whose infrastructure is **provisioned outside EPIC** (Terraform Cloud, another pipeline, ClickOps) — EPIC only deploys the code. There is no `.infra/` folder, so run with **`terraformAction: none`** (no DeployInfra stage); EPIC skips infra entirely and reads the existing resource identifiers straight from the `cloud` section. This is the Azure counterpart to an AWS app whose infra is managed by TFC.

Because nothing runs DeployInfra, there are no Terraform outputs to resolve from — the `cloud` values below are the **only** source of the deploy target, so they must name resources that already exist. (Resolution is always Terraform outputs → `cloud` fallback; with no infra stage, only the fallback applies.)

```json
{
  "app": {
    "appName": "my-existing-app",
    "appType": "php",
    "codePath": "/",
    "runtimeVersion": "8.3"
  },
  "cloud": {
    "azureRegion": "westus2",
    "environments": {
      "dev":  { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-dev",  "appServiceName": "my-app-dev"  },
      "qa":   { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-qa",   "appServiceName": "my-app-qa"   },
      "uat":  { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-uat",  "appServiceName": "my-app-uat"  },
      "prod": { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-prod", "appServiceName": "my-app-prod" }
    }
  }
}
```

> The deploy stage reads `resourceGroup` + `appServiceName` (App Service) or `staticStorageAccount` (static site) from the `cloud` section — a resource listed under any other field name is silently ignored. If integration tests run against this app, also provide `appUrl` (there is no Terraform `app_url` output to fall back on).

### Azure — Node Function App (`buildType: function`)

A Node app packaged as an Azure Functions v4 bundle and deployed via config-zip. `buildType: function` selects both the Functions packaging in the build stage and the Function deploy target.

```json
{
  "app": {
    "appName": "my-func",
    "appType": "node",
    "codePath": "/",
    "buildType": "function",
    "runtimeVersion": "20"
  },
  "cloud": {
    "azureRegion": "westus2",
    "environments": {
      "dev":  { "azureServiceConnection": "MyConn-NonProd", "resourceGroup": "rg-app-dev",  "appServiceName": "my-func-dev"  },
      "prod": { "azureServiceConnection": "MyConn-Prod",    "resourceGroup": "rg-app-prod", "appServiceName": "my-func-prod" }
    }
  }
}
```

### Azure — React with runtime config (`appConfig`, one build, per-environment)

A single SPA build served to every environment: `cloud.environments.<env>.appConfig` is injected at deploy time as `window.__APP_CONFIG__` in a generated `config.js`. The app loads `/config.js` before its bundle and reads per-environment values (API URL, OIDC IDs) at runtime.

```json
{
  "app": {
    "appName": "my-frontend",
    "appType": "react",
    "codePath": "frontend",
    "runtimeVersion": "20"
  },
  "cloud": {
    "azureRegion": "westus2",
    "environments": {
      "dev":  {
        "azureServiceConnection": "MyConn-NonProd",
        "staticStorageAccount": "myappfedev",
        "appConfig": { "apiUrl": "/api/v1", "oidcClientId": "4e490edc-…", "oidcTenantId": "e2568721-…" }
      },
      "prod": {
        "azureServiceConnection": "MyConn-Prod",
        "staticStorageAccount": "myappfeprod",
        "appConfig": { "apiUrl": "/api/v1", "oidcClientId": "…", "oidcTenantId": "0ec5ddf3-…" }
      }
    }
  }
}
```

### SAP BTP — Infrastructure (`btp`, Terraform provisioning)

```json
{
  "app": {
    "appName": "my-btp-environment",
    "appType": "btp",
    "infraPath": "/my-btp-environment",
    "configPath": "/my-btp-environment/.pipeline"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "secretsManager": {
      "name": "my-secrets-manager-name",
      "keys": ["BTP_USERNAME", "BTP_PASSWORD", "CF_USER", "CF_PASSWORD"]
    }
  }
}
```

### SAP CAP — Application (`cap`, MTA → Cloud Foundry)

Deploys to a pre-existing Cloud Foundry space. Run with Build enabled and Deploy Infrastructure disabled.

```json
{
  "app": {
    "appName": "my-cap-app",
    "appType": "cap",
    "codePath": "/",
    "runtimeVersion": "20",
    "buildTestTool": "jest"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "secretsManager": {
      "name": "my-secrets-manager-name",
      "keys": ["CF_USER", "CF_PASSWORD"]
    },
    "cfApi": "https://api.cf.us10.hana.ondemand.com",
    "cfOrg": "my-cf-org",
    "cfSpace": "dev",
    "cfOrigin": "sap.ids"
  }
}
```

If `/.infra` is present and Terraform outputs include deployment targets (e.g., `bucket_name`, `distribution_id`, `instance_id`, `app_service_name`, `resource_group_name`), those values override the equivalent `cloud` fields automatically.

---

## Contract Parameters

### `app` Section — Application Configuration

| Parameter | Required | Description |
|-----------|----------|-------------|
| `appName` | Yes | Logical application name. Alphanumeric, hyphens, or underscores. No spaces. |
| `appType` | Yes | Determines build and deploy implementation. See allowed values below. |
| `codePath` | Yes | Relative path from repo root to application source (e.g., `/`, `.`, `/src`). |
| `infraPath` | No | Relative path to infrastructure directory (defaults to `.infra`). |
| `buildType` | No | Defines packaging behavior. Omit for standard build. `function` packages a `node` app as an Azure Functions v4 bundle and routes deploy to the Azure Function target. |
| `runtimeVersion` | No | Runtime version override (e.g., `"20"` for Node, `"10.x"` for .NET). If omitted, engine default is used. |
| `approvalEnvironments` | No | Array of environment names that require manual approval before deploy (e.g., `["prod"]`). |

**`appType` allowed values:**

`appType` selects the **build** implementation and how the deploy stage packages the app. The actual **cloud is determined by the `cloud` section** (`awsAccountId` → AWS, an Azure service connection → Azure, `btp`/`cap` → SAP), not by the appType — the "Typical Cloud" column below is just the most common pairing. For example `angular`/`react`/`html` deploy to S3 + CloudFront on AWS or to a Storage `$web` site on Azure, depending on the `cloud` section.

| Value | Typical Cloud | Description |
|-------|---------------|-------------|
| `ami` | AWS | AMI factory (EC2 Image Builder + SSM) |
| `angular` | AWS / Azure | Angular frontend (AWS S3+CloudFront, or Azure Storage `$web`) |
| `react` | AWS / Azure | React frontend — CRA, Vite, Next.js static (AWS S3+CloudFront, or Azure Storage `$web`) |
| `html` | AWS / Azure | Static HTML (AWS S3+CloudFront, or Azure Storage `$web`) |
| `dotnet` | AWS | .NET Core / .NET 6+ application |
| `dotnet_framework` | AWS | .NET Framework application |
| `go` | AWS | Go application (static binary on EC2 via SSM) |
| `java` | AWS | Java application |
| `node` | Azure | Generic Node app (App Service zip, or Azure Functions v4 with `buildType: function`) |
| `php` | Azure | PHP application (App Service) |
| `python` | AWS | Python application |
| `btp` | SAP | SAP BTP infrastructure provisioning (Terraform; runs DeployInfra stage only — disable Build and Deploy toggles) |
| `cap` | SAP | SAP CAP application — builds an MTA archive and deploys it to a pre-existing Cloud Foundry space |
| `infra` | AWS / Azure | Infrastructure-only Terraform provisioning (no app build/deploy — runs DeployInfra stage only; disable Build and Deploy toggles) |

### `app` Section — Tool Configuration

| Parameter | Description | Allowed Values |
|-----------|-------------|----------------|
| `scanTool` | Scan tool to execute | `sonarqube`, `wiz`, omit to skip |
| `scanPolicy` | Wiz policy name to evaluate against | Any valid Wiz policy name (required when `scanTool` is `wiz`) |
| `buildTestTool` | Build test framework | `jest`, `karma`, `vitest`, `junit`, `phpunit`, `pytest`, `xunit`, `gotestsum`, omit to skip |
| `integrationTestTool` | Integration test framework | `playwright`, omit to skip |

---

### `cloud` Section — AWS Deployment Parameters

#### Required

These parameters are always required for AWS deployments. They are used for authentication (STS role assumption) and backend configuration — they cannot be derived from Terraform outputs.

| Parameter | Description |
|-----------|-------------|
| `awsAccountId` | Target AWS account ID (12 digits) |
| `awsRegion` | AWS region (defaults to `us-west-2`) |

#### Required if `.infra/` is not present (by `appType`)

These parameters identify pre-existing infrastructure resources. If `/.infra` is present, EPIC resolves them from Terraform outputs automatically and these can be omitted.

| `appType` | Required Parameters |
|-----------|---------------------|
| `html`, `angular`, `react` | `s3`, `cloudfront` |
| `dotnet` | `s3`, `ec2InstanceId`, `appExecutable` |
| `java` | `s3`, `ec2InstanceId` |
| `python` | `s3`, `ec2InstanceId`, (optional) `appExecutable` |
| `go` | `s3`, `ec2InstanceId`, (optional) `appExecutable` |

| Parameter | Description |
|-----------|-------------|
| `s3` | Target S3 bucket name (used for static hosting or deployment artifact staging) |
| `cloudfront` | CloudFront distribution ID for cache invalidation |
| `ec2InstanceId` | EC2 instance ID targeted via SSM for deployment |
| `appExecutable` | Name of the executable to launch after deploy |
| `appUrl` | Deployed application URL. Used by integration tests as `BASE_URL` when no Terraform `app_url` output is available. Required when `integrationTestTool` is set and `.infra/` is absent. |

#### Required when `appType` is `ami`.

| Parameter | Description |
|-----------|-------------|
| `components` | Array of component names to build/deploy |
| `imageBuilderPipelinePrefix` | Prefix for Image Builder pipeline ARNs (default: `ami-factory`) |
| `ssmParameterPrefix` | SSM Parameter Store prefix for AMI IDs (default: `/ami_factory`) |
| `configDocPrefix` | SSM document prefix for configuration (optional, deploy only) |
| `testDocPrefix` | SSM document prefix for testing (optional, deploy only) |
| `componentDocSuffixes` | Object mapping component names to SSM document suffixes (optional — defaults to component name) |
| `instanceTags` | Object mapping component names to EC2 Name tags (optional, deploy only) |

### `cloud` Section — Azure Deployment Parameters

Azure is selected when `epic.json` provides an Azure **service connection** (flat or per-environment) — the connection is what identifies Azure, and the **target subscription is taken from the connection** (`epic.json` does not restate a subscription ID). Any of the fields below may be set flat (applies to every environment) or overridden per environment under `cloud.environments.<env>` (see [Environments](#environments--one-contract-any-environment)).

| Parameter | Description |
|-----------|-------------|
| `azureServiceConnection` | Name of the ADO Azure service connection to authenticate with. Defaults to `Azure`. Set this (or the per-environment form) to target a non-default subscription/tenant. |
| `azureRegion` | Azure region (defaults to `westus2`) |
| `resourceGroup` | Target resource group. Passed to Terraform as `resource_group_name`; when omitted the `.infra` default applies. (Legacy flat alias: `resourceGroupName`.) |
| `appServiceName` | Target App Service name (App Service deploys) |
| `staticStorageAccount` | Target Storage account for static-site (`html`/`angular`/`react`) deploys. Overridden by a Terraform `frontend_storage_account` output when present. |
| `appConfig` | JSON object injected at static-site deploy time as `window.__APP_CONFIG__` in a generated `config.js` (runtime config for one-build-any-environment SPAs). Typically set per-environment. See [Runtime config.js injection](#runtime-configjs-injection-static-spa-deploys). |
| `appUrl` | Deployed application URL. Used by integration tests as `BASE_URL` when no Terraform `app_url` output is available. Required when `integrationTestTool` is set and `.infra/` is absent. |

#### State backend overrides (optional)

By default, Terraform state follows the per-subscription convention (`epictfstate{first-8-of-subscription-id}` in `rg-epic-tfstate`, container `tfstate`) — one shared state account per subscription. Override any of the following, flat or per-environment:

| Parameter | Description |
|-----------|-------------|
| `stateStorageAccount` | Override the derived state storage account name |
| `stateResourceGroup` | Override the state resource group (default `rg-epic-tfstate`) |
| `stateContainer` | Override the state container (default `tfstate`) |
| `bootstrapState` | `true` = the infra stage **creates** the state RG + account + container on the first run and no-ops thereafter (idempotent; first run == 100th run). Default `false` = the account must already exist (created out of band). Self-bootstrap needs the SPN to have control-plane rights on the state RG (creating a storage account); the pre-created model needs only data-plane (`Storage Blob Data Contributor`). The state storage is managed imperatively — it is where Terraform state lives, so it is not itself in Terraform state. |

##### Recommended pattern — co-locate state in the app's environment RG

Instead of a shared `rg-epic-tfstate`, point `stateResourceGroup` at the **same RG the app deploys into** (`resourceGroup`), with a per-environment state account name. This is the **recommended pattern**, especially for prod-sensitive orgs:

```jsonc
"prod": {
  "azureServiceConnection": "MyConn-Prod",
  "resourceGroup":       "rg-app-prod",
  "stateResourceGroup":  "rg-app-prod",        // state lives with the app
  "stateStorageAccount": "myapptfstateprod"    // per-env, globally-unique, <=24 lc-alphanumeric
}
```

**Why it's preferred:**
- **Least privilege** — the SPN already has Contributor on the app's env RG (it provisions the app there), so with `bootstrapState: true` it creates the state account inside a RG it already owns. **No subscription-scoped Contributor and no RG-creation right are needed** — the env RG is assumed to pre-exist (the `.infra` reads it as a data source), so the bootstrap step skips group creation and only creates the storage account.
- **Blast-radius isolation** — one state account per app-environment rather than a shared account for the whole subscription.

**When NOT to co-locate:** only when the app's `.infra` **creates/destroys its own RG** (rather than reading a pre-existing one). In that case a `terraform destroy` could delete the RG — and its state account — out from under itself; keep state in a separate `rg-epic-tfstate` for those apps. EPIC's built-in default stays `rg-epic-tfstate` precisely to protect that case, so co-location is always an explicit per-app choice.

#### Container image build (optional — `cloud.containerImage`)

Present this block to have the infra stage build + push the app's container image during provisioning (staged apply). All fields come from `epic.json`:

| Field | Description |
|-------|-------------|
| `registryTarget` | Terraform address of the container registry resource to apply first (e.g. `module.acr`) |
| `registryOutput` | Terraform output name that returns the registry login server |
| `imageName` | Image repository name |
| `tagVariable` | Terraform variable the built image tag is passed into |
| `dockerfile` | Dockerfile path (default `Dockerfile`) |
| `context` | Build context relative to `codePath` (default `.`) |
| `target` | Optional Docker build target stage |

#### Per-environment map (optional — `cloud.environments`)

Keys any of the above `cloud.*` fields by environment (`dev`/`test`/`qa`/`uat`/`stage`/`prod`). Used when environments live in different subscriptions/tenants. See [Environments](#environments--one-contract-any-environment). If a run selects an environment absent from this map (with no flat fallback), the orchestrator fails fast.

### `cloud` Section — SAP Parameters

Required when `appType` is `btp` or `cap`. SAP/CF credentials are stored in AWS Secrets Manager and retrieved at runtime (by the infrastructure stage for `btp`, by the deploy stage for `cap`).

| Parameter | `btp` | `cap` | Description |
|-----------|-------|-------|-------------|
| `awsAccountId` | Yes | Yes | AWS account ID where SAP/CF secrets are stored |
| `awsRegion` | No | No | AWS region for Secrets Manager (defaults to `us-west-2`) |
| `secretsManager.name` | Yes | Yes | Name of the AWS Secrets Manager secret containing SAP/CF credentials |
| `secretsManager.keys` | Yes | Yes | Array of keys to retrieve from the secret (e.g., `["BTP_USERNAME", "BTP_PASSWORD", "CF_USER", "CF_PASSWORD"]`) |
| `cfApi` | — | Yes | Cloud Foundry API endpoint (e.g., `https://api.cf.us10.hana.ondemand.com`) |
| `cfOrg` | — | Yes | Target Cloud Foundry org |
| `cfSpace` | — | Yes | Target Cloud Foundry space |
| `cfOrigin` | — | Yes | Identity origin used for `cf auth` (e.g., `sap.ids`) |

---

## Parameter Categories Summary

| Category | Section | Required | Parameters |
|----------|---------|----------|------------|
| Application Identity | `app` | Yes | `appName`, `appType`, `codePath` |
| Infrastructure | `app` | Optional | `infraPath` |
| Packaging | `app` | Optional | `buildType` |
| Runtime Version | `app` | Optional | `runtimeVersion` |
| Approval Gates | `app` | Optional | `approvalEnvironments` |
| Scanning | `app` | Optional | `scanTool`, `scanPolicy` |
| Build Testing | `app` | Optional | `buildTestTool` |
| Integration Testing | `app` | Optional | `integrationTestTool` |
| AWS Deployment | `cloud` | Conditional | `awsAccountId`, `awsRegion`, `s3`, `cloudfront`, `ec2InstanceId`, `appExecutable`, `appUrl` |
| AMI Configuration | `cloud` | Conditional | `components`, `imageBuilderPipelinePrefix`, `ssmParameterPrefix`, `configDocPrefix`, `testDocPrefix`, `componentDocSuffixes`, `instanceTags` |
| Azure Deployment | `cloud` | Conditional | `azureServiceConnection`, `azureRegion`, `resourceGroup`, `appServiceName`, `staticStorageAccount`, `appConfig`, `appUrl`, (state) `stateStorageAccount`/`stateResourceGroup`/`stateContainer`/`bootstrapState`, (image) `containerImage.*` |
| Per-Environment | `cloud` | Optional | `environments.<env>.*` — any `cloud.*` field, keyed by environment |
| SAP | `cloud` | Conditional | `awsAccountId`, `awsRegion`, `secretsManager.name`, `secretsManager.keys`, (`cap` only) `cfApi`, `cfOrg`, `cfSpace`, `cfOrigin` |

---

## Validation Rules

EPIC enforces validation at runtime:

- Missing required fields fail early with a clear error
- Unsupported `appType`, `scanTool`, or `buildTestTool` values fail during stage dispatch
- `runtimeVersion` defaults to the engine's `defaultRuntimeVersion` per appType if omitted
- Deployment parameters are validated only when the deploy stage executes
- If `/.infra` is present, Terraform outputs are validated before the deploy stage runs
- Cloud provider is auto-detected from `epic.json` (`appType: "btp"` or `"cap"` = SAP, then `awsAccountId` = AWS, then an Azure service connection — flat or per-environment `azureServiceConnection`, or a legacy `azureSubscriptionId` — = Azure)
- If a `cloud.environments` map is present and the selected environment is not in it (and no flat fallback exists), the run fails fast rather than defaulting to the wrong target

---

## Extending EPIC

To add support for a new build type, test framework, or scanner:

1. Create a new folder under the appropriate stage directory
2. Implement the YAML template following the existing conventions
3. Register it in the stage dispatcher (`main.yml`) using the `${{ if eq(...) }}` pattern

To add a new deploy target:

1. Create a template under `deploy/aws/` or `deploy/azure/`
2. Add a routing conditional in `deploy/main.yml`

To add a new runtime version default:

1. Add a `${{ elseif }}` clause to the `defaultRuntimeVersion` variable in `epic-engine.yml`

No changes to `epic-orchestrator.yml` are required for any of the above.

---

## Summary

EPIC provides a standardized CI/CD backbone for enterprise application delivery across AWS, Azure, and SAP.

It separates:

- **Application configuration** (`app` section — identity, tooling, build intent)
- **Cloud deployment** (`cloud` section — targets, credentials, resources)
- **Infrastructure provisioning** (`/.infra` + Terraform)
- **Orchestration logic** (engine + orchestrator)

This keeps pipelines clean, scalable, and governable across teams.
