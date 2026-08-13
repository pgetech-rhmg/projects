package rules

import (
	"context"
	"fmt"

	"github.com/pgetech/epic-compliance/internal/model"
)

// This file wires concrete rules into the Registry. Each rule is a small
// evaluator over the Repo view. Detection here is intentionally conservative:
// a rule returns N/A when the control's precondition is absent, PARTIAL when a
// mechanism is present but unverifiable against the threshold, FAIL when the
// mechanism is clearly missing where it should exist, and defers to the LLM for
// interpretive calls where a regex cannot decide.
//
// Control IDs are the CANONICAL NIST 800-53 ids from the AI-DLC UCF worksheet
// (see controls.go): account lockout is AC-07 (not AC-06), the system-use
// banner is AC-08, concurrent-session control is AC-10, audit-record content is
// AU-03, UTC timestamps are AU-08, audit-record generation is AU-12, and
// artifact-integrity verification is SA-10-01.
//
// Every rule sets CheckedFor (what it looked for, verdict-independent) so the
// report explains PASS/FAIL/N/A uniformly; absent-mechanism FAIL/PARTIAL
// verdicts get a location via anchors (where the mechanism should live) and a
// SearchScope (what was searched) — so a reader always sees WHERE, even when
// there is no matching line.

func init() {
	// HARD rules
	register(&authGatedRule{
		control: "AC-07-00", kind: model.KindHard,
		checkedFor: "an account-lockout mechanism (>=10 failed attempts / 60 min, lock >=15 min) on the authentication path",
		// lockout only applies if there is an auth surface at all
		authSignals:    []string{`login|logon|signin|authenticate\(`, `password|passwd`},
		mechanismRegex: `lockout|failed.?attempts|loginAttempts|max.?attempts|too.?many.?attempts`,
		anchors:        anchorsAuth,
		naMessage:      "No authentication surface found in the repo; account-lockout has no login to protect.",
		failMessage:    "Authentication present but no account-lockout mechanism (10 attempts / 60 min, lock >=15 min) detected.",
		partialMessage: "Lockout-like logic present; threshold (10/60min, >=15min lock) must be confirmed manually.",
		remediation:    "Enforce >=10 invalid attempts per 60 min then lock >=15 min on the authentication path.",
	})
	register(&authGatedRule{
		control: "AC-08-00", kind: model.KindHard,
		checkedFor:     "a system-use notification banner shown before granting access",
		authSignals:    []string{`login|logon|signin`, `session`},
		mechanismRegex: `system use|acknowledge|consent to monitoring|unauthorized use|use notification|banner`,
		anchors:        anchorsAuth,
		naMessage:      "No interactive logon interface found; use-notification banner does not apply (framework limits this to human logon interfaces).",
		failMessage:    "Logon interface present but no system-use notification banner detected.",
		partialMessage: "Banner-like text present; confirm it contains all four mandated statements.",
		remediation:    "Display a use-notification banner with the four mandated statements before granting access.",
	})
	register(&authGatedRule{
		control: "AC-10-00", kind: model.KindHard,
		checkedFor:     "a concurrent-session cap (limit of 2) in session management",
		authSignals:    []string{`session`, `login|signin`},
		mechanismRegex: `concurrent.?session|max.?sessions|session.?limit`,
		anchors:        anchorsAuth,
		naMessage:      "No session management found; concurrent-session limit does not apply.",
		failMessage:    "Sessions present but no concurrent-session cap (limit of 2) detected.",
		partialMessage: "Session-limit logic present; confirm the cap equals 2.",
		remediation:    "Limit concurrent sessions per account to 2.",
	})
	register(&loggingFieldsRule{}) // AU-03-00 (six required audit-record fields)
	register(&presenceRule{
		control: "AU-08-00", kind: model.KindHard,
		checkedFor:     "UTC time-stamp generation for audit records",
		mechanismRegex: `toISOString|time\.Now\(\)\.UTC|Instant\.now|DateTime\.UtcNow|utcnow|new Date\(\)\.toISOString`,
		anchors:        anchorsLogging,
		presentVerdict: model.VerdictPartial,
		presentMessage: "UTC timestamp generation found; confirm all audit records (not just some) carry UTC time stamps.",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "No UTC timestamp generation detected for audit records.",
		remediation:    "Generate UTC time stamps from the system clock on every audit record.",
	})
	register(&presenceRule{
		control: "AU-12-00", kind: model.KindHard,
		checkedFor:     "generation of security-relevant audit events (auth, authorization, privilege escalation, config changes)",
		mechanismRegex: `auth.*event|security.*event|audit.*event|log.*(login|logout|authoriz|denied|privilege)`,
		anchors:        anchorsLogging,
		presentVerdict: model.VerdictPartial,
		presentMessage: "Some security-event logging found; confirm coverage of the enumerated event types.",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "No security-relevant event logging detected (auth, authz, privilege, config changes).",
		remediation:    "Log the enumerated security event types (authentication, authorization, privilege escalation, config changes).",
		llmQuestion:    "Does this evidence show the application actually LOGGING security events (auth successes/failures, authorization decisions, privilege escalation, config changes), or are these matches comments/prompt text/operational logging only? PASS only for real security-event logging coverage.",
	})

	// PRESENCE rules
	register(&presenceRule{
		control: "IA-02-00", kind: model.KindPresence,
		checkedFor:     "authentication enforced on request handling",
		mechanismRegex: `authenticate|preHandler.*auth|Authorize\]|@login_required|passport|jwt|bearer`,
		anchors:        anchorsHandlers,
		presentVerdict: model.VerdictPass,
		presentMessage: "User/request authentication mechanism found.",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "No authentication mechanism found on request handling.",
		remediation:    "Authenticate all non-public requests.",
		llmQuestion:    "Does this evidence show real authentication ENFORCED on request handling (middleware/guards on endpoints), or are these matches merely documentation, comments, prompt text, or outbound-call auth? Answer PASS only if requests are actually authenticated.",
	})
	register(&presenceRule{
		// HARD + layerServer: gates only when the app owns server-side request
		// handling (else the profile step marks it N/A — inherited by the backing
		// API). An access-control (AC) failure on an app that enforces its own
		// authorization is a hard gate.
		control: "AC-03-00", kind: model.KindHard,
		checkedFor:     "server-side authorization enforcement (deny-by-default) on protected operations",
		mechanismRegex: `Authorize|@PreAuthorize|hasRole|hasPermission|can\(|deny.?by.?default|rbac`,
		anchors:        anchorsHandlers,
		presentVerdict: model.VerdictPass,
		presentMessage: "Server-side authorization enforcement found.",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "No server-side access enforcement detected.",
		remediation:    "Enforce approved authorizations server-side; deny by default.",
		llmQuestion:    "Does this evidence show server-side authorization actually enforced on protected operations (deny-by-default), or are these matches comments/prompt text/config unrelated to real access checks? PASS only for genuine enforcement.",
	})
	register(&presenceRule{
		control: "AU-10-00", kind: model.KindPresence,
		checkedFor:     "attributable, timestamped actions supporting non-repudiation",
		mechanismRegex: `timestamp|toISOString|time\.Now|DateTime`,
		anchors:        anchorsLogging,
		presentVerdict: model.VerdictPartial,
		presentMessage: "Timestamps present; non-repudiation attribution requires user identity in logs.",
		absentVerdict:  model.VerdictNA,
		absentMessage:  "No timestamped, attributable actions found.",
	})
	register(&presenceRule{
		control: "AC-02-04", kind: model.KindPresence,
		checkedFor:     "auditing of account create/modify/enable/disable/remove actions",
		mechanismRegex: `createUser|deleteUser|updateUser|account.*(create|modify|disable|remove)|audit.*account`,
		presentVerdict: model.VerdictPartial,
		presentMessage: "Account-management operations found; confirm they are audited.",
		absentVerdict:  model.VerdictNA,
		absentMessage:  "No account-management operations found.",
	})
	register(&presenceRule{
		// HARD + layerIaC: gates only when the repo carries IaC (else N/A —
		// inherited from the hosting edge). When the app owns infra, missing
		// transport protection is a hard gate.
		//
		// Scans BOTH app source AND IaC: TLS can be satisfied either in-app
		// (createSecureServer/listenTLS) or, more commonly, by edge termination
		// declared in Terraform/YAML (an HTTPS listener, ssl_policy, an ACM/KeyVault
		// cert, ingress TLS). Without the IaC patterns a pure-Terraform repo with a
		// perfectly good HTTPS listener would false-FAIL — its .tf files were never
		// grepped. The IaC idioms below mirror how SC-28 already reads *.tf/*.yaml.
		control: "SC-08-00", kind: model.KindHard,
		checkedFor:     "TLS/HTTPS protection of data in transit",
		mechanismRegex: `https|tls|ssl|createSecureServer|listenTLS|ssl_policy|aws_lb_listener|protocol\s*=\s*"?HTTPS|certificate_arn|acm_certificate|https_listener|ssl_certificate|tls_secret|ingress.*tls`,
		filePatterns:   []string{"*.ts", "*.js", "*.go", "*.cs", "*.py", "*.java", "*.tf", "*.yaml", "*.yml"},
		presentVerdict: model.VerdictPartial,
		presentMessage: "TLS/HTTPS references found (in app source and/or IaC edge termination).",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "No TLS/HTTPS found in app source or IaC; confirm TLS termination (in-app or at the load balancer/ingress) — else data-in-transit is unprotected.",
		remediation:    "Serve over TLS, or declare TLS termination at the load balancer/ingress in IaC (e.g. an HTTPS listener with an ACM/Key Vault certificate).",
	})
	register(&presenceRule{
		// HARD + layerIaC: gates only when the repo carries IaC (else N/A —
		// at-rest encryption is inherited from the hosting infra). When the app
		// owns IaC, missing at-rest encryption is a hard gate. Absent now FAILs
		// (was MANUAL) because the profile step only runs this rule when IaC is
		// present, so "no encryption config in the IaC we do have" is a real gap.
		control: "SC-28-00", kind: model.KindHard,
		checkedFor:     "encryption-at-rest configuration in IaC",
		mechanismRegex: `kms|encrypt|storage_encrypted|encryption`,
		filePatterns:   []string{"*.tf", "*.yaml", "*.yml"},
		presentVerdict: model.VerdictPartial,
		presentMessage: "Encryption-at-rest config found in IaC.",
		absentVerdict:  model.VerdictFail,
		absentMessage:  "IaC present but no at-rest encryption config found (e.g. kms/storage_encrypted); data at rest may be unprotected.",
		remediation:    "Configure encryption at rest (e.g. KMS keys, storage_encrypted=true) for stateful resources in IaC.",
	})
	register(&presenceRule{
		control: "CM-06-00", kind: model.KindPresence,
		checkedFor:     "a secure/most-restrictive baseline configuration (STIG/CIS/hardening)",
		mechanismRegex: `stig|cis.?benchmark|hardening|baseline`,
		presentVerdict: model.VerdictPass,
		presentMessage: "Baseline/hardening references found.",
		absentVerdict:  model.VerdictNA,
		absentMessage:  "No baseline-config artifacts in repo; typically an infra/image concern.",
	})
	register(&presenceRule{
		control: "CM-07-00", kind: model.KindPresence,
		checkedFor: "least functionality — no needless open ports/protocols/services",
		// \bports: avoids matching Angular's `imports:` array; EXPOSE/listen(/0.0.0.0
		// are the real network-exposure signals for a server repo.
		mechanismRegex: `0\.0\.0\.0|listen\(|EXPOSE|\bports:`,
		presentVerdict: model.VerdictPartial,
		presentMessage: "Network exposure found; confirm least-functionality (no needless ports/services).",
		absentVerdict:  model.VerdictNA,
		absentMessage:  "No obvious network exposure to evaluate.",
	})
	// EPIC-added HARD control (not in the worksheet's 69): committed secrets.
	register(&secretsRule{})
	register(&presenceRule{
		control: "SA-10-01", kind: model.KindPresence,
		checkedFor:     "software/artifact integrity verification (HMAC/signature/checksum)",
		mechanismRegex: `hmac|timingSafeEqual|checksum|signature|integrity|sha256`,
		presentVerdict: model.VerdictPartial,
		presentMessage: "Integrity-verification mechanism found (HMAC/checksum/signature).",
		absentVerdict:  model.VerdictNA,
		absentMessage:  "No artifact-integrity verification found; may be handled in CI/supply chain.",
		llmQuestion:    "Does this evidence show a real integrity-verification mechanism (HMAC/signature/checksum actually verified), or incidental crypto references? PASS only for genuine verification.",
	})
}

