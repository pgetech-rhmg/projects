# EPIC Peer Review — Meeting Talking Points

---

## Slide 7 — High-Level Architecture Diagram  *(20 minutes)*

**Goal:** walk the room left-to-right through each lane, then close with the cross-lane flows. Pause for questions at each lane boundary.

### Opening framing (~1 min)
- "What you're looking at is four vertical lanes, left to right: the EPIC Interface, GitHub as our source of truth, Azure DevOps as the CI/CD control plane, and the multi-cloud workload targets."
- "The strip across the bottom is centralized quality and security services that any stage can call into."

---

### Lane 1 — EPIC Interface  *(~4 min)*

**This lane runs in our PG&E EPIC AWS account (`514712703977`, us-west-2). Everything here is internal-only.**

- **epic-web** — Angular 20 SPA. Hosted on **S3 + CloudFront** behind a WAFv2 IP allow-list (PG&E corporate egress IPs only). DNS is a private Route 53 alias, so it's only reachable from the corporate network. No server-side runtime.

- **epic-api** — .NET 10 REST API. Runs on **EC2 with systemd on port 5000** (not Beanstalk, not Lambda — straightforward EC2 because the workload is light and we want full control). Sits behind an **internal ALB** that only accepts ingress from PG&E corporate CIDRs.
  - Two security group chain: **SG-WEB → SG-API**. The API security group only accepts traffic on 5000 from SG-WEB — by SG ID, not by CIDR. There is no path to the API from outside the ALB.
  - Instance profile is least-privilege: `S3-ReadOnly` + a scoped Secrets Manager read policy + a single-ARN read for the RDS master secret.

- **Aurora PostgreSQL Serverless v2** (engine 16.11). Storage encrypted at rest. **`manage_master_user_password = true`** — RDS owns and rotates the master credential in Secrets Manager, our app never sees it directly. Deletion protection on prod. Ingress on 5432 only from SG-API.

- **AWS Secrets Manager** holds the appsettings: `GITHUB_BASE_URL`, `GITHUB_TOKEN`, `ADO_PAT`. Plus the auto-merged `AWS_RDS_SECRET_ARN` and `AWS_RDS_ENDPOINT` from the Aurora module.

- **Networking** — VPC `vpc-8c57a5f4` with three subnets, all CCOE-managed. EPIC consumes the VPC ID and subnet IDs as inputs; we don't define networking in our Terraform.

---

### Lane 2 — Source of Truth (GitHub)  *(~4 min)*

**Everything that runs in EPIC is sourced from `github.com/pgetech`. That's the immutable record.**

- **Application repositories** — N teams, each with their own repo. Two things matter for EPIC: a `.pipeline/epic.json` contract and an optional `.infra/` Terraform tree. Source code lives wherever the team puts it; `epic.json` tells us where via `codePath`.
  - The `epic.json` keys we actually consume: `app.{appName, appType, codePath, infraPath, runtimeVersion, scanTool, buildTestTool, integrationTestTool, approvalEnvironments}` and `cloud.{aws|azure|btp specifics}`.
  - **Branch protection** is on every protected branch — required reviews, status checks, linear history. CodeQL, secret scanning with push protection, and Dependabot are all on. CODEOWNERS gates the sensitive paths like `.pipeline/` and `.infra/`.

- **epic-pipeline** — one repo. Holds the orchestrator YAML, the engine YAML, and every reusable stage template — `build/`, `test/`, `scan/`, `infra/`, `deploy/`. App teams don't fork this; they consume it. **This is the architectural lever** that lets us guarantee consistent controls — there's no opt-out path.

- **Terraform Modules** — `pgetech/epic-pipeline-module-aws-…` repos, consumed via `git::https://...?ref=main`. Modules carry the security defaults: IAM policies, security groups, S3 public-access blocks, ACM, the tagging schema. App teams pick from a vetted catalog rather than hand-rolling primitives.

- **Auth path** — For the POC, EPIC authenticates to GitHub with a PAT in the ADO library group. That works, it's secure, but it's user-bound. Obviously, long-term it needs to move to a GitHub App: org-owned identity, one-hour installation tokens scoped per repo, no human dependency. Same security model we already use for AWS — short-lived credentials, no static keys.

---

### Lane 3 — CI/CD Control Plane (Azure DevOps)  *(~5 min)*

**This is where the run actually happens. It's our CI/CD Control Plane.**

- **Orchestrator** *(pipelineId 194)* — the entry point. Runs on a Microsoft-hosted agent `ubuntu-latest`. Validates the run parameters, clones the app repo, reads `epic.json`, builds a JSON payload via `jq`, then POSTs to `/_apis/pipelines/194/runs` to invoke the engine. Tags the orchestrator build with `epicRepo` and `epicAppName` — first audit hop.

- **Engine** — the actual build/deploy pipeline. Runs on `ubuntu-latest` by default. Receives the templated parameters from the orchestrator and dispatches stages based on `appType` and `cloudProvider`.
  - **Builds tags every Engine run** with five values: `epicRepo`, `epicAppName`, `epicAppType`, `epicEnvironment`, `epicCloud`. That's the audit trail surfaced in the EPIC dashboard and queryable via ADO REST.
  - **Stages are templates the engine includes conditionally.** Teams can't inject custom YAML — they declare intent in `epic.json` and run params; the engine decides what runs.

