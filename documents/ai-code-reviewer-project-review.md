# Project Review — `projects/ai-code-reviewer/`

**Reviewed:** 2026-07-09
**Repo:** `projects/ai-code-reviewer/` (package `code-scanner` v2.0.0)
**Purpose of this review:** Assess the prior AI code-review tool as a candidate to slot into the EPIC pipeline (between `download` and `build`), and document the challenges and gaps that led to building the purpose-built `epic-compliance` gate instead.

---

## Executive summary

`ai-code-reviewer` is a **working prototype of an LLM-driven code scanner** with genuine engineering depth in its analysis engine — multi-pass security scanning, checkpoint/resume, batching, and a rich analyst dashboard. But it was built as a **standalone analyst tool, not a CI gate.** The layer that would let a pipeline actually *use* it — a distributable artifact, exit-code gating, machine-readable output, cost control — is effectively 0% complete.

**Bottom line:** the scanner engine is real and polished; the CI-integration layer is missing entirely. Every gap is technically fillable with adapters, but the sum of them makes a clean, purpose-built tool a shorter path than retrofitting this one. It is kept as **reference prior art**, not a base to extend. This directly informed the design of the EPIC Compliance Reviewer (`epic-compliance`), which was built to be a CI gate first.

---

## What the project is

Four subdirectories at wildly different maturity levels:

