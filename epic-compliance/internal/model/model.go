// Package model defines the core domain types for the EPIC Compliance Reviewer:
// controls, rules, findings, verdicts, and the overall report.
//
// A Rule is our enforceable interpretation of a PG&E control (keyed to a NIST
// 800-53 control ID). Running a Rule against a repository yields a Finding with
// a Verdict. The collection of Findings plus summary counts is a Report.
package model

// Verdict is the outcome of evaluating one rule against a repository.
type Verdict string

const (
	// VerdictPass — control satisfied, code evidence present.
	VerdictPass Verdict = "PASS"
	// VerdictPartial — mechanism present but incomplete/inconsistent (warning).
	VerdictPartial Verdict = "PARTIAL"
	// VerdictFail — control applies and evidence shows it is not met.
	VerdictFail Verdict = "FAIL"
	// VerdictNA — the control's precondition does not exist in this app
	// (e.g. lockout when there is no login).
	VerdictNA Verdict = "N/A"
	// VerdictManual — a real control that only human/runtime attestation can
	// confirm; not determinable from a repository.
	VerdictManual Verdict = "MANUAL"
)

// Severity mirrors the framework's Security Baseline and drives SARIF level.
type Severity string

const (
	SeverityHigh   Severity = "High"
	SeverityMedium Severity = "Medium"
	SeverityLow    Severity = "Low"
)

// RuleKind distinguishes rules that carry a hard, self-contained pass/fail
// criterion from those that only check for the presence of a mechanism.
type RuleKind string

const (
	// KindHard — the framework text states a concrete, checkable criterion
	// (threshold, required fields, enumerated values). These gate the build.
	KindHard RuleKind = "hard"
	// KindPresence — the framework states no threshold; we can only detect
	// whether the mechanism exists. Informational (warning), not a gate.
	KindPresence RuleKind = "presence"
)

// CheckClass describes how (or whether) a control can be evaluated from a repo.
// It drives how the engine treats a catalogued control that has no code rule.
type CheckClass string

const (
	// ClassCode — a code/IaC rule exists and produces a real verdict.
	ClassCode CheckClass = "code"
	// ClassManual — a genuine control, but only human/runtime attestation can
	// confirm it (personnel, process, pen tests, physical media). Auto-MANUAL.
	ClassManual CheckClass = "manual"
	// ClassUnspecified — the framework gives no evaluable requirement text
	// (empty/vague prose). Surfaced as MANUAL with a distinct note. Auto-MANUAL.
	ClassUnspecified CheckClass = "unspecified"
)

// Control is a PG&E/NIST control as catalogued in the steering docs.
// It is the vocabulary a Finding is keyed to — auditor-grade output.
//
// The catalog (IDs, titles, coverage, and the AI-DLC narrative fields) is
// derived from the PG&E "AI-DLC UCF Controls Worksheet" — the authoritative
// mapping of the Unified Controls Framework to the AI-DLC constitution. That
// worksheet uses the canonical NIST 800-53 control IDs, which supersede the
// earlier degraded-PDF extraction (whose IDs were shifted one control down).
type Control struct {
	// NISTID is the primary key, e.g. "AC-06-00".
	NISTID string `json:"nistId"`
	// Title is the control's short name.
	Title string `json:"title"`
	// Requirement is the normative text extracted from the framework doc.
	Requirement string `json:"requirement"`
	// Baseline is the framework's Security Baseline (High/Medium/Low).
	Baseline []Severity `json:"baseline"`
	// InternalID is the secondary PG&E ID (e.g. SECURITY-XX) once the
	// numbering collision in pge-aidlc is resolved. May be empty for now.
	InternalID string `json:"internalId,omitempty"`
	// AppApplicability is the framework's "App Level Applicability" flag.
	AppApplicability string `json:"appApplicability"` // "Yes" | "Maybe"
	// Class describes how this control is evaluated (code / manual / unspecified).
	Class CheckClass `json:"class"`

	// ---- PG&E AI-DLC worksheet fields (auditor context) ----

	// Coverage is the worksheet's disposition of the control against the AI-DLC
	// ruleset: "Done" | "Advise" | "Verify" | "Document" | "Future" |
	// "Cyber to Define" | "" (unassigned). It records where the control stands
	// in the AI-DLC program, independent of a given repo's verdict.
	Coverage string `json:"coverage,omitempty"`
	// Mandatory reports whether the control is currently required for app repos.
	// The worksheet's Mandatory column was blank, so this is derived: a control
	// is mandatory unless its Coverage defers it ("Future"/"Cyber to Define").
	Mandatory bool `json:"mandatory"`
	// Disposition is the worksheet's "AI-DLC Responsible" narrative — who owns
	// the control and under what conditions (e.g. inherited from the IdP vs.
	// enforced in the app when local access is configured).
	Disposition string `json:"disposition,omitempty"`
	// Action is the worksheet's "Action" column — what AI-DLC must do.
	Action string `json:"action,omitempty"`
	// Advice is the worksheet's "Advise users of AI-DLC" guidance.
	Advice string `json:"advice,omitempty"`
	// Notes is the worksheet's free-form clarification for the control.
	Notes string `json:"notes,omitempty"`
	// AddedByEPIC marks a control that is NOT one of the 69 AI-DLC UCF worksheet
	// controls but is enforced by EPIC anyway (e.g. IA-05 committed-secrets).
	// Keeps coverage reporting honest about worksheet-vs-EPIC provenance.
	AddedByEPIC bool `json:"addedByEpic,omitempty"`
}

