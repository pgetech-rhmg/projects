package rules

import (
	"context"

	"github.com/pgetech/epic-compliance/internal/model"
)

// Repo is the read-only view of the target repository a Rule evaluates.
// It is provided by the engine so rules do not touch the filesystem directly
// (keeps rules unit-testable with an in-memory Repo).
type Repo interface {
	// Files returns repo-relative paths matching the given glob-ish patterns.
	Files(patterns ...string) []string
	// Grep returns evidence for lines matching a (case-insensitive) regex
	// across the given file patterns.
	Grep(pattern string, filePatterns ...string) []model.Evidence
	// AppType is the declared appType from .pipeline/epic.json, if known.
	AppType() string
}

// LLM is the interface to the reasoning backend (Bedrock via Portkey gateway).
// Interpretive rules use it; deterministic rules leave it unused. Kept as an
// interface so the engine can inject a no-op in offline/deterministic mode.
type LLM interface {
	// Judge asks the model to evaluate a control against supplied evidence and
	// return a verdict with reasoning. Implementations must be deterministic
	// enough for CI (low temperature).
	Judge(ctx context.Context, control model.Control, evidence []model.Evidence, question string) (model.Verdict, string, error)
}

// Rule evaluates one control against a repository and returns a Finding.
type Rule interface {
	// ControlID is the NIST id this rule enforces (key into Controls).
	ControlID() string
	// Kind reports whether this is a HARD (gating) or PRESENCE (warning) rule.
	Kind() model.RuleKind
	// Evaluate produces a Finding. It may consult the LLM for interpretive
	// judgment; deterministic rules ignore it.
	Evaluate(ctx context.Context, repo Repo, llm LLM) model.Finding
}

// Registry is the ordered set of rules the engine runs. Order is display order
// in the report (HARD rules first, then presence).
//
// NOTE: concrete Rule implementations are added in rules_impl.go as they are
// built. This scaffold wires the structure; the per-rule detection logic is
// the next implementation step.
var Registry []Rule

// register appends a rule to the Registry. Called from impl file init().
func register(r Rule) { Registry = append(Registry, r) }