| Subdir | LOC / size | Maturity | Role |
|--------|-----------|----------|------|
| **Application-Codebase/** | ~6,900 LOC (TS, `src/`) | **Working prototype** | The actual product: a CLI scanner + a Fastify REST API with GitHub webhooks and SQLite persistence. |
| **web-ui/** | ~5,500 LOC (TS) | Working prototype | d3 force-graph dashboard, PDF report generator, and a "DevAsk" LLM Q&A server. An analyst/report-viewer UI, **not a pipeline component**. |
| **infra/** | 4 files, no code | **0% — empty scaffold** | `cdk.json` + `package.json` with `REPLACE_WITH_PGE_ACCOUNT_ID` placeholders. No `bin/`, no `lib/`, no stack code. |
| **demo-tests/** | 1 file | N/A | A Playwright script for **recording a walkthrough video** — not a test suite. |

Loose files at the repo root reinforce that this is a personal working project, not a productized tool:
- `CryptoKeyCompromiseTests.cls` — sample Salesforce Apex **input** to feed the scanner, not part of the tool.
- `find_easy.py` — the author's throwaway triage helper.
- `AIDLC_PGE_Deployment_Flow.drawio` — a diagram.
- Root `package.json` is only a Playwright demo wrapper.

> Note: a `.pipeline/epic.json` was recently added (pointing `codePath` at `web-ui`, `appType: node`), reflecting an attempt to onboard the repo *as an EPIC workload* — separate from the tool's own readiness to *be* an EPIC stage.

---

## How it "reviews code"

**Pure-LLM. No static analysis, no rule engine, no AST work.** Every verdict comes from a model call. Two separate pipelines:

1. **Security scan** (`src/ai/pipeline.ts`) — 5 sequential passes per file:
   comprehension → flow-tracing → detection (6 categories: access-control, injection, XSS, CSRF, open-redirect, secrets) → verification → remediation.
2. **Code review** (`src/review/code-review-pipeline.ts`) — a separate "Pass 6" for code quality / architecture / best-practices / maintainability.

**Model:** Claude **Sonnet 4.5 via AWS Bedrock, routed through PG&E's Portkey gateway** (`aws-ai-gateway.nonprod.pge.com`). Requires `PORTKEY_API_KEY`, `PORTKEY_BASE_URL`, `BEDROCK_MODEL` — it refuses to start without them.

**Engineering depth that is genuinely good:**
- Batching + rate-limiting (`src/ai/batch-processor.ts`).
- Disk checkpointing with **resume-from-crash** (`src/ai/checkpoint.ts`).
- Incremental scanning — but only in the **API + SQLite** path, not the CLI.

The cost of the design: **every file gets 4+ LLM calls**, and security + review are **two separate runs**, doubling that.

---

## Inputs & outputs today

**CLI** (`sf-security-scan <projectPath> [-o outDir] [-f json|html|both] [--categories …]`):
- Accepts a **directory path only**. **No diff mode.** The `review` subcommand's `--scope changed` is effectively unimplemented — the CLI never wires `changedFiles` into `runCodeReview`, and the web-ui's `--changed-files` flag isn't even declared in commander.
- **Always a full-tree scan** from the CLI.
- **Outputs:** `security-report.json`, optional `security-report.html`, `code-review-report.json`, and a `checkpoints/` dir. **No SARIF. No JUnit.**
- **Exit code is always 0 on a completed scan.** Every `process.exit(1)` in `src/cli.ts` (lines 124, 170, 221, 306) fires only on an **infrastructure/usage error** — arg-parse failure, missing `projectPath`, or a caught exception. **Findings never fail the process**, and there is no `--fail-on-severity` / threshold config.

**API mode** (`POST /repos`, `POST /repos/:id/scan`, `POST /webhooks/github`) — a push-driven, long-running **service** model. Not pipeline-shaped.

---

## Challenges & gaps (ranked by impact on CI integration)

1. **No distributable artifact.** No container image, no binary. Only runnable via `git clone` → `npm install` → `tsc` → `node dist/cli.js`. A CI agent would have to build it from source every run — the exact drift problem EPIC avoids.
2. **No exit-code gating.** The CLI never fails the build on findings, so it cannot *gate* anything — the single most important property of a pipeline check. There is no severity threshold or fail policy.
3. **No machine-readable CI output.** No SARIF (ADO Advanced Security) and no JUnit. Output is bespoke JSON/HTML meant for the tool's own dashboard, not for a pipeline to consume.
4. **Hard dependency on the PG&E Portkey gateway** with no offline / deterministic fallback — it won't even start without the gateway env vars. A gateway outage takes the whole gate down (no fail-open).
5. **Cost & runtime.** 4+ LLM calls per file × N categories × two pipelines = minutes-to-hours per repo, with **no cost cap** and no scope-to-changed-files in the CLI path. Unviable as an every-build gate.
6. **Full-tree only from the CLI.** The incremental logic exists solely in the API+SQLite service, which is the wrong shape for a stateless pipeline stage.
7. **Two separate runs** (security + review) double the LLM cost for a single evaluation.
8. **Committed secret.** `Application-Codebase/.security-scanner.yml` contains a hard-coded Portkey API key (`portkeyApiKey: "uE9SLPNyicvSUt5t7vKZk2xiGBs6"`). Treat as leaked; any use must override via env var and the key should be rotated.
9. **`infra/` is 0% complete** — no Dockerfile, no CDK stack, no Terraform anywhere in the tree. There is no deployment story.
10. **No compliance framing.** It scans for generic OWASP-style categories; it has no concept of PG&E's AIDLC steering docs or NIST control IDs, so its output doesn't speak the auditor's vocabulary.

---

## What it does *well* (worth learning from)

- **The multi-pass LLM analysis** (comprehend → trace → detect → verify → remediate) is a thoughtful structure — the "verify" pass in particular reduces false positives, a lesson carried into `epic-compliance`'s LLM-refinement step.
- **Checkpoint/resume and batching** show real production thinking about long LLM runs.
- **Remediation suggestions** per finding are developer-friendly.
- The **analyst dashboard** (d3 graph, PDF export) is a legitimately nice reporting surface for a human reviewer — just not a CI artifact.

---

## Why EPIC built a new tool instead of extending this

The gaps above aren't bugs — they're **the entire CI contract**, which was never a design goal here. Retrofitting a container, exit-code gate, SARIF output, cost cap, diff mode, and a compliance-framework mapping onto a pure-LLM, service-shaped, full-tree scanner amounts to building the important parts from scratch anyway, while inheriting the parts that don't fit (two-pipeline cost, dashboard, webhook server, SQLite).

The EPIC Compliance Reviewer (`epic-compliance`) was built to invert the priorities:
- **CI-first**: single static binary, exit-code gate (`0`/`1`/`2`), SARIF + JSON + Markdown out of the box, version-pinned in S3, workspace-scoped install (no drift).
- **Hybrid engine**: deterministic checks for the ~80% that are byte-checkable; LLM only for interpretive controls — cheap and reproducible where it matters.
- **Compliance-framed**: findings keyed to **NIST 800-53 control IDs** from PG&E's own AIDLC steering docs — the unique value no generic scanner (or Wiz/SonarQube) provides.

`ai-code-reviewer` remains a useful reference for the **analysis techniques**; it is not the base for the gate.

---

## Recommendation

- **Do not extend** `ai-code-reviewer` as the EPIC compliance/review gate. Keep it as reference prior art.
- **Rotate** the committed Portkey key immediately, regardless of this project's fate.
- If any part is salvaged, salvage the **multi-pass verify technique** and **remediation prose**, not the plumbing.
- Treat the repo (via its new `.pipeline/epic.json`) purely as a **candidate workload** to validate against the EPIC contract — distinct from any role as EPIC tooling.

---

*Companion docs: [`compliance-reviewer.md`](../compliance-reviewer.md) (Compliance Reviewer charter/log) and [`documents/compliance-reviewer-architecture.md`](compliance-reviewer-architecture.md) (what was built instead).*