// Finding is the result of evaluating one Rule against the target repository.
//
// Every finding carries a consistent explanation regardless of verdict: a
// one-line Message (the "why", phrased uniformly per verdict — see
// output.Explain), the CheckedFor description of what the rule looked for, and
// (for FAIL/PARTIAL) either concrete Evidence locations or, when the mechanism
// is entirely absent, a SearchScope describing where it was looked for. This is
// what lets the reports render PASS/FAIL/N/A/MANUAL in one format and give a
// file/line (or an explicit "absent across N files") for every FAIL.
type Finding struct {
	Control  Control  `json:"control"`
	RuleID   string   `json:"ruleId"`
	Kind     RuleKind `json:"kind"`
	Verdict  Verdict  `json:"verdict"`
	Severity Severity `json:"severity"`
	// Message is a human-readable explanation of the verdict.
	Message string `json:"message"`
	// CheckedFor states, in one phrase, what the rule inspected the repo for
	// (e.g. "an account-lockout mechanism on the authentication path"). It is
	// verdict-independent so a reader sees the same "what" whether the control
	// passed, failed, or was found inapplicable.
	CheckedFor string `json:"checkedFor,omitempty"`
	// Evidence lists the concrete code locations supporting the verdict.
	Evidence []Evidence `json:"evidence,omitempty"`
	// SearchScope describes where the rule looked when the mechanism was absent
	// (so an absent-mechanism FAIL still reports a location: "no match in N
	// files: *.ts, *.cs …"). Set only when Evidence is empty and a location
	// would otherwise be missing.
	SearchScope *SearchScope `json:"searchScope,omitempty"`
	// Remediation is guidance for a FAIL/PARTIAL verdict.
	Remediation string `json:"remediation,omitempty"`
	// InheritedFrom names the architectural layer that actually enforces this
	// control when the profiling step determined this repo is not that layer
	// (e.g. "Microsoft Entra ID (MSAL)" for SSO-delegated auth controls). When
	// set, the verdict is N/A with an inheritance rationale in Message.
	InheritedFrom string `json:"inheritedFrom,omitempty"`
}

// SearchScope records where a rule looked for a mechanism it did not find. It
// gives an absent-mechanism FAIL a concrete, honest "location" — the patterns
// and files searched — in place of a file/line that does not exist.
type SearchScope struct {
	// FilesSearched is how many indexed files matched the rule's file patterns.
	FilesSearched int `json:"filesSearched"`
	// FilePatterns is the set of file globs the rule scanned (e.g. "*.ts").
	FilePatterns []string `json:"filePatterns,omitempty"`
	// Anchors names the code locations where the mechanism WOULD live if present
	// (e.g. request handlers, the app entrypoint) so a reviewer knows where to
	// add it. Empty when no relevant anchor could be identified.
	Anchors []string `json:"anchors,omitempty"`
}

// AppKind classifies what a repository IS. A repo may carry more than one kind
// (e.g. a monorepo with both a SPA and an API), so profiles hold a slice.
type AppKind string

const (
	KindFrontendSPA AppKind = "frontend-spa"
	KindBackendAPI  AppKind = "backend-api"
	KindIaC         AppKind = "iac"
	KindLibrary     AppKind = "library"
	KindUnknown     AppKind = "unknown"
)

// AuthModel classifies how an app authenticates its users — the distinction
// that decides whether identity/session/account controls are the app's to own
// or are inherited from an external identity provider.
type AuthModel string