// ---- anchor specifications ----

// anchorSpec describes where a missing mechanism WOULD live, so an
// absent-mechanism FAIL can point a reviewer at a concrete location instead of
// leaving the "location" field empty.
type anchorSpec struct {
	pattern      string
	label        string
	filePatterns []string
}

// Common anchor groups shared across rules. Ordered most-specific first.
var (
	// anchorsHandlers: request/route handlers — where authN/authZ belong.
	anchorsHandlers = []anchorSpec{
		{`\[Http(Get|Post|Put|Delete|Patch)\]|MapControllers|\[ApiController\]`, "API controller/route", []string{"*.cs"}},
		{`app\.(get|post|put|delete|patch)\(|router\.(get|post|put|delete)\(|@(Get|Post|Put|Delete)Mapping|@app\.route|http\.HandleFunc|exports\.handler|export (const|async function) handler`, "request handler", []string{"*.ts", "*.js", "*.go", "*.py", "*.java"}},
	}
	// anchorsAuth: the app's authentication surface — where login/session
	// controls (lockout, banner, concurrent-session cap) belong.
	anchorsAuth = []anchorSpec{
		{`login|logon|signin|authenticate|session`, "authentication/session code", defaultSourcePatterns},
	}
	// anchorsLogging: logging/audit call sites — where audit-record controls
	// (content, timestamps, event coverage) belong.
	anchorsLogging = []anchorSpec{
		{`logger|log\.|pino|winston|slog|ILogger|logging\.|console\.(log|error|warn)`, "logging call site", defaultSourcePatterns},
	}
)

