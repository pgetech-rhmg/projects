# EPIC Peer Review — Meeting Talking Points

---

## Slide 6 — Key Requirements Impacting the Design  *(5 minutes)*

**Goal:** establish *why* the architecture looks the way it does — frame the requirements that left us with no real choice.

### Opening (~30 sec)
- "Before I walk through the diagram, I want to anchor the room on the requirements that actually drove the architecture. Most of the design decisions you'll see on the slide come straight out of these ten bullets."
- "Five functional, five non-functional. These aren't all the requirements, just the ones that materially shaped what got built."

### Functional Requirements (~2 min — ~25 sec each)

1. **Universal Pipeline**
   - "PG&E is a regulated utility. We can't have every app team writing their own YAML, picking their own scanners, and managing their own deploy scripts — there's no way to prove consistent controls across that footprint."
   - "Making it a universal (or centralized) isn't a preference, it's a compliance posture. One framework, one set of guardrails, every app."

2. **Single contract per app**
   - "Every app onboards by dropping a `.pipeline/epic.json` into their repo. That contract drives the entire run — which stages execute, which scanners run, which environments need approvals, where infrastructure gets provisioned."
   - "Teams describe *what* they need; the engine decides *how* to do it."

3. **Multi-cloud deployment**
   - "Workloads run in AWS, Azure, Azure Local, and SAP BTP. The pipeline auto-detects which cloud from `cloud.*` in the contract and dispatches accordingly."
   - "App teams don't learn cloud-specific deploy mechanics — they just declare the target."

4. **Self-service runs + automated CI**
   - "Two trigger paths. Engineers can kick a run from the EPIC dashboard for ad-hoc deploys, and PR merges to tracked branches kick off CI automatically. Same engine, same controls, both paths."

5. **Per-app, per-environment infrastructure - for apps that use EPIC for infrastructure deploys**
   - "TFC is currently the in-house solution for infrastrucutre deploys, but EPIC has built-in capabilities that don't require addtional layers or costs that are associated with TFC."
   - "Each app owns a `.infra/` Terraform tree, but the modules they consume are versioned and centrally maintained in our Github — `pgetech/epic-pipeline-modules`. Security defaults — IAM, security groups, encryption, tagging — are baked into the modules, not hand-rolled by each team."

### Non-Functional Requirements (~2 min — ~25 sec each)

1. **Security**
   - "Mandatory Wiz and SonarQube scans. All credentials live in AWS Secrets Manager — nothing in repo, nothing in pipeline variables. No long-lived cloud keys on agents; AWS uses STS AssumeRole at run time."

2. **Auditability / FinOps**
   - "Every Engine build is tagged with five values: repo, app name, app type, environment, cloud. That gives us a clean audit trail surfaced in the EPIC dashboard and in ADO's REST API — no spelunking through logs to answer 'what got deployed where, when, and by whom.'"
   - "These tags - or additional tags - can be used for cost management as well.'"

3. **Governance & Separation of Duties**
   - "Production deploys pause at a `ManualValidation@0` gate. The engine inserts the gate automatically when the target environment is in the app's `approvalEnvironments[]` list — so dev runs flow straight through, but prod always requires a human approver who isn't the committer."

4. **Maintainability**
   - "When we patch the pipeline, we patch one repo. Every app team gets the fix on their next run — they don't have to merge anything into their own pipelines."

5. **Network compliance**
   - "Internal-only ALB with PG&E corporate CIDR ingress. The VPC, subnets, and routing are owned by CCOE and consumed by EPIC as inputs — we don't define networking in our Terraform, we conform to theirs."

### Closing (~30 sec)
- "Every one of these is a constraint, not a feature wish. The architecture you'll see is essentially the minimum viable shape that satisfies all of them simultaneously."
