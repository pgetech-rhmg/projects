# Standalone Evaluation — `projects/ai-code-reviewer/`

**Evaluated:** 2026-07-09
**Repo:** `projects/ai-code-reviewer/` (package `code-scanner` v2.0.0, Node/TypeScript)
**Lens:** This evaluates the app **as a standalone application on its own merits** — how you build it, run it, test it, and trust it as a product — *independent of* whether it's ever wired into a pipeline. Issues that make it manual, un-automated, or off-best-practice are flagged inline.

> A separate review ([`ai-code-reviewer-project-review.md`](ai-code-reviewer-project-review.md)) covers its fitness as an EPIC pipeline stage. This document deliberately does **not** judge it against the CI contract — it judges it as a tool a developer runs by hand.

---

## Verdict at a glance

A **capable, thoughtfully-architected LLM scanner** with real test discipline (31 test files, property-based testing) and a genuinely interesting multi-pass analysis design. But as a standalone product it is **hard to operate, undocumented, and expensive to run**, and it carries a **committed secret**. It reads like a strong solo research prototype, not a hand-off-ready application.

| Dimension | Rating | Summary |
|-----------|--------|---------|
| Architecture & code structure | 🟢 Good | Clean pass separation, typed, modular. |
| Testing | 🟢 Good | 31 test files; unit + property-based (fast-check). |
| Documentation | 🔴 **Poor** | **No README anywhere.** Undiscoverable without reading source. |
| Operability (build/run) | 🟡 Manual | Clone → npm install → tsc → node. All manual, all local. |
| Efficiency / cost | 🔴 **Poor** | Many LLM calls per file; per-finding fan-out; two full pipelines. |
| Security hygiene | 🔴 **Poor** | **Committed Portkey API key** tracked in git. |
| Tooling / best practices | 🟡 Mixed | `strict` TS + tests, but **no linter, no formatter, no CI**. |

---

## 1. What it is (standalone)

A command-line + local-service security scanner. Two entry points (`package.json` `bin`):
- **`sf-security-scan`** (`dist/cli.js`) — the CLI: point it at a directory, get security + code-review reports.
- **`code-scanner-api`** (`dist/api/server.js`) — a Fastify REST service with GitHub webhooks and SQLite persistence, meant to run as a long-lived local server.

~6,900 LOC of TypeScript in `Application-Codebase/src`, plus a ~5,500-LOC `web-ui/` analyst dashboard (d3 graph, PDF export, "DevAsk" LLM Q&A). Originally aimed at **Salesforce/Apex** code (the category prompts are Salesforce-specific), with a general-language fallback path.

---

## 2. Getting it running — **manual, undocumented, local-only**

🔴 **There is no README, no docs/ folder, no run instructions anywhere in the repo.** To even learn the commands you must read `package.json` and `src/cli.ts`. For a standalone tool meant to be used by anyone but the author, this is the single biggest usability gap.

🟡 **Startup is entirely manual and local.** There is no packaged artifact — no binary, no `npx`-able published package, no container. The only path is:
```
git clone → npm install → npm run build (tsc) → node dist/cli.js <path>
```
`node_modules` is not vendored and the app was never installed in this checkout, so first run requires a full toolchain.

🟡 **Configuration is split and implicit.** Config comes from a `.security-scanner.yml` file (default path, `config-loader.ts:115`) merged with three required env vars (`PORTKEY_API_KEY`, `PORTKEY_BASE_URL`, `BEDROCK_MODEL`). Nothing documents this contract; you discover it by reading `config-loader.ts`. The app **will not function without the PG&E Portkey gateway** — there's no offline or mock mode for local evaluation.

🔴 **Hard external dependency with no fallback.** Every analysis path calls the LLM. If the gateway is unreachable or the key is invalid, the tool produces nothing — there is no deterministic/static-analysis mode to fall back on. As a standalone tool, it is only as available as the gateway.

---

## 3. Efficiency & cost — **the biggest architectural weakness**

🔴 This is where the design is most expensive. The tool's own comment (`detection.ts:9`) states *"Each category is analyzed in a separate LLM call."* Combined with per-finding passes, the call count multiplies fast. For a **single scan of one repo**:

**Security pipeline (`src/ai/pipeline.ts`) — five sequential passes, each doing its own LLM calls:**