const (
	// AuthDelegatedSSO — login is a redirect to an external IdP (MSAL/OIDC);
	// the app never sees credentials and owns no login surface.
	AuthDelegatedSSO AuthModel = "delegated-sso"
	// AuthLocalLogin — the app owns a credential/login form of its own.
	AuthLocalLogin AuthModel = "local-login"
	// AuthNone — no interactive user authentication in this repo.
	AuthNone AuthModel = "none"
)

// Profile is the output of the profiling ("evaluate") step: what the app is,
// what it has, and what it does. It lets the engine disposition each control to
// the architectural layer that actually enforces it — so a client-side SPA is
// not graded against server-side middleware or IdP login controls it will never
// contain.
type Profile struct {
	// Kinds is what the repo is (may be multiple).
	Kinds []AppKind `json:"kinds"`
	// AuthModel is how users authenticate.
	AuthModel AuthModel `json:"authModel"`
	// IdP names the identity provider when AuthModel is delegated-sso.
	IdP string `json:"idp,omitempty"`
	// HasServerRequestHandling is true when the repo contains server-side
	// request handling (an API/handler), which can own authZ and audit-of-record.
	HasServerRequestHandling bool `json:"hasServerRequestHandling"`
	// HasAuditSink is true when a structured logging/audit sink is present.
	HasAuditSink bool `json:"hasAuditSink"`
	// HasIaC is true when the repo carries infrastructure-as-code (*.tf).
	HasIaC bool `json:"hasIaC"`
	// Narrative is a short human-readable description of the app for the report.
	Narrative string `json:"narrative,omitempty"`
	// Signals lists the concrete detection tokens/files for transparency.
	Signals []string `json:"signals,omitempty"`
	// LLMConfirmed is true when an LLM pass reviewed/refined the profile.
	LLMConfirmed bool `json:"llmConfirmed"`
}

// Has reports whether the profile carries the given app kind.
func (p Profile) Has(k AppKind) bool {
	for _, got := range p.Kinds {
		if got == k {
			return true
		}
	}
	return false
}

// Evidence is a single code location that supports a Finding.
type Evidence struct {
	File    string `json:"file"`
	Line    int    `json:"line,omitempty"`
	Snippet string `json:"snippet,omitempty"`
	// Role explains what this location is relative to the verdict: "match" (the
	// mechanism/text the rule found) or "anchor" (a location where a missing
	// mechanism should live — used to give an absent-mechanism FAIL a concrete
	// pointer). Empty is treated as "match" for backward compatibility.
	Role string `json:"role,omitempty"`
}

// Evidence roles.
const (
	EvidenceMatch  = "match"
	EvidenceAnchor = "anchor"
)

// Report is the full output of a scan: metadata, summary counts, and findings.
type Report struct {
	Metadata Metadata  `json:"metadata"`
	Profile  Profile   `json:"profile"`
	Summary  Summary   `json:"summary"`
	Findings []Finding `json:"findings"`
}

// Metadata describes the scan run.
type Metadata struct {
	Tool     string `json:"tool"`
	Version  string `json:"version"`
	RepoPath string `json:"repoPath"`
	// RepoName is the repository's name (the base of RepoPath), for display.
	// The full RepoPath is often the ADO agent's ephemeral work dir
	// (e.g. /home/adoagent/myagent/_work/1/s/epic-web) which is meaningless to a
	// reader — reports show RepoName instead.
	RepoName   string `json:"repoName"`
	AppType    string `json:"appType,omitempty"`
	SpecSource string `json:"specSource"` // which steering doc(s) drove the rules
	ScannedAt  string `json:"scannedAt"`  // RFC3339, injected by caller (no wall-clock in library)
}

// Summary is the verdict distribution across all findings.
type Summary struct {
	Total     int             `json:"total"`
	ByVerdict map[Verdict]int `json:"byVerdict"`
}

// GateFailed reports whether the report should fail the pipeline stage under
// the given policy. Under the default "hard-fail" policy, any HARD-kind rule
// with a FAIL verdict fails the gate; PARTIAL/MANUAL/N/A never gate.
func (r Report) GateFailed(policy string) bool {
	switch policy {
	case "", "hard-fail":
		for _, f := range r.Findings {
			if f.Kind == KindHard && f.Verdict == VerdictFail {
				return true
			}
		}
		return false
	case "any-fail":
		for _, f := range r.Findings {
			if f.Verdict == VerdictFail {
				return true
			}
		}
		return false
	case "never":
		return false
	default:
		// Unknown policy is treated as the safe default.
		return r.GateFailed("hard-fail")
	}
}
