package output

import (
	"fmt"
	"io"
	"sort"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
)

// writeProfileMarkdown renders the "evaluate" step's app profile so a reader
// sees WHAT the reviewer decided the app is — and thus why inherited controls
// were dispositioned rather than graded.
func writeProfileMarkdown(w io.Writer, p model.Profile) {
	if len(p.Kinds) == 0 {
		return
	}
	fmt.Fprintln(w, "## App Profile")
	fmt.Fprintln(w)
	kinds := make([]string, len(p.Kinds))
	for i, k := range p.Kinds {
		kinds[i] = string(k)
	}
	fmt.Fprintf(w, "- **Kind:** %s\n", strings.Join(kinds, ", "))
	fmt.Fprintf(w, "- **Auth model:** %s", p.AuthModel)
	if p.IdP != "" {
		fmt.Fprintf(w, " (%s)", p.IdP)
	}
	fmt.Fprintln(w)
	fmt.Fprintf(w, "- **Server request handling:** %v · **Audit sink:** %v · **IaC:** %v\n",
		p.HasServerRequestHandling, p.HasAuditSink, p.HasIaC)
	if p.Narrative != "" {
		fmt.Fprintf(w, "- **Summary:** %s\n", p.Narrative)
	}
	confirm := "deterministic detection"
	if p.LLMConfirmed {
		confirm = "deterministic detection + LLM confirmation"
	}
	fmt.Fprintf(w, "- **Classified by:** %s\n", confirm)
	fmt.Fprintln(w)
}

// writeLocationMarkdown renders the WHERE for a finding: concrete match
// locations when the rule found the mechanism, or — for an absent-mechanism
// FAIL/PARTIAL — the anchor locations where it should live plus the search
// scope, so every gating verdict points at a real place in the repo.
func writeLocationMarkdown(w io.Writer, f model.Finding) {
	matches, anchors := splitEvidence(f.Evidence)
	if len(matches) > 0 {
		fmt.Fprintln(w, "- **Evidence:**")
		for _, e := range matches {
			fmt.Fprintf(w, "  - `%s`\n", evidenceLoc(e))
		}
		return
	}
	if len(anchors) == 0 && f.SearchScope == nil {
		return
	}
	fmt.Fprintln(w, "- **Location:** mechanism not found; expected where it would live:")
	for _, e := range anchors {
		fmt.Fprintf(w, "  - `%s`\n", evidenceLoc(e))
	}
	if f.SearchScope != nil {
		fmt.Fprintf(w, "  - _%s_\n", searchScopeText(f.SearchScope))
	}
}

// evidenceLoc renders one evidence entry as file or file:line.
func evidenceLoc(e model.Evidence) string {
	if e.Line > 0 {
		return fmt.Sprintf("%s:%d", e.File, e.Line)
	}
	return e.File
}

// WriteMarkdown renders a report as a Markdown document suitable for handing to
// stakeholders or attaching as a pipeline artifact. Shape mirrors the demo
// report the team has already seen.
func WriteMarkdown(w io.Writer, r model.Report) {
	fmt.Fprintln(w, "# EPIC Compliance Reviewer — Report")
	fmt.Fprintln(w)
	fmt.Fprintf(w, "- **Tool:** %s %s\n", r.Metadata.Tool, r.Metadata.Version)
	fmt.Fprintf(w, "- **Spec:** %s\n", r.Metadata.SpecSource)
	fmt.Fprintf(w, "- **Repo:** `%s`\n", repoDisplay(r.Metadata))
	if r.Metadata.AppType != "" {
		fmt.Fprintf(w, "- **App type:** %s\n", r.Metadata.AppType)
	}
	if r.Metadata.ScannedAt != "" {
		fmt.Fprintf(w, "- **Scanned:** %s\n", r.Metadata.ScannedAt)
	}
	fmt.Fprintln(w)

	writeProfileMarkdown(w, r.Profile)

	// Summary table.
	fmt.Fprintln(w, "## Summary")
	fmt.Fprintln(w)
	fmt.Fprintln(w, "| Verdict | Count |")
	fmt.Fprintln(w, "|---|---:|")
	for _, v := range verdictOrder {
		fmt.Fprintf(w, "| %s | %d |\n", v, r.Summary.ByVerdict[v])
	}
	fmt.Fprintf(w, "| **Total** | **%d** |\n", r.Summary.Total)
	fmt.Fprintln(w)

	// Findings grouped by verdict, worst first.
	byVerdict := map[model.Verdict][]model.Finding{}
	for _, f := range r.Findings {
		byVerdict[f.Verdict] = append(byVerdict[f.Verdict], f)
	}
	fmt.Fprintln(w, "## Findings")
	fmt.Fprintln(w)
	for _, v := range verdictOrder {
		group := byVerdict[v]
		if len(group) == 0 {
			continue
		}
		sort.Slice(group, func(i, j int) bool {
			return group[i].Control.NISTID < group[j].Control.NISTID
		})
		fmt.Fprintf(w, "### %s (%d)\n\n", v, len(group))
		for _, f := range group {
			kind := ""
			if f.Kind == model.KindHard {
				kind = " · **HARD**"
			}
			fmt.Fprintf(w, "#### %s — %s%s\n\n", f.Control.NISTID, f.Control.Title, kind)
			// Every finding renders the same ordered fields regardless of verdict,
			// so the report reads consistently: requirement, the normalized
			// verdict/why line, what was checked, where, and PG&E disposition.
			fmt.Fprintf(w, "- **Requirement:** %s\n", f.Control.Requirement)
			fmt.Fprintf(w, "- **Verdict:** %s\n", reasonLine(f))
			if f.CheckedFor != "" {
				fmt.Fprintf(w, "- **Checked for:** %s\n", f.CheckedFor)
			}
			if f.InheritedFrom != "" {
				fmt.Fprintf(w, "- **Inherited from:** %s\n", f.InheritedFrom)
			}
			writeLocationMarkdown(w, f)
			if f.Remediation != "" {
				fmt.Fprintf(w, "- **Remediation:** %s\n", f.Remediation)
			}
			if disp := dispositionText(f); disp != "" {
				fmt.Fprintf(w, "- **PG&E disposition:** %s (%s)\n", disp, mandatoryLabel(f.Control))
			}
			if adv := strings.TrimSpace(f.Control.Advice); adv != "" {
				fmt.Fprintf(w, "- **Developer guidance:** %s\n", adv)
			}
			fmt.Fprintln(w)
		}
	}
}
