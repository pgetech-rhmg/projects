# EPIC Compliance Reviewer

A focused compliance gate for the EPIC pipeline. It scans a checked-out
repository against the **enforceable subset** of PG&E's *T&S R&C Unified
Controls Framework* (app-applicable) and emits findings **keyed to NIST 800-53
control IDs**. It runs as an EPIC stage between `download` and `build`, and the
pipeline gates on this tool's **exit code**.

It is **not** a general code reviewer and **not** a replacement for Wiz (cloud
posture) or SonarQube (code quality) — both already integrated into EPIC. Its
unique value is PG&E-specific policy-as-code from the AIDLC steering docs.

> Design context, scope decisions, and the rule-derivation rationale live in
> the workspace root: [`../compliance-reviewer.md`](../compliance-reviewer.md)
> and [`../STATE.md`](../STATE.md).

## Status: v1 scaffold (deterministic heuristics)

The architecture, CLI contract, rule catalog, and output formats are in place
and working end-to-end. Rule **detection** currently uses conservative regex
heuristics — they demonstrate the verdict model (PASS / PARTIAL / FAIL / N/A /
MANUAL) but are **not yet production-accurate**: they can over-match (e.g. match
rule text inside a scanner's own prompt strings) or under-match. The interpretive
controls are meant to defer to an LLM (Bedrock via the PG&E Portkey gateway);
that `LLM` seam exists (`internal/rules.LLM`) but is not yet wired — v1 runs
deterministic-only.

See "Known limitations" below before trusting a verdict.

## Prerequisites

- **Go 1.23+** to build (this repo builds a static, dependency-free binary).

## Build

```bash
make build                       # host binary -> bin/epic-compliance
make release VERSION=v1.0.0      # static linux/amd64 -> dist/ (the ONLY binary EPIC/S3 uses)
make release-all VERSION=v1.0.0  # every platform (linux, mac arm+intel, windows) -> dist/
```

Two distinct distribution channels, do not conflate them:

| Channel | Binary(ies) | Built by | Published to | Versioned? | Consumed by |
|---------|-------------|----------|--------------|-----------|-------------|
| **Pipeline** | `linux-amd64` | `make release` | **S3** (`pge-epic-compliance-reviewer`) | **yes** — pinned via `COMPLIANCE_REVIEWER_VERSION` | the EPIC Review stage. **The only binary S3 needs.** |
| **Local shift-left** | `darwin-arm64`, `darwin-amd64`, `linux-amd64`, `windows-amd64.exe` | `make publish-local` | **GitHub Release `local`** | **no** — rolling, always-latest | developers running the gate on their machine |

The two channels are independent. **CI is version-pinned** (reproducible, audited);
**local shift-left is always-latest** (a rolling GitHub Release named `local` whose
unversioned assets are overwritten on every `make publish-local`). Binaries are
**never committed to git** (`dist/` is git-ignored) — GitHub Releases store assets
outside the repo, so the clone never grows. See "Local shift-left" below.

## Bumping a version

The EPIC pipeline runs a **version-pinned** binary pulled from S3 — nothing is
`latest`. Rolling a change is four steps; the pipeline picks it up on the next
run once the ADO variable points at the new version.

1. **Make the change** — edit the code and run `make test` / `make vet`.
2. **Build the release binaries** for the new version (bump the tag — patch for a
   fix, minor for a feature). Build every arch from the **same checkout** so a
   version's artifacts stay byte-faithful to each other:
   ```bash
   make release-all VERSION=v1.0.1
   # -> dist/epic-compliance-v1.0.1-linux-amd64        (EPIC pipeline — goes to S3)
   # -> dist/epic-compliance-v1.0.1-darwin-arm64       (local shift-left — GitHub only)
   # -> dist/epic-compliance-v1.0.1-darwin-amd64       (local shift-left — GitHub only)
   # -> dist/epic-compliance-v1.0.1-windows-amd64.exe  (local shift-left — GitHub only)
   # (version is baked in via -ldflags)
   ```
3. **Deploy the linux/amd64 binary to S3** — this is the **only** artifact S3
   needs; it is what the pipeline pulls and gates on. Upload under the pinned key
   (KMS-encrypted, from the `EPIC AWS Resources/Compliance Reviewer/` stack):
   ```bash
   aws s3 cp dist/epic-compliance-v1.0.1-linux-amd64 \
     s3://pge-epic-compliance-reviewer/compliance/epic-compliance-v1.0.1-linux-amd64 \
     --sse aws:kms --sse-kms-key-id alias/pge-epic-compliance
   ```
   > Do **not** upload the mac/windows binaries to S3 — they are not part of the
   > pipeline contract and would just be dead weight in the bucket. They belong on
   > GitHub Releases (next step).
4. **Refresh the local shift-left binaries** — rebuild the unversioned binaries
   and overwrite the rolling `local` GitHub Release (this is what the shift-left
   scripts download; it is *not* version-pinned — local always runs latest):
   ```bash
   make publish-local            # builds dist/local/* and re-uploads with --clobber
   ```
   > This channel is optional per-version housekeeping, independent of the S3
   > pin above — do it whenever you want local runs to reflect the newest checks.
5. **Bump the EPIC (ADO) version** — set `COMPLIANCE_REVIEWER_VERSION` in the
   `GV-account-access` variable group (ADO Library) to the new tag
   (`v1.0.1`). The engine passes it to the Review stage as
   `complianceVersion`, which builds the S3 key. No pipeline YAML edit needed.

> Keep the `v` prefix consistent (`v1.0.1`) — it's part of the git tag, the S3
> key, and `COMPLIANCE_REVIEWER_VERSION`. The binary carries its own `v` via
> `-ldflags`, so reports and `--version` render it once (do not add another).
> (The `local` GitHub Release is *not* versioned — its assets are unversioned and
> rolling; a binary pulled from it still self-reports whatever version it was
> built with.)

## Usage

```bash
epic-compliance <repoPath> [flags]
```

| Flag | Meaning |
|------|---------|
| `--app-type` | `appType` from `.pipeline/epic.json` (will dispatch rule packs) |
| `--out`      | write native JSON report to this path (EPIC dashboard / audit record) |
| `--sarif`    | write SARIF 2.1.0 report (ADO Advanced Security) |
| `--fail-on`  | gate policy: `hard-fail` (default), `any-fail`, `never` |
| `--quiet`    | suppress the human-readable text summary |
| `--version`  | print version and exit |

### Exit codes (the gate contract)

| Code | Meaning |
|------|---------|
| `0`  | gate passed — pipeline proceeds |
| `1`  | gate failed — a gating finding was raised; pipeline should stop |
| `2`  | usage / runtime error — scan could not complete |

Under the default `hard-fail` policy, **only HARD-kind rules with a FAIL verdict
fail the gate.** PARTIAL / MANUAL / N/A never gate — they are informational.

## How it runs in EPIC (planned stage)

The pipeline pulls a version-pinned binary from S3 into the cleaned run
workspace and executes it — no global install, so `workspace: clean: all`
guarantees a fresh tool every run:

```yaml
- bash: |
    aws s3 cp s3://<bucket>/compliance/epic-compliance-$(complianceVersion)-linux-amd64 ./epic-compliance
    chmod +x ./epic-compliance
    ./epic-compliance "$(System.DefaultWorkingDirectory)/${{ parameters.appName }}" \
      --app-type "${{ parameters.appType }}" \
      --sarif compliance.sarif --out compliance.json --fail-on hard-fail
  displayName: "Compliance Reviewer"
  env:
    PORTKEY_API_KEY: $(portkeyKey)   # for the interpretive controls (once wired)
```

The `bash` step's exit code gates the stage — identical in shape to the Wiz
stage (`epic-pipeline/scan/wiz/main.yml`).

## Local shift-left (run the gate before you push)

The pipeline runs this gate for you in the **Review** stage — but you don't have
to wait for CI. You can run the gate against your working tree locally and catch
a HARD failure before it ever reaches the pipeline. Local runs always use the
**latest** binary (the rolling `local` GitHub Release), so you get the newest
checks without pinning anything.

### One-time setup

1. Install the **GitHub CLI** (`gh`) — <https://cli.github.com>.
2. Log in to the org once:
   ```bash
   gh auth login          # choose GitHub.com, and the pgetech account
   ```
3. Add the `epic-scan` command to your shell — **run the one-liner for your OS**
   and it writes the function into your profile for you:

   ```bash
   # macOS / Linux  (adds it to ~/.zshrc or ~/.bashrc)
   gh api repos/pgetech/epic-compliance/contents/scripts/install.sh \
     -H "Accept: application/vnd.github.raw" | bash
   ```
   ```powershell
   # Windows PowerShell  (adds it to your $PROFILE)
   gh api repos/pgetech/epic-compliance/contents/scripts/install.ps1 `
     -H "Accept: application/vnd.github.raw" | iex
   ```
   Then open a new terminal. (Re-running the installer is safe — it refreshes the
   command in place rather than duplicating it.)

That's the whole prerequisite. **No AWS access, no KMS, no source checkout, no Go
toolchain, and no file to keep up to date** — the command streams the latest
script straight from this repo each run, which in turn pulls the latest binary.

<details>
<summary>Prefer to add it by hand? (equivalent to what the installer writes)</summary>

```bash
# macOS / Linux  — paste into ~/.zshrc or ~/.bashrc
epic-scan() {
  gh api repos/pgetech/epic-compliance/contents/scripts/epic-scan.sh \
    -H "Accept: application/vnd.github.raw" | bash -s -- "$@"
}
```
```powershell
# Windows PowerShell — paste into $PROFILE
function epic-scan {
  $t = "$env:TEMP\epic-scan.ps1"
  gh api repos/pgetech/epic-compliance/contents/scripts/epic-scan.ps1 `
    -H "Accept: application/vnd.github.raw" | Out-File -Encoding utf8 $t
  & $t @args
}
```
</details>

### Every time you want to scan

Same command on both platforms — just pass your app's path:

```bash
epic-scan ~/code/my-app        # macOS / Linux
```
```powershell
epic-scan C:\code\my-app       # Windows
```

That one command does everything: fetches the latest scanner script and the
latest binary for your OS, auto-detects `appType` from your
`.pipeline/epic.json`, scans, prints a summary, writes `compliance.md` (readable)
+ `compliance.sarif` next to the app, and exits with the gate code (`0` pass /
`1` HARD fail / `2` error). Open the `.sarif` with the VS Code **SARIF Viewer**
extension for inline squiggles at each finding.

> Both the script and the binary always update automatically — there is nothing
> to re-download when the gate changes.

### Manual (no shell function, or an unsupported OS)

Download your binary from the rolling `local` release and run it directly:

```bash
gh release download local --repo pgetech/epic-compliance \
  --pattern 'epic-compliance-<your-os-arch>' --output epic-compliance
chmod +x ./epic-compliance   # (skip on Windows)
./epic-compliance /path/to/your/app --app-type <appType> --md compliance.md --fail-on hard-fail
```

Published arches: `darwin-arm64` (Apple Silicon), `darwin-amd64` (Intel Mac),
`linux-amd64`, `windows-amd64.exe`. Note: local runs are **deterministic-only**
(no `--llm`), so they are slightly noisier than CI — a local FAIL is a strong
signal, but the LLM pass in CI may reclassify a borderline finding.

## Layout

```
cmd/epic-compliance/   CLI entrypoint + exit-code gate
internal/model/        domain types: Control, Rule, Finding, Verdict, Report
internal/rules/        control catalog (controls.go) + rule impls (rules_impl.go)
internal/engine/       repo indexer + scan orchestration
internal/output/       JSON, SARIF 2.1.0, and text report writers
```

## The rule set (15 rules from the AI-DLC UCF worksheet)

Derived from the **AI-DLC UCF Controls Worksheet** — PG&E's authoritative
mapping of the Unified Controls Framework (69 app-applicable NIST controls) to
the AI-DLC constitution. Each control carries its worksheet **coverage
disposition** (Done / Advise / Verify / Document / Future / Cyber-to-Define) and
a per-control narrative (responsible party, action required, developer advice)
that the reports surface. Only ~6 controls carry a hard, self-contained
pass/fail criterion; ~9 more are presence-checkable; the rest are
process/human/infra controls a repo scan cannot verify and are surfaced as
MANUAL/N/A.

**HARD (gate):** AC-07-00 (lockout), AC-08-00 (use banner), AC-10-00 (concurrent
sessions), AU-03-00 (audit-record fields), AU-08-00 (UTC timestamps), AU-12-00
(security event generation).

**PRESENCE (warn):** IA-02-00, AC-03-00, AU-10-00, AC-02-04, CM-06-00, CM-07-00,
SC-08-00, SC-28-00, SA-10-01.

> **Canonical IDs (2026-07-16 migration).** The worksheet uses the canonical
> NIST 800-53 IDs, which **supersede** the earlier degraded-PDF extraction whose
> control names were shifted one control down. Finding IDs changed accordingly:
> lockout AC-06→**AC-07**, banner AC-07→**AC-08**, concurrent-sessions
> AC-08→**AC-10**, six-field audit AU-02→**AU-03**, UTC timestamps
> AU-06→**AU-08**, security-event generation AC-12→**AU-12**, non-repudiation
> AU-08→**AU-10**, baseline-config CM-05→**CM-06**, least-functionality
> CM-06→**CM-07**, artifact-integrity SI-07→**SA-10-01**. (AC-06 is now correctly
> *Least Privilege*, a MANUAL control.) Reports produced before this migration do
> not line up ID-for-ID.

## Report format (consistent across verdicts)

Every finding renders the same ordered fields regardless of verdict — PASS,
PARTIAL, FAIL, N/A, or MANUAL — so a reader sees one consistent shape:

- **Verdict/why** — a normalized opener per verdict (*Satisfied* / *Partially
  met* / *Failed* / *Not applicable* / *Requires attestation*) + the reason.
- **Checked for** — what the rule inspected (verdict-independent).
- **Location** — for FAIL/PARTIAL: the `file:line` matches; when the mechanism
  is **entirely absent**, the *anchor* location(s) where it should live plus an
  explicit *"no match in N files searched (patterns)"* — so **every FAIL carries
  a concrete location**, even when there is no matching line.
- **Remediation** (FAIL/PARTIAL) and **PG&E disposition** (worksheet coverage +
  responsible-party narrative + Mandatory flag), rendered on every finding.

This shape is identical across the text summary, the Markdown artifact, the JSON
report (`checkedFor`, `evidence[].role`, `searchScope`), and SARIF (each result
carries a location for both matches and anchors).

## The evaluate step (app profiling)

Before any control rule runs, the reviewer **profiles the repository** — what it
IS (a client-side SPA, a server API, IaC, a library), what it HAS (server
request handling, an audit sink, IaC), and what it DOES for authentication
(delegated SSO vs. a local login vs. none). This is the fix for the class of
false FAILs where the full 76-control framework was graded against a repo that
structurally cannot satisfy a control.

Each code-checkable control is mapped to the architectural **layer** that
enforces it:

| Layer | Controls | Inherited when… |
|-------|----------|-----------------|
| `idp` | AC-07/08/10 (lockout, banner, sessions), IA-02, AC-02-04 | auth is **delegated SSO** — the IdP owns login/session/account |
| `server` | AC-03, AU-03/08/10/12 | the repo has **no server request handling** — the backing API owns authZ & audit-of-record |
| `iac` | SC-08 (TLS), SC-28 (at-rest) | the repo carries **no IaC** — the hosting edge enforces it |
| `pipeline` | SA-10-01 (artifact integrity) | the repo does **no server-side verification** — the EPIC pipeline signs artifacts |
| `host` | CM-07 (least functionality) | the repo runs **no server** — the host/platform baseline owns ports/protocols |

When a control is inherited, the reviewer emits an **N/A finding attributed to
that layer** (e.g. *"Inherited from the identity provider (Microsoft Entra ID
(MSAL))"*) and does **not** run its rule — so an SSO-delegated SPA is never
failed for account lockout or a login banner it cannot own. Controls not in the
layer map are always graded in-repo.

Profiling is deterministic (signature detection over the indexed repo) and,
when `--llm` is set, refined by a confirmation pass; the deterministic result is
the floor, so offline CI stays reproducible. The chosen profile is printed in
every report (text, Markdown "App Profile" section, JSON `profile`, SARIF run
properties).

Example — running against **epic-web** (an Angular SPA on MSAL/Entra ID) went
from **8 FAIL** to **0 FAIL**: the 6 IdP/server access-control FAILs plus
SA-10-01 are now correctly dispositioned as inherited N/A, keying only genuine
in-repo concerns (SC-08/SC-28 IaC, CM-06/CM-07) as PARTIAL/PASS.

## Known limitations (v1)

- **Regex heuristics over-/under-match.** They match on line content, so a rule
  can flag the *text* of a control described in a comment or prompt string. The
  LLM judgment layer is the intended fix for interpretive controls.
- **Profiling heuristics are v1.** App-kind/auth-model detection is
  signature-based; an unusual stack may be misclassified, which would mis-set a
  control's inherited/graded disposition. The `--llm` confirmation pass and the
  printed profile (review it) are the mitigations.
- **Inheritance is attribution, not proof.** An inherited N/A asserts the
  control is enforced *elsewhere* (IdP/API/IaC/pipeline); it does not verify that
  layer actually enforces it. That remains an attestation.
- **Catalog now sourced from the AI-DLC UCF worksheet** (canonical NIST IDs),
  which resolved the earlier degraded-PDF "shifted one control down" mismapping.
  Some requirement text for MANUAL controls is derived from the worksheet title
  where no fuller prose was supplied — confirm against the framework doc before
  hard-coding thresholds. (See `../compliance-reviewer.md`.)
- **`SECURITY-XX` cross-reference is empty** pending resolution of the pge-aidlc
  numbering collision.
```