// locateAbsence builds the SearchScope for an absent-mechanism verdict: how many
// files were searched under which patterns, plus up to two anchor locations
// (recorded on the finding as Role=anchor evidence) where the missing mechanism
// should live. This gives an absent FAIL a concrete pointer even with no match.
func locateAbsence(repo Repo, f *model.Finding, filePatterns []string, anchors []anchorSpec) {
	if len(filePatterns) == 0 {
		filePatterns = defaultSourcePatterns
	}
	f.SearchScope = &model.SearchScope{
		FilesSearched: len(repo.Files(filePatterns...)),
		FilePatterns:  filePatterns,
	}
	const maxAnchors = 2
	for _, a := range anchors {
		if len(f.Evidence) >= maxAnchors {
			break
		}
		fp := a.filePatterns
		if len(fp) == 0 {
			fp = filePatterns
		}
		for _, e := range repo.Grep(a.pattern, fp...) {
			e.Role = model.EvidenceAnchor
			f.Evidence = append(f.Evidence, e)
			f.SearchScope.Anchors = append(f.SearchScope.Anchors,
				fmt.Sprintf("%s (%s:%d)", a.label, e.File, e.Line))
			if len(f.Evidence) >= maxAnchors {
				break
			}
		}
	}
}

// ---- rule implementations ----