| Pass | What it calls | LLM calls |
|------|---------------|-----------|
| 1 — Comprehension | one call **per file** | `F` |
| 2 — Flow tracing | one call **per file group** | `~G` |
| 3 — Detection | one call **per enabled category, per batch** — up to **6 categories** (access-control, injection, xss, csrf, open-redirect, secrets) | `≈ 6 × B` |
| 4 — Verification | one call **per finding** (batched) | `N_findings` |
| 5 — Remediation | one call **per finding/file** (batched) | `~N_findings` |

**Then the code-review pipeline (`src/review/code-review-pipeline.ts`) runs as a *separate* Pass 6**, iterating files again with its own `callLLM` per batch.

**Net effect — the inefficiencies to highlight:**
1. 🔴 **Multiplicative call count.** A file isn't scanned once — it's comprehended (1), traced (≥1), then detected against **each of up to 6 categories** separately. That alone is up to **8+ calls before any finding exists**, and verification + remediation then add a call *per finding*. A repo with a few hundred files and dozens of findings runs into the **many-hundreds-to-thousands of LLM calls** range for one scan.
2. 🔴 **Two full pipelines per evaluation.** Security scan and code review are separate runs over the same files. The code-review pass reuses Pass-1 comprehension (a good touch) but still adds a whole second per-file LLM sweep — roughly **doubling** the cost of a "full" analysis.
3. 🔴 **Per-category prompting instead of one multi-category call.** Detection deliberately splits categories into separate calls "to keep prompts focused" (`detection.ts:9`). Cleaner prompts, but 6× the calls and 6× the token overhead (each call re-sends the file/context). A single call returning all categories, or grouping cheap categories, would cut this dramatically.
4. 🔴 **Per-finding verification & remediation.** Passes 4 and 5 fan out one call per finding. A noisy detector (many findings) is directly, linearly more expensive — the tool costs *more* exactly when the code is *worse*.
5. 🟡 **No result caching / memoization across runs.** The only "skip work" mechanism is disk **checkpointing for crash-resume within a single run** (`checkpoint.ts`) — re-scanning an unchanged file in a later run re-pays the full LLM cost. (Content-hash caching would make repeat runs near-free.)
6. 🟡 **No cost or token budget cap.** Nothing bounds total spend or call count; a large repo can run for a very long time (minutes-to-hours) with no ceiling and no estimate up front.
7. 🟢 **Mitigations that *are* present:** batching with bounded concurrency (`Promise.all` per batch, `batch-processor.ts:66`), and retry with **exponential backoff** (`BASE_DELAY_MS * 2^attempt`, `batch-processor.ts:24`). These control burst rate — they do **not** reduce the total number of calls.

**Bottom line on efficiency:** the pass architecture is *analytically* sound but *economically* naive. The cost model scales with `files × categories + findings × 2`, across two pipelines, with no cross-run caching and no budget cap. For a standalone tool a developer runs repeatedly, this is slow and expensive by design.

---

## 4. Code quality & architecture — **the strong part**

🟢 **Clean modular structure.** Passes are separated into their own files (`src/ai/passes/*.ts`), the LLM client is isolated (`portkey-client.ts`), config loading is centralized, and types are shared (`types.ts`). The pipeline wiring (`pipeline.ts`) is readable and each stage has a clear single responsibility.

🟢 **TypeScript `strict: true`** is enabled (`tsconfig.json`). Good baseline type safety.

🟢 **Thoughtful domain modeling.** The 5-pass design (comprehend → trace → detect → **verify** → remediate) is genuinely good thinking — the *verification* pass explicitly re-checks findings to cut false positives, and the Salesforce platform-context prompts encode real domain knowledge (e.g. "@AuraEnabled has automatic CSRF tokens — don't flag it"). This is above typical prototype quality.

🟢 **Crash-resume via checkpointing** shows production-minded engineering for long runs.

🟡 **Salesforce-first, general-language second.** The richest prompts are Apex-specific; the general path is thinner. Fine if Salesforce is the target, but the name "code-reviewer" oversells the general-language coverage.

---

## 5. Testing — **surprisingly strong**

🟢 **31 test files**, well beyond prototype norms, run via **Vitest**:
- **15 unit tests** (`tests/unit/`) — discovery, config, CLI, file parsing.
- **12 property-based tests** (`tests/property/`) using **fast-check** — prompt construction, severity invariants, response-parser round-trips, report metadata, inline-ignore handling, config parsing. Property-based testing is a mature choice most prototypes never reach for.
- **2 AI-pass tests** + **2 platform tests** (also property-based).

🟢 Dedicated scripts: `test`, `test:watch`, `test:unit`, `test:property`.

