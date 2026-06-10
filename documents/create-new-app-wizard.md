# Create New App Wizard — Design Doc

## 1. Goal

Add a "Create New App" wizard to **epic-web** that walks a user through a deterministic set of questions and emits a single Markdown file: **`epic.md`**. The user puts that file in their empty repo. They are also instructed (by `epic.md` itself) to download the current version of PG&E's AI-DLC steering docs into `.ai/`. They then start a new AI session and tell it to "run `epic.md`" — the AI reads the file, reads `.ai/`, and produces all the actual artifacts (app code, `.infra/`, `.pipeline/epic.json`, README, etc.).

The wizard collects intent and writes a directive document. **It does not scaffold anything.** No app structure, no `.infra/`, no `.pipeline/epic.json` — those are entirely the AI's job, derived from the requirements captured in `epic.md`.

**Green-field only.** The target repo is empty. Brown-field flows (adding EPIC to an existing repo) are out of scope for v1 and continue to use the existing "Add to My Apps" / builder modals.

## 2. Non-goals (v1)

- No code generation. The wizard never produces app source, infra Terraform, or `epic.json`.
- No LLM invocation. The downstream AI session is the user's, outside this feature.
- No persistence to epic-api. No new backend tables, controllers, or endpoints.
- No repo or PR creation. No GitHub calls.
- No automatic AI-DLC download. `epic.md` *instructs* the user to populate `.ai/`; the wizard does not fetch the docs.
- No new Angular routes. The wizard is a modal, consistent with the existing "New Run" / "Builder" / "How To" modals.
- No reference-app catalog.
- No brown-field support.

## 3. UX Flow

### 3.1 Entry point

A new **"Create New App"** primary button in the main page header (next to the existing "Add to My Apps" button). Clicking it opens the wizard modal. The existing `builder` modal (which produces just `epic.json`) stays as-is for now; if both end up overlapping in practice, we collapse them in a follow-up.

### 3.2 Step layout

The wizard is a single modal with a step indicator (1 / 2 / 3 / 4 / Review). Each step has Back / Next; the final step has **Download `epic.md`** and **Copy to Clipboard**.