// presenceRule is the common shape: grep for a mechanism signature and map
// present/absent to configured verdicts.
type presenceRule struct {
	control        string
	kind           model.RuleKind
	checkedFor     string
	mechanismRegex string
	filePatterns   []string     // defaults to common source patterns if empty
	anchors        []anchorSpec // where the mechanism should live, for absent FAILs
	presentVerdict model.Verdict
	presentMessage string
	absentVerdict  model.Verdict
	absentMessage  string
	remediation    string
	// llmQuestion, when set AND an LLM is supplied, escalates a "present"
	// heuristic hit to the model to confirm/refine the verdict — this is what
	// prevents regex false positives (e.g. matching prompt text) from passing.
	llmQuestion string
}

func (r *presenceRule) ControlID() string    { return r.control }
func (r *presenceRule) Kind() model.RuleKind { return r.kind }

func (r *presenceRule) Evaluate(ctx context.Context, repo Repo, llm LLM) model.Finding {
	patterns := r.filePatterns
	if len(patterns) == 0 {
		patterns = defaultSourcePatterns
	}
	ev := repo.Grep(r.mechanismRegex, patterns...)
	f := newFinding(r.control, r.kind)
	f.CheckedFor = r.checkedFor
	if len(ev) > 0 {
		f.Verdict = r.presentVerdict
		f.Message = r.presentMessage
		f.Evidence = markMatches(capEvidence(ev))
		refineWithLLM(ctx, llm, &f, r.llmQuestion, ev)
		// An LLM refinement may flip present->FAIL; if it did and left no
		// concrete match, still give the FAIL a location.
		locateIfNeeded(repo, &f, patterns, r.anchors)
	} else {
		f.Verdict = r.absentVerdict
		f.Message = r.absentMessage
		f.Remediation = r.remediation
		locateIfNeeded(repo, &f, patterns, r.anchors)
	}
	return f
}

