package output

import (
	"fmt"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
)

// This file defines the ONE explanation format shared by every writer (text,
// markdown, SARIF). A finding of any verdict — PASS, PARTIAL, FAIL, N/A,
// MANUAL — renders with the same four parts, so a reader sees a consistent
// shape throughout the report:
//
//	Verdict — <reason>            (why: a leading verb keyed to the verdict)
//	Checked for: <what>           (verdict-independent; what the rule inspected)
//	Location: <where>             (FAIL/PARTIAL: file:line matches, or, when the
//	                               mechanism is absent, the anchors + search scope)
//	<disposition / remediation>   (MANUAL/N/A: PG&E worksheet disposition;
//	                               FAIL/PARTIAL: remediation)
//
// verbForVerdict gives each verdict a consistent opening so the "why" reads the
// same way every time (e.g. every FAIL starts "Failed —", every MANUAL
// "Requires attestation —").
func verbForVerdict(v model.Verdict) string {
	switch v {
	case model.VerdictPass:
		return "Satisfied"
	case model.VerdictPartial:
		return "Partially met"
	case model.VerdictFail:
		return "Failed"
	case model.VerdictNA:
		return "Not applicable"
	case model.VerdictManual:
		return "Requires attestation"
	default:
		return string(v)
	}
}

// reasonLine is the verdict + normalized "why" sentence.
func reasonLine(f model.Finding) string {
	msg := strings.TrimSpace(f.Message)
	return fmt.Sprintf("%s — %s", verbForVerdict(f.Verdict), msg)
}

// locationText renders the WHERE for a finding as a compact, human-readable
// string. Match evidence is rendered as file:line; when there is no match (an
// absent-mechanism FAIL) it renders the anchor locations and the search scope
// so the verdict still points somewhere concrete. Returns "" when there is
// nothing locational to show (PASS/N/A/MANUAL with no evidence).
func locationText(f model.Finding) string {
	matches, anchors := splitEvidence(f.Evidence)
	if len(matches) > 0 {
		return strings.Join(evidenceLocs(matches), ", ")
	}
	// Absent mechanism: show anchors (where it should live) + what was searched.
	var parts []string
	if len(anchors) > 0 {
		parts = append(parts, "should live at "+strings.Join(evidenceLocs(anchors), ", "))
	}
	if f.SearchScope != nil {
		parts = append(parts, searchScopeText(f.SearchScope))
	}
	return strings.Join(parts, "; ")
}

// searchScopeText renders "not found in N files (patterns)".
func searchScopeText(s *model.SearchScope) string {
	pats := strings.Join(s.FilePatterns, ", ")
	if pats == "" {
		pats = "source files"
	}
	return fmt.Sprintf("no match in %d files searched (%s)", s.FilesSearched, pats)
}

// splitEvidence partitions evidence into concrete matches vs anchors.
func splitEvidence(ev []model.Evidence) (matches, anchors []model.Evidence) {
	for _, e := range ev {
		if e.Role == model.EvidenceAnchor {
			anchors = append(anchors, e)
		} else {
			matches = append(matches, e)
		}
	}
	return matches, anchors
}

// evidenceLocs renders each evidence entry as file or file:line.
func evidenceLocs(ev []model.Evidence) []string {
	out := make([]string, 0, len(ev))
	for _, e := range ev {
		if e.Line > 0 {
			out = append(out, fmt.Sprintf("%s:%d", e.File, e.Line))
		} else {
			out = append(out, e.File)
		}
	}
	return out
}

// dispositionText is the PG&E worksheet context for a finding — the AI-DLC
// coverage disposition plus the responsible-party narrative. Shown on every
// finding so MANUAL/N/A verdicts explain WHO owns the control and why it was
// not graded here, in the same slot FAIL/PARTIAL uses for remediation.
func dispositionText(f model.Finding) string {
	var parts []string
	if c := f.Control.Coverage; c != "" {
		parts = append(parts, "AI-DLC coverage: "+c)
	}
	if d := strings.TrimSpace(f.Control.Disposition); d != "" {
		parts = append(parts, d)
	}
	return strings.Join(parts, " — ")
}

// mandatoryLabel renders the mandatory flag as a short tag.
func mandatoryLabel(c model.Control) string {
	if c.Mandatory {
		return "Mandatory"
	}
	return "Not yet mandatory"
}
