package engine

import (
	"context"
	"path/filepath"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
	"github.com/pgetech/epic-compliance/internal/profile"
	"github.com/pgetech/epic-compliance/internal/rules"
)

// Options configure a scan run.
type Options struct {
	RepoPath string
	// RepoName is the repository name for the report. Optional: when empty it is
	// derived from the base of RepoPath. Callers should pass the real repo name
	// when the scanned path is a subdir (e.g. codePath), since the path base
	// would otherwise be that subdir ("app") rather than the repo ("backstage").
	RepoName  string
	AppType   string
	Version   string
	ScannedAt string    // RFC3339 timestamp injected by the caller (CLI stamps it)
	LLM       rules.LLM // optional; nil => interpretive rules run deterministic-only
	// ProfileLLM optionally refines the app profile (the "evaluate" step). Nil
	// => the profile is deterministic-only. The same gateway client can satisfy
	// both this and LLM.
	ProfileLLM profile.LLM
}

// Scan indexes the repository, profiles the app, runs the code-checkable rules
// (skipping controls the profile shows are enforced by another layer), and
// returns a Report. It does not decide the gate — the caller inspects
// Report.GateFailed.
func Scan(ctx context.Context, opts Options) (model.Report, error) {
	repo, err := newRepo(opts.RepoPath, opts.AppType)
	if err != nil {
		return model.Report{}, err
	}

	// 0. Evaluate step: classify the app so controls can be dispositioned to the
	//    layer that actually enforces them (IdP / server / IaC / pipeline).
	prof := profile.Detect(ctx, repo, opts.ProfileLLM)

	findings := make([]model.Finding, 0, len(rules.Controls))

	// 1. Code-checkable controls: run their rules — unless the profile shows the
	//    control is inherited from another layer, in which case emit an
	//    attributed N/A instead of grading this repo against a control it cannot
	//    structurally own (e.g. account lockout on an SSO-delegated SPA).
	rated := map[string]bool{}
	for _, rule := range rules.Registry {
		if ctx.Err() != nil {
			return model.Report{}, ctx.Err()
		}
		id := rule.ControlID()
		rated[id] = true
		if inherited, from := profile.Disposition(id, prof); inherited {
			findings = append(findings, inheritedFinding(rules.Controls[id], rule.Kind(), from))
			continue
		}
		findings = append(findings, rule.Evaluate(ctx, repo, opts.LLM))
	}

	// 2. Every other catalogued control (manual/unspecified) is emitted as an
	//    explicit MANUAL finding so the report accounts for the full framework
	//    — never silently omitting controls a machine cannot verify.
	for id, c := range rules.Controls {
		if rated[id] {
			continue
		}
		findings = append(findings, manualFinding(c))
	}

	return model.Report{
		Metadata: model.Metadata{
			Tool:       "epic-compliance",
			Version:    opts.Version,
			RepoPath:   opts.RepoPath,
			RepoName:   resolveRepoName(opts.RepoName, opts.RepoPath),
			AppType:    opts.AppType,
			SpecSource: rules.SpecSource,
			ScannedAt:  opts.ScannedAt,
		},
		Profile:  prof,
		Summary:  summarize(findings),
		Findings: findings,
	}, nil
}

// resolveRepoName prefers an explicit repo name (passed by the caller, e.g. the
// real GitHub repo when scanning a codePath subdir) and falls back to deriving
// one from the scanned path.
func resolveRepoName(explicit, path string) string {
	if strings.TrimSpace(explicit) != "" {
		return strings.TrimSpace(explicit)
	}
	return repoName(path)
}

// repoName derives a display name from the scanned path. The path is often the
// ADO agent's ephemeral work dir (e.g. /home/adoagent/myagent/_work/1/s/epic-web)
// whose base is the actual repo — so return the last non-empty path segment.
// Falls back to the cleaned path if it cannot be reduced (e.g. "." or "/").
func repoName(path string) string {
	cleaned := filepath.Clean(strings.TrimSpace(path))
	base := filepath.Base(cleaned)
	if base == "." || base == string(filepath.Separator) || base == "" {
		return cleaned
	}
	return base
}

// inheritedFinding produces the N/A finding for a code-checkable control the
// profile shows is enforced by another architectural layer, attributing it so
// an auditor sees WHY it was not graded in this repo (vs. a missing check).
func inheritedFinding(c model.Control, kind model.RuleKind, from string) model.Finding {
	sev := model.SeverityMedium
	if len(c.Baseline) > 0 {
		sev = c.Baseline[0]
	}
	return model.Finding{
		Control:       c,
		RuleID:        "EPIC-" + c.NISTID,
		Kind:          kind,
		Verdict:       model.VerdictNA,
		Severity:      sev,
		InheritedFrom: from,
		CheckedFor:    "whether this repository is the architectural layer that owns the control",
		Message:       "enforced by " + from + ", outside this repository — not graded here.",
	}
}

// manualFinding produces the MANUAL finding for a catalogued control that has
// no code rule, with a message that explains why it is not repo-checkable.
func manualFinding(c model.Control) model.Finding {
	sev := model.SeverityMedium
	if len(c.Baseline) > 0 {
		sev = c.Baseline[0]
	}
	msg := "personnel, process, or operational evidence for this control cannot be " +
		"verified from source code; human/runtime attestation required."
	checkedFor := "whether this control is verifiable from repository source"
	if c.Class == model.ClassUnspecified {
		msg = "the framework provides no machine-evaluable criterion for this control; " +
			"manual review required."
		checkedFor = "a machine-evaluable criterion in the control text"
	}
	return model.Finding{
		Control:    c,
		RuleID:     "EPIC-" + c.NISTID,
		Kind:       model.KindPresence,
		Verdict:    model.VerdictManual,
		Severity:   sev,
		CheckedFor: checkedFor,
		Message:    msg,
	}
}

func summarize(findings []model.Finding) model.Summary {
	by := map[model.Verdict]int{}
	for _, f := range findings {
		by[f.Verdict]++
	}
	return model.Summary{Total: len(findings), ByVerdict: by}
}