// authGatedRule is N/A unless an auth surface exists; only then does it check
// the specific mechanism. Used by the access-control HARD rules where "no
// login" must read as N/A rather than FAIL.
type authGatedRule struct {
	control        string
	kind           model.RuleKind
	checkedFor     string
	authSignals    []string // any-of; presence means an auth surface exists
	mechanismRegex string
	anchors        []anchorSpec
	naMessage      string
	failMessage    string
	partialMessage string
	remediation    string
	llmQuestion    string // escalate the PARTIAL hit to the LLM when supplied
}

func (r *authGatedRule) ControlID() string    { return r.control }
func (r *authGatedRule) Kind() model.RuleKind { return r.kind }

func (r *authGatedRule) Evaluate(ctx context.Context, repo Repo, llm LLM) model.Finding {
	f := newFinding(r.control, r.kind)
	f.CheckedFor = r.checkedFor
	hasAuth := false
	for _, sig := range r.authSignals {
		if len(repo.Grep(sig, defaultSourcePatterns...)) > 0 {
			hasAuth = true
			break
		}
	}
	if !hasAuth {
		f.Verdict = model.VerdictNA
		f.Message = r.naMessage
		return f
	}
	ev := repo.Grep(r.mechanismRegex, defaultSourcePatterns...)
	if len(ev) > 0 {
		f.Verdict = model.VerdictPartial
		f.Message = r.partialMessage
		f.Evidence = markMatches(capEvidence(ev))
		refineWithLLM(ctx, llm, &f, r.llmQuestion, f.Evidence)
		locateIfNeeded(repo, &f, defaultSourcePatterns, r.anchors)
	} else {
		f.Verdict = model.VerdictFail
		f.Message = r.failMessage
		f.Remediation = r.remediation
		locateIfNeeded(repo, &f, defaultSourcePatterns, r.anchors)
	}
	return f
}

// locateIfNeeded populates the SearchScope + anchor locations for a FAIL/PARTIAL
// finding that has no concrete match evidence, so every gating verdict carries a
// location. It is a no-op for PASS/N/A/MANUAL and for findings that already have
// match evidence.
func locateIfNeeded(repo Repo, f *model.Finding, filePatterns []string, anchors []anchorSpec) {
	if f.Verdict != model.VerdictFail && f.Verdict != model.VerdictPartial {
		return
	}
	if hasMatchEvidence(f) {
		return
	}
	locateAbsence(repo, f, filePatterns, anchors)
}

// hasMatchEvidence reports whether the finding carries at least one real match
// (as opposed to anchor) evidence location.
func hasMatchEvidence(f *model.Finding) bool {
	for _, e := range f.Evidence {
		if e.Role != model.EvidenceAnchor {
			return true
		}
	}
	return false
}

// markMatches tags evidence as concrete matches (Role=match) so writers can
// distinguish "the mechanism we found" from "where a missing one should live".
func markMatches(ev []model.Evidence) []model.Evidence {
	for i := range ev {
		if ev[i].Role == "" {
			ev[i].Role = model.EvidenceMatch
		}
	}
	return ev
}

// refineWithLLM asks the model to confirm/refine a heuristic verdict when both
// an LLM and a question are available. The model's verdict replaces the
// heuristic one, and its reasoning is appended. On any LLM error the heuristic
// verdict stands (fail-open to the deterministic result, never crash the gate).
func refineWithLLM(ctx context.Context, llm LLM, f *model.Finding, question string, ev []model.Evidence) {
	if llm == nil || question == "" {
		return
	}
	v, reason, err := llm.Judge(ctx, f.Control, ev, question)
	if err != nil {
		// Fail-open to the deterministic verdict; record a capped error so the
		// cause is visible without dumping the full gateway body into the report.
		msg := err.Error()
		if len(msg) > 400 {
			msg = msg[:400] + "…"
		}
		f.Message += " [LLM check skipped after retries: " + msg + "]"
		return
	}
	f.Verdict = v
	if reason != "" {
		f.Message = reason + " (LLM-reviewed)"
	}
}

