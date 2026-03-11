# EPIC Pipeline - DevSecOps Coverage & Gap Analysis

## Directly Addressed by EPIC

### Federated Identity Model (Azure DevOps + AWS)
EPIC establishes and enforces the federated identity model between Azure DevOps and AWS using OIDC-based service connections. No long-lived credentials. IAM role assumption is scoped per environment and governed through pipeline policy.

### Reusable Azure DevOps Pipeline Templates (YAML)
The entire EPIC framework is built on parameterized, reusable YAML templates. Teams onboard by referencing EPIC templates - they don't own pipeline logic. This is the core delivery mechanism.

### Build, Test, Security Scan, Deploy to AWS
EPIC owns the full CI/CD lifecycle:
- Build and unit test stages with enforced pass gates
- Security scanning integrated as non-bypassable pipeline stages
- Deployment to AWS via scoped service connections and Terraform-driven provisioning

### Tool Integration (JFrog, SonarQube, Wiz, GitHub, Service Connections, Secrets Handling, Policy Enforcement)
EPIC wires these tools into the pipeline as first-class stages:
- **JFrog Artifactory** - artifact storage, promotion, and provenance
- **SonarQube** - SAST and code quality gates
- **Wiz** - IaC and container security scanning
- **GitHub** - source integration and PR-triggered pipeline execution
- **Service Connections** - managed centrally by CCoE, scoped per environment
- **Secrets Handling** - ADO Secrets Library (as needed); no plaintext secrets in pipeline YAML
- **Policy Enforcement** - branch policies, required reviewers, and pipeline gate conditions tied to scan results

### Consistent Security Gates
EPIC enforces uniform security gates across all pipelines that use the templates. Gate conditions are centrally defined - individual teams cannot override them without CCoE approval.

### SAST / SCA / IaC Scanning
- SAST via SonarQube (integrated at build stage)
- SCA via dependency scanning (JFrog Xray or equivalent)
- IaC scanning via Wiz, triggered on Terraform plan output before apply

### Policy-Based Fail Conditions
Pipeline execution halts on defined policy violations. Fail conditions are codified in template logic - not left to team discretion. High/critical findings block promotion by default.

### Artifact Lifecycle Standards
JFrog Artifactory manages artifact storage and lifecycle. EPIC defines:
- Naming conventions
- Immutable artifact tagging post-promotion
- Repository structure per environment tier (dev/staging/prod)

### Promotion Rules
Promotion between environments is gate-driven. No manual artifact copying. Promotion requires passing all scan gates and, for production, explicit approval.

### Retention and Provenance
- Pipeline run history retained per ADO retention policy (configurable per project)
- Artifact provenance tracked through JFrog metadata - build ID, commit SHA, pipeline run linked at publish time

---

## Outside EPIC - But Relevant

### Environment Onboarding (New AWS Accounts Auto-Wired to Azure DevOps)
EPIC assumes accounts are already onboarded. Automating the account-to-ADO wiring - service connection provisioning, IAM role bootstrapping, variable group creation - is a CCoE platform engineering concern that sits upstream of EPIC. A Terraform-based onboarding module or ADO API automation is needed here.

### Observability Hooks (Pipeline Telemetry, Deployment Traceability)
EPIC emits standard ADO pipeline logs and artifacts, but structured telemetry (e.g., feeding pipeline events into a monitoring tool) is not natively part of EPIC. This requires a telemetry sidecar pattern or ADO service hook configuration pushing to an observability platform - owned by CCoE platform ops, not the pipeline framework itself.

### Run Model (Who Supports Failed Pipelines? Who Owns Platform SLAs?)
This is an operational governance question, not a pipeline engineering question. EPIC is the platform - the run model defines who supports it. CCoE needs to publish:
- Tier 1 triage ownership (app team vs. CCoE)
- Escalation path for EPIC template failures vs. app-specific failures
- SLA definitions for pipeline availability and incident response

### Compliance Evidence
EPIC generates the raw material - logs, scan results, approval records - but packaging that into compliance evidence (e.g., for NERC CIP, SOX, or internal audit) requires a reporting layer. This could be a scheduled export from ADO + JFrog + Wiz into a compliance dashboard or artifact store. Outside EPIC scope but dependent on EPIC outputs.

### Audit-Ready Logs Across Azure DevOps + AWS
ADO audit logs and AWS CloudTrail both exist, but correlating them into a unified audit trail is outside pipeline scope. This is a CCoE observability/compliance engineering effort - likely involving a log aggregation pipeline (e.g., CloudTrail -> S3 -> Splunk/Sentinel, combined with ADO audit log export).