🟡 **But the tests never run automatically** — there is **no CI**, so the suite only protects the author who remembers to run it (see §7).

---

## 6. Security hygiene — **a real problem**

🔴 **Committed API key.** `Application-Codebase/.security-scanner.yml` contains a hard-coded Portkey key (`portkeyApiKey: "uE9SLPNyicvSUt5t7vKZk2xiGBs6"`) and gateway URL, and the file **is tracked in git** (confirmed via `git ls-files`). This is a live secret in version control.
- **Action:** rotate the key immediately, remove the file from history, and load the key from env only (the loader already reads `PORTKEY_API_KEY` from env — the committed value should never have been there).

🟡 **`.gitignore` is reasonable otherwise** — it excludes `.env`, `node_modules`, `dist`, `*.db`, and `reports/` — which makes the committed `.security-scanner.yml` an inconsistency, not a blanket carelessness. The scanner config file simply wasn't treated as a secret.

🟢 **Ironically, this is exactly the class of finding the tool exists to catch** ("secrets: CRITICAL for hardcoded secrets") — it doesn't scan itself.

---

## 7. Tooling & best-practice gaps

🔴 **No CI whatsoever.** No `.github/workflows`, no pipeline config for the tool itself. Tests, typecheck, and build are **manual** — nothing runs them on change. (`.github/` is even in `.gitignore`.) For a standalone project this means quality is entirely dependent on developer discipline.

🔴 **No linter, no formatter.** There is no ESLint and no Prettier config anywhere. The `lint` script is misleadingly named — it's just `tsc --noEmit` (a typecheck, not a lint). Style and common-bug linting are entirely absent; consistency rests on one author's habits.

🔴 **No README / usage docs / contribution guide.** Covered in §2 — worth repeating as a best-practice gap. A standalone tool with no docs is effectively single-maintainer-only.

🟡 **No versioned/published artifact.** `v2.0.0` in `package.json` but nothing is published (no npm registry entry, no release, no container). "Install" = clone and build.

🟡 **No license file** and no author/ownership metadata in `package.json`.

🟢 **Good scripts hygiene otherwise** — clear `build`/`start`/`start:cli`/`test*` scripts; sensible dependency choices (commander, fastify, fast-check, vitest).

---

## 8. Summary — flagged issues

**Manual / not automated:**
- ❌ No README or run docs — operation is discoverable only by reading source.
- ❌ Build/install/run are all manual local steps (clone → install → tsc → node).
- ❌ No CI — tests, typecheck, and build never run automatically.
- ❌ Config contract (yml + 3 env vars) is undocumented and implicit.

**Does not follow best practices:**
- ❌ **Committed API key** tracked in git.
- ❌ No linter and no formatter (`lint` is just a typecheck).
- ❌ No published/packaged artifact; no license.
- ❌ Hard dependency on an external gateway with no offline/mock mode.

**Inefficient:**
- ❌ Up to **6 separate LLM calls per file just for detection** (one per category).
- ❌ **Per-finding** verification *and* remediation calls — cost grows with finding count.
- ❌ **Two full pipelines** (security + review) per evaluation.
- ❌ **No cross-run caching** — unchanged files are re-analyzed and re-billed every run.
- ❌ **No cost/token cap or up-front estimate.**

**Genuinely good:**
- ✅ Clean, modular, `strict`-typed architecture with a smart 5-pass (verify-included) design.
- ✅ 31 tests including property-based (fast-check) coverage.
- ✅ Crash-resume checkpointing, batching, exponential-backoff retry.
- ✅ Real domain knowledge encoded in the Salesforce prompts.

---

## Recommendations (standalone)

1. **Rotate the committed key now** and purge `.security-scanner.yml` from history; load secrets from env only.
2. **Write a README** — commands, config contract, env vars, example run, cost expectations. This is the highest-leverage fix.
3. **Cut LLM cost:** collapse the 6 per-category detection calls into one multi-category call (or group them), and add **content-hash caching** so unchanged files aren't re-billed across runs. Add a token/cost budget cap with an up-front estimate.
4. **Add real tooling:** ESLint + Prettier, and a CI workflow that runs `build` + `test` + typecheck on every change (the tests already exist — they just don't run).
5. **Add an offline/mock mode** so the tool can be evaluated and tested without the gateway.
6. **Add a `LICENSE`** and author metadata.

*Overall: a strong analytical engine wrapped in a weak product shell. The intelligence is real; the operability, documentation, cost discipline, and security hygiene are not.*