Step branching is driven by `appType` and `cloudProvider` answered in steps 1 and 2 — the same pattern used today in [app.ts:891-900](epic-web/src/app/app.ts#L891-L900) where `applyAppTypeDefaults` toggles stage availability based on the selected config's appType.

```
Step 1: App basics       → name, appType, scan/unit-test/integration-test tools (tools disabled until appType is picked)
Step 2: Architecture     → frontend? backend? lambda? API? DB? events? auth?
Step 3: Cloud target     → AWS | Azure | BTP, account/subscription, region
Step 4: Generation hints → free-text notes for the AI + acceptance criteria
Review : Rendered epic.md, Download / Copy buttons
```

There is no "EPIC contract" step. The wizard does not ask for `codePath` / `infraPath` / `runtimeVersion` — the AI infers those from the architecture answers and the AI-DLC steering docs in `.ai/`, and writes `.pipeline/epic.json` itself. Scan, unit-test, and integration-test tool selections **are** captured in step 1 (after `appType` is chosen) and flow through to `epic.json` and the rendered allowlist.

### 3.3 Branching rules

| Trigger                          | Effect                                                                                       |
| -------------------------------- | -------------------------------------------------------------------------------------------- |
| `appType = btp`                  | Step 2 forces cloud=AWS (BTP secrets live in AWS Secrets Manager); Step 3 hides Frontend / Backend / Lambda / DB toggles (BTP apps are CF deployments). |
| `appType = infra`                | Step 3 collapses to an "infra-only" notice — no architecture toggles.                        |
| `appType = ami`                  | Step 3 hides Frontend / Backend / DB toggles; shows AMI components list only.                |
| `appType in [angular,react,html]`| Step 3 defaults `hasFrontend=true`.                                                          |
| `appType in [dotnet,java,python,php,node]` | Step 3 defaults `hasBackend=true`.                                                  |
| `cloudProvider = aws`            | `ami` and `btp` remain selectable; Azure-only options hidden.                                |
| `cloudProvider = azure`          | `ami` and `btp` hidden in Step 1's appType list.                                             |

## 4. Question Schema

Authoritative source for what's asked and what shape the answer takes. The wizard component will hold this as a TypeScript constant (see §6 Implementation).

### Step 1 — App basics

| Field           | Type                | Required | Notes                                                                                       |
| --------------- | ------------------- | -------- | ------------------------------------------------------------------------------------------- |
| `appName`       | kebab-case string   | yes      | Validated against `^[a-z][a-z0-9-]{2,40}$`. Must not collide with an existing app in `apps()` signal — call `appService` to check. |
| `appType`       | enum                | yes      | `angular \| react \| dotnet \| node \| python \| java \| html \| php \| ami \| btp \| infra`. Mirrors [app.ts:344-488](epic-web/src/app/app.ts#L344-L488). |
| `description`   | string (1-2 lines)  | yes      | Surfaces in the steering doc as the LLM's "what we're building" prompt.                     |
| `scanTool`            | enum   | optional | From `SCAN_TOOL_OPTIONS`. Disabled until `appType` is selected. Empty = no scan tool. |
| `buildTestTool`       | enum   | optional | Per-`appType` allowlist (`BUILD_TEST_TOOL_OPTIONS`). Disabled until `appType` is selected. Empty = no unit-test runner. |
| `integrationTestTool` | enum   | optional | Per-`appType` allowlist (`INTEGRATION_TEST_TOOL_OPTIONS`). Disabled until `appType` is selected. Empty = no integration-test runner. |

### Step 2 — Architecture (skipped/reduced for btp/infra/ami)

Each toggle is a yes/no. If yes, sub-fields appear inline.

| Toggle           | Sub-fields when "yes"                                                                                  |
| ---------------- | ------------------------------------------------------------------------------------------------------ |
| `hasFrontend`    | Renders as **Frontend Auth** in the form. Sub-fields: `authMode` (none \| oidc-entra \| msal), `authClientId` (when authMode uses Entra), `apiBaseUrlNeeded`. Framework is *not* asked — `appType` already conveys it. |
| `hasBackend`     | `backendStyle` (`rest-api \| lambda-per-endpoint \| graphql`), `runtime`, `authStyle` (`none \| jwt-validator \| api-key`) |
| `needsDatabase`  | `dbEngine` (`postgres \| dynamodb \| sqlserver \| sqlite-local-dev-only`), `dbScale` (`single-instance \| multi-az`)        |
| `needsQueue`     | `queueKind` (`sqs \| sns \| eventbridge \| servicebus`)                                                  |
| `needsScheduler` | cron / EventBridge schedule rule. Simple `string` field; doc tells the AI to wire into infra.          |
| `needsStorage`   | `storageKind` (`s3 \| azure-blob`)                                                                     |
| `includeInfra`   | No sub-fields. Boolean. **Defaults to `true`** for `appType` `infra` and any architecture toggle that implies cloud resources; defaults to `false` for `html` static sites with no backend. The user can override either way. When `false`, `epic.md` omits the `.infra/` directive entirely — the AI will not generate Terraform. |

### Step 3 — Cloud target

When `includeInfra` is unchecked on Architecture, this page collapses to just the cloud-provider dropdown plus an optional account/subscription identifier — region and resource group are hidden because EPIC won't generate Terraform — and a per-`appType` **Deploy target** subform appears asking for already-provisioned resource identifiers (S3 bucket, CloudFront distribution ID, EC2 instance, App Service name, etc.). When `includeInfra` is checked, no deploy-target fields are collected — the AI derives them from the architecture answers and the Terraform outputs.

| Field                 | Type                          | When required                | Notes                              |
| --------------------- | ----------------------------- | ---------------------------- | ---------------------------------- |
| `cloudProvider`       | `aws \| azure \| btp`         | always                       | BTP forces AWS-side secrets too. Locked when `appType=btp`. |
| `awsAccountId`        | 12-digit string               | `includeInfra` AND (provider=aws OR appType=btp) | Validated `^\d{12}$`. Optional (no validation) when `!includeInfra`. |
| `awsRegion`           | string, default `us-west-2`   | `includeInfra` AND (provider=aws OR appType=btp) | Match dropdown to known PG&E regions. Hidden when `!includeInfra`. |
| `azureSubscriptionId` | UUID                          | `includeInfra` AND provider=azure | Standard UUID validation. Optional when `!includeInfra`. |
| `azureResourceGroup`  | string                        | `includeInfra` AND provider=azure | Free-text. Hidden when `!includeInfra`. |
| `deployTarget`        | flat string fields            | `!includeInfra` AND appType is set | Per-`appType` set of pre-existing resource identifiers. The schema is keyed off `(appType, cloudProvider)` and matches the `cloud.*` keys actually read by `epic-pipeline/deploy/main.yml`: SPA on AWS → `s3`, `cloudfront`, `appUrl`; server runtime on AWS → `ec2InstanceId`, `appExecutable`, `appUrl`; anything on Azure → `appServiceName`, `resourceGroupName`, `appUrl`; `ami` → `configDocPrefix`, `testDocPrefix`, `imageRecipeName`. Each value flows verbatim into `cloud.*` in `epic.json`; blanks become the literal string `"TODO"` plus a row in `overview.md`. The wizard hides irrelevant keys per `appType`. |

### Step 4 — Generation hints

| Field                | Type                | Notes                                                                            |
| -------------------- | ------------------- | -------------------------------------------------------------------------------- |
| `acceptanceCriteria` | textarea (multiline)| Free-text. The AI reads this verbatim — what "done" looks like.                  |
| `extraNotes`         | textarea            | Anything the user wants the AI to know that the structured fields didn't capture. |

## 5. Output — `epic.md`

The wizard renders the answers into one Markdown file named exactly **`epic.md`** (not parameterized — the user drops it at the root of the empty repo and the AI session is told to "run epic.md"). Section headings are stable so the AI can locate them deterministically.

```markdown
# epic.md — <appName>

**Generated:** <ISO timestamp>
**By:** <currentUser>

You are starting a new green-field application. This file is your brief. Read it end-to-end before doing anything.

## Prerequisites — do this first
1. Confirm `.ai/` exists at the repo root and contains PG&E's AI-DLC steering docs. If it does not, **stop** and ask the user to download the current AI-DLC steering docs into `.ai/` before continuing.
2. Treat everything in `.ai/` as authoritative for naming, security, review, and code-style conventions. This file describes *what* to build; `.ai/` describes *how* PG&E expects you to build it.
3. Do not write `.pipeline/epic.json`, `.infra/`, `code/`, or any application artifact until you have completed the **Design phase** below and the user has explicitly approved it.

## Workflow — design first, then build
You will work in two phases. Do not skip ahead.

### Phase 1 — Design (write to `.design/` only)
Create a `.design/` folder at the repo root and put **every** design document, architecture diagram, data-model sketch, API surface, infra topology note, and other steering artifact you produce inside it. Nothing outside `.design/` is created in this phase.

At minimum, `.design/` should contain:
- `overview.md` — restated goal, acceptance criteria, and open questions
- `app-design.md` — language/framework choices, module layout, key components, auth/data flow
- `infra-design.md` — *only if `Infrastructure: included` appears in the Architecture section below* — Terraform module list, resource topology, IAM/secrets approach, environment differences
- `pipeline-design.md` — the planned shape of `.pipeline/epic.json` and any rationale for non-default fields

When `.design/` is complete, **stop and present a summary to the user**. List what you intend to create in Phase 2 (file tree of `code/`, `.infra/`, and `.pipeline/`). Wait for explicit approval before continuing. If the user requests changes, update the relevant `.design/` doc and ask again.

### Phase 2 — Build (only after user approval)
Once the user approves, generate the artifacts listed under **What you must produce**. Do not modify `.design/` during Phase 2 except to mark sections as implemented if useful for the user.

## Goal
<description>

## Acceptance criteria
<acceptanceCriteria>

## App profile
- App name: <appName>
- App type: <appType>

## Cloud target
- Provider: <cloudProvider>
- AWS account / Azure subscription: <id>
- Region: <region>

## Architecture
<rendered list of Step 3 toggles + sub-fields; sections omitted when "no". For btp/infra/ami the section is replaced with a single line describing the deployment shape.>

## What you must produce
After the user approves the design (Phase 1), produce exactly these artifacts in Phase 2. Derive each from the App profile, Cloud target, and Architecture sections, plus the conventions in `.ai/` and the approved `.design/` documents:

1. **`code/`** — application source code, tests, README, and `.gitignore` for the app type and architecture described above. All app code lives under `code/` at the repo root.
2. **`.pipeline/epic.json`** — shape it to match the app type and cloud target. Stage selection at run time is controlled by the EPIC web UI, **not** this file, so do not embed stage flags.
3. **`.infra/` Terraform project** — *only if `Infrastructure: included` appears in the Architecture section above.* When included, generate only the resources actually implied by the architecture and approved in `.design/infra-design.md`. Use modules from `epic-pipeline-modules/` where they fit. When **not** included, do not create `.infra/` at all.

Do not commit secrets. List required Secrets Manager keys in the README and let PG&E ops populate them.

Final repo layout (after Phase 2):
```
<repo-root>/
  .ai/             # AI-DLC steering docs (already in place)
  .design/         # design docs from Phase 1 (kept in the repo)
  .pipeline/
    epic.json
  .infra/          # only if infrastructure was included
  code/            # application source
  epic.md    # this file
```

## Open items / extra notes
<extraNotes>
```

## 6. Implementation Plan (epic-web)

All work is in **epic-web** — no API or pipeline changes.

### 6.1 New files

| Path                                                        | Purpose                                                                                  |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `epic-web/src/app/wizard/wizard.model.ts`                   | TypeScript types for `WizardAnswers`, `AppType`, `CloudProvider`, the question schema.   |
| `epic-web/src/app/wizard/wizard.template.ts`                | Pure function `renderEpicMd(answers: WizardAnswers): string`. Easy to unit test.   |
| `epic-web/src/app/wizard/wizard.template.spec.ts`           | Unit tests covering: each appType branch, each cloudProvider, BTP flow, ami flow.        |

### 6.2 Edits to existing files

- **`epic-web/src/app/app.ts`** — add wizard state (signals) following the pattern of `showBuilderModal` / `builderStep` at [app.ts:1062-1064](epic-web/src/app/app.ts#L1062-L1064). Add `openCreateAppWizard()`, `closeCreateAppWizard()`, `wizardNext()`, `wizardBack()`, `wizardDownload()`, `wizardCopy()`. Keep the wizard's signals grouped under one `// ── Create New App Wizard ──` section.
- **`epic-web/src/app/app.html`** — add the modal and the trigger button. Mirror the existing builder modal markup so styling/animations are consistent.
- **`epic-web/src/app/app.scss`** — minor — reuse `.modal`, `.modal-content`, `.builder-step` classes; add a `.wizard-step` modifier only if needed.
- **`@HostListener('document:keydown.escape')`** in [app.ts:93-100](epic-web/src/app/app.ts#L93-L100) — add `else if (this.showCreateAppWizard()) this.closeCreateAppWizard();` to the chain.

The wizard does **not** reuse `builderRuntimePlaceholders` / `builderUnitTestOptions` / `epicJsonSamples` — those are epic.json concerns, and the wizard never touches epic.json.

### 6.3 Download mechanism

Use a Blob + anchor click — no library needed:
```ts
const blob = new Blob([renderEpicMd(answers)], { type: 'text/markdown' });
const url = URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = 'epic.md';
a.click();
URL.revokeObjectURL(url);
```

### 6.4 Validation

Per-step validation runs on Next click; the button is disabled until the step is valid (same pattern as `canBuilderNext` at [app.ts:1191-1195](epic-web/src/app/app.ts#L1191-L1195)). Cross-cutting validation (appName uniqueness vs. `apps()`) runs on Step 1 blur.

## 7. Decisions

1. **AI-DLC integration.** `epic.md` instructs the user (and the AI session) to populate `.ai/` with PG&E's current AI-DLC steering docs before doing any other work. The wizard does not fetch the docs and does not embed a download URL — that step is owned by the user.
2. **Overlap with existing builder modal.** Keep both. The wizard is for green-field new apps; the builder remains reachable from the "How To" / "New Run" paths for users who only need an `epic.json` for an existing repo.
3. **App-type / cloud combinations.** Hide invalid options in the cloud step based on appType (e.g. `ami` only on AWS, `btp` forces AWS). The user cannot select a nonsensical pairing.
4. **No stage / tool config in the wizard.** Stage selection (build / test / scan / deploy / integrations / infra action) is owned by epic-web's New Run feature at run time. The wizard does not ask, and `epic.md` does not embed, any stage flags.
5. **Schema drift.** The wizard's renderer is a pure function with snapshot tests. If the question shape or output template changes, tests fail loudly rather than the wizard silently producing broken docs.
6. **Design-then-build workflow.** `epic.md` enforces a two-phase flow on the AI session: Phase 1 writes design docs to `.design/` only, then waits for explicit user approval; Phase 2 generates `code/`, `.pipeline/epic.json`, and (when applicable) `.infra/`. The wizard itself does not need to know about this — the directive is baked into the rendered template.