- **Agent pools** — three:
  - **Microsoft-hosted `ubuntu-latest`** — default for build, test, deploy, infra. Ephemeral VM per job, no persistent state.
  - **Microsoft-hosted `windows-latest`** — .NET builds when SonarQube isn't involved.
  - **`EPIC - Self-hosted`** — only for Wiz and SonarQube scan steps that need PG&E network reach. We avoid using self-hosted by default — Microsoft-hosted is more secure and lower-maintenance.

- **8-stage flow** — Download → Build → Build Tests → Scan → Infra → Approval → Deploy → Integration Tests.
  - Stages are skipped or required by the contract. A static SPA skips Infra. A `dev` deploy skips Approval. A pure infra change can skip Build entirely.
  - **Stage 4 — Scan** — mandatory if `scanTool` is set - in the epic.json contract file - or there's a defined environment requirement (e.g., PROD).
  - **Stage 5 — Infra** — Terraform with state in our S3 bucket plus DynamoDB lock. State is never stored locally on the agent.
  - **Stage 6 — Approval** — `ManualValidation@0` task. Inserted automatically when the target environment is in the `approvalEnvironments[]` list.  
  **This is the Separation of Duties gate I called out as a non-functional requirement on slide 6.**
  - **Stage 7 — Deploy** — assumes a short-lived role into the target cloud. No long-lived credentials anywhere.
  - **Stage 8 — Integration Testing** — mandatory if `integrationTestTool` is set - in the epic.json contract file.

---

### Lane 4 — Multi-Cloud Workloads  *(~4 min)*

**Three sub-zones defined at the moment — AWS, Azure, BTP. Each has its own trust model. Azure-Local will be the next workload.**

- **AWS workload accounts** *(per app, per environment)*
  - Engine assumes `arn:aws:iam::{cloud.awsAccountId}:role/pge-epic-deployment-role` via the ADO `AWS` service connection.  
  *Note: There will be a one-time deployment of this role into any AWS Account that EPIC needs to deploy to. It allows ADO to deploy via the ADO `AWS` service connection.*
  - Session name is `PGE-EPIC-DEPLOY-ADO-{BuildId}` — every CloudTrail event traces back to a specific build run.
  - Three deploy patterns from the contract at the moment: `static` (S3 + CloudFront — for HTML / Angular / React), `ec2` (S3 upload + SSM RunShellScript — for .NET / Java / Python), `ami` (Image Builder). These were for the POC. We build out as needed/when needed for additional patterns.

- **Azure workload subscriptions** *(per app, per environment)*
  - ADO Service Connection backed by an Azure AD Service Principal scoped to `cloud.azureSubscriptionId` defined in the epic.json contract file.
  - Single `app-service` template handles every app type — Resource Group and App Service name come from the contract.
  - Functions, Key Vault, SQL DB, Storage all available as TF modules when an app needs them for infrastructure deploys.

- **SAP BTP subaccounts + Cloud Foundry**
  - Provider auth credentials (`BTP_USERNAME`, `BTP_PASSWORD`, `CF_USER`, `CF_PASSWORD`) are pulled from AWS Secrets Manager — the secret name and key list come from the `epic.json` (`cloud.secretsManager.name` + `.keys[]`) contract file.
  - Credentials are written to a temp env file sourced by the Terraform/CF steps, never echoed.
  - Pipeline runs `terraform init / fmt / validate / test / plan / apply` for infrastructure, then `cf push` for the app tier.

---

### Bottom strip — Centralized Quality & Security  *(~1 min)*

**These are SaaS endpoints any stage can call into. Tokens come from Secrets Manager / ADO library — never in repo.**

- **Wiz** — CSPM and IaC scanning. Mandatory when `scanTool=wiz`. Self-hosted pool only.
- **SonarQube** — SAST and quality gates. Coverage is normalized for .NET runs.
- **JFrog Xray** — SCA and artifact registry, where used.
- **GitHub Advanced Security** — branch protection, CodeQL, secret scanning, Dependabot — already covered in Lane 2.
- **ADO Manual Validation** — the approval gate from Lane 3.
- **ADO Build Tags** — the audit trail.
- **CloudWatch + ADO Logs** — single observability surface, every run, every cloud.

---

### Cross-lane flow walkthrough  *(~2 min)*

**Trace one run end-to-end so the room sees the lanes connect:**

1. **Trigger** — engineer clicks "Deploy to dev" in epic-web → epic-api receives REST call (`X-Epic-User` header, ALB on 443) → epic-api reads target repo's `epic.json` from GitHub → epic-api POSTs to ADO REST to start the orchestrator.
2. **Orchestrator** clones the app repo, builds the payload, invokes the engine via REST.
3. **Engine** runs the stage flow on Microsoft-hosted agents. Scan stage hits the bottom strip. If env is in `approvalEnvironments[]`, run pauses at the gate.
4. **Deploy** assumes `pge-epic-deployment-role` in the target AWS account and runs the deploy template — `s3 sync` for static, `ssm send-command` for EC2.
5. **Tags** are written to the engine build via the ADO REST `PUT /_apis/build/builds/{id}/tags` call.
6. **Status** flows back: epic-api polls ADO for run status, epic-web auto-refreshes the dashboard.

### Closing  *(~30 sec)*
- "That's the picture. Universal control plane, multi-cloud reach, every run audited and gated."