// loggingFieldsRule (AU-03-00) checks for the six required audit-record fields.
// A structured logger raises confidence; bare console/print logging lowers it.
type loggingFieldsRule struct{}

func (r *loggingFieldsRule) ControlID() string    { return "AU-03-00" }
func (r *loggingFieldsRule) Kind() model.RuleKind { return model.KindHard }

func (r *loggingFieldsRule) Evaluate(ctx context.Context, repo Repo, llm LLM) model.Finding {
	f := newFinding("AU-03-00", model.KindHard)
	f.CheckedFor = "audit records carrying all six required fields (what/when/where/source/outcome/identity)"
	structured := repo.Grep(`pino|winston|slog|ILogger|structlog|logrus|zap`, defaultSourcePatterns...)
	bare := repo.Grep(`console\.(log|error|warn)|print\(|fmt\.Print`, defaultSourcePatterns...)
	switch {
	case len(structured) > 0:
		f.Verdict = model.VerdictPartial
		f.Message = "Structured logger found; confirm audit records carry all six fields (what/when/where/source/outcome/identity)."
		f.Evidence = markMatches(capEvidence(structured))
		refineWithLLM(ctx, llm, &f, "Given this structured-logging evidence, do audit records plausibly carry all six required fields (event type, when, where, source, outcome, identity)? PARTIAL if some are missing/uncertain, PASS only if all six are clearly present, FAIL if it is only operational logging without these fields.", f.Evidence)
	case len(bare) > 0:
		f.Verdict = model.VerdictFail
		f.Message = "Only unstructured logging (console/print) found; the six required audit-record fields are not captured."
		f.Evidence = markMatches(capEvidence(bare))
		f.Remediation = "Adopt a structured logger emitting event type, timestamp, location, source, outcome, and identity."
	default:
		f.Verdict = model.VerdictFail
		f.Message = "No logging detected; audit records cannot be produced."
		f.Remediation = "Emit structured audit records with the six required fields."
		locateAbsence(repo, &f, defaultSourcePatterns, anchorsHandlers)
	}
	return f
}

// secretsRule (IA-05-00) is EPIC's committed-secrets gate — not one of the 69
// worksheet controls. It scans a BROAD set of file types (source, .env, tfvars,
// tfstate, key/cert files) for secret patterns, in two tiers:
//
//   - DEFINITE secrets — structurally unambiguous, high-entropy provider
//     credentials (AWS key id, private-key header, Azure AccountKey, JWT,
//     Slack/GitHub tokens, inline-password connection strings). A single match
//     is a HARD FAIL that the LLM MAY NOT downgrade. A placeholder cannot
//     accidentally look like these, so there is nothing to "interpret away".
//   - AMBIGUOUS assignments — `password=`/`secret=`/`token=`/`api_key=` set to
//     some literal. These legitimately include commented placeholders
//     (CHANGE_ME, TO_LOAD_FROM_AWS) so, absent a definite hit, the LLM may vet
//     them and downgrade to PASS if ALL are placeholders.
//
// Every pattern is always scanned (no early break) so a real secret is never
// starved by earlier low-signal matches. On LLM error the deterministic FAIL
// stands (fail-closed).
type secretsRule struct{}

func (r *secretsRule) ControlID() string    { return "IA-05-00" }
func (r *secretsRule) Kind() model.RuleKind { return model.KindHard }

// definiteSecretPatterns match structurally unambiguous real secrets. Any hit
// is an un-downgradable FAIL.
var definiteSecretPatterns = []string{
	`AKIA[0-9A-Z]{16}`,                                // AWS access key id
	`-----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY`, // private key file
	`eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.`,     // JWT (header.payload.)
	`xox[baprs]-[0-9A-Za-z-]{10,}`,                    // Slack token
	`gh[pousr]_[0-9A-Za-z]{20,}`,                      // GitHub PAT
	`AccountKey=[A-Za-z0-9+/]{40,}`,                   // Azure Storage account key
	`postgres(ql)?://[^\s:]+:[^\s@/]+@`,               // conn string with inline password
	`AIza[0-9A-Za-z_-]{30,}`,                          // Google API key
}

// ambiguousSecretPatterns match secret-named assignments that MIGHT be real or
// MIGHT be placeholders. LLM-vettable when no definite hit exists.
var ambiguousSecretPatterns = []string{
	`(client_secret|clientsecret)["'\s:=]+[0-9A-Za-z._~+/-]{16,}`,
	`(password|passwd|pwd)["'\s:=]+[^\s"'$<{][^\s"']{5,}`,
	`(secret|api_?key|token|access_?key)["'\s:=]+[0-9A-Za-z._~+/-]{16,}`,
}

// secretFilePatterns intentionally include committed env/state/key files —
// exactly where real leaks live — in addition to source.
var secretFilePatterns = []string{
	"*.ts", "*.js", "*.go", "*.cs", "*.py", "*.java", "*.php", "*.rb",
	"*.env", "*.env.*", ".env", ".env.*",
	"*.tfvars", "*.tfstate", "*.tfstate.backup",
	"*.pem", "*.key", "*.pfx", "*.p12",
	"*.json", "*.yaml", "*.yml", "*.properties", "*.config",
}

func (r *secretsRule) Evaluate(ctx context.Context, repo Repo, llm LLM) model.Finding {
	f := newFinding("IA-05-00", model.KindHard)
	f.CheckedFor = "committed secrets/credentials/keys/tokens in tracked files (source, .env, tfvars, tfstate, key/cert files)"

	// Scan ALL patterns — no early break — so a real secret is never starved by
	// earlier low-signal matches.
	var definite, ambiguous []model.Evidence
	for _, pat := range definiteSecretPatterns {
		definite = append(definite, repo.Grep(pat, secretFilePatterns...)...)
	}
	for _, pat := range ambiguousSecretPatterns {
		ambiguous = append(ambiguous, repo.Grep(pat, secretFilePatterns...)...)
	}

	// A definite secret is an un-downgradable HARD FAIL — the LLM never runs.
	if len(definite) > 0 {
		f.Verdict = model.VerdictFail
		f.Message = "Committed secret(s) detected in tracked files (provider key/token/private-key/connection-string) — credentials must not live in source control."
		f.Evidence = markMatches(capEvidence(definite))
		f.Remediation = "Remove the secret from source, rotate it (git history retains it), and inject it at runtime from AWS Secrets Manager / Azure Key Vault."
		return f
	}

	if len(ambiguous) == 0 {
		f.Verdict = model.VerdictPass
		f.Message = "No committed secrets detected across source, env, tfstate, and key/cert files."
		return f
	}

	// Only ambiguous secret-named assignments remain; these can be placeholders,
	// so start FAIL and let the LLM downgrade to PASS only if ALL are clearly fake.
	f.Verdict = model.VerdictFail
	f.Message = "Possible committed secret(s) detected in tracked files — credentials must not live in source control."
	f.Evidence = markMatches(capEvidence(ambiguous))
	f.Remediation = "Remove the secret from source, rotate it (git history retains it), and inject it at runtime from AWS Secrets Manager / Azure Key Vault."
	refineWithLLM(ctx, llm, &f,
		"Each evidence line matched a secret-assignment pattern in a committed file. Does ANY line show a REAL secret value (FAIL), or is EVERY match a placeholder/commented example/test fixture (e.g. CHANGE_ME, TO_LOAD_FROM_AWS, <your-key>, example, all-x's)? Answer FAIL if ANY match is a real secret; PASS only if ALL are clearly placeholders.",
		f.Evidence)
	return f
}

// ---- helpers ----

var defaultSourcePatterns = []string{"*.ts", "*.js", "*.go", "*.cs", "*.py", "*.java", "*.php", "*.rb"}

// newFinding builds a Finding pre-populated from the control catalog.
func newFinding(controlID string, kind model.RuleKind) model.Finding {
	c := Controls[controlID]
	sev := model.SeverityMedium
	if len(c.Baseline) > 0 {
		sev = c.Baseline[0]
	}
	return model.Finding{
		Control:  c,
		RuleID:   "EPIC-" + controlID,
		Kind:     kind,
		Severity: sev,
	}
}

// capEvidence limits evidence to a readable number of locations per finding.
func capEvidence(ev []model.Evidence) []model.Evidence {
	const max = 5
	if len(ev) > max {
		return ev[:max]
	}
	return ev
}
