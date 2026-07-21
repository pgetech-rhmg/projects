package output

import (
	"fmt"
	"io"
	"sort"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
)

// verdictOrder controls display grouping in the text report.
var verdictOrder = []model.Verdict{
	model.VerdictFail, model.VerdictPartial, model.VerdictPass,
	model.VerdictManual, model.VerdictNA,
}

// repoDisplay is the repo identifier shown in reports: the derived RepoName
// (just the repo, e.g. "epic-web"), falling back to the full RepoPath for
// reports produced before RepoName existed.
func repoDisplay(m model.Metadata) string {
	if m.RepoName != "" {
		return m.RepoName
	}
	return m.RepoPath
}

var verdictMark = map[model.Verdict]string{
	model.VerdictPass:    "PASS   ",
	model.VerdictPartial: "PARTIAL",
	model.VerdictFail:    "FAIL   ",
	model.VerdictNA:      "N/A    ",
	model.VerdictManual:  "MANUAL ",
}

// WriteText renders a human-readable summary for pipeline logs.
func WriteText(w io.Writer, r model.Report) {
	fmt.Fprintf(w, "EPIC Compliance Reviewer  %s\n", r.Metadata.Version)
	fmt.Fprintf(w, "Spec: %s\n", r.Metadata.SpecSource)
	fmt.Fprintf(w, "Repo: %s", repoDisplay(r.Metadata))
	if r.Metadata.AppType != "" {
		fmt.Fprintf(w, "  (appType=%s)", r.Metadata.AppType)
	}
	fmt.Fprintln(w)
	if len(r.Profile.Kinds) > 0 {
		kinds := make([]string, len(r.Profile.Kinds))
		for i, k := range r.Profile.Kinds {
			kinds[i] = string(k)
		}
		fmt.Fprintf(w, "Profile: %s | auth=%s", strings.Join(kinds, ","), r.Profile.AuthModel)
		if r.Profile.IdP != "" {
			fmt.Fprintf(w, " (%s)", r.Profile.IdP)
		}
		fmt.Fprintln(w)
	}
	fmt.Fprintln(w, "----------------------------------------------------------------")

	// Summary line.
	fmt.Fprintf(w, "Findings: %d  |  ", r.Summary.Total)
	for _, v := range verdictOrder {
		fmt.Fprintf(w, "%s=%d  ", v, r.Summary.ByVerdict[v])
	}
	fmt.Fprintln(w)
	fmt.Fprintln(w, "----------------------------------------------------------------")

	// Findings grouped by verdict, worst first.
	byVerdict := map[model.Verdict][]model.Finding{}
	for _, f := range r.Findings {
		byVerdict[f.Verdict] = append(byVerdict[f.Verdict], f)
	}
	for _, v := range verdictOrder {
		group := byVerdict[v]
		sort.Slice(group, func(i, j int) bool {
			return group[i].Control.NISTID < group[j].Control.NISTID
		})
		for _, f := range group {
			kind := ""
			if f.Kind == model.KindHard {
				kind = " [HARD]"
			}
			fmt.Fprintf(w, "[%s] %-9s %s%s\n", verdictMark[v], f.Control.NISTID, f.Control.Title, kind)
			// Consistent block for every verdict: why / checked-for / location /
			// disposition or remediation.
			fmt.Fprintf(w, "            %s\n", reasonLine(f))
			if f.CheckedFor != "" {
				fmt.Fprintf(w, "            Checked for: %s\n", f.CheckedFor)
			}
			if loc := locationText(f); loc != "" {
				fmt.Fprintf(w, "            Location:    %s\n", loc)
			}
			if f.Remediation != "" {
				fmt.Fprintf(w, "            Remediation: %s\n", f.Remediation)
			}
			if disp := dispositionText(f); disp != "" {
				fmt.Fprintf(w, "            Disposition: %s\n", disp)
			}
		}
	}
	fmt.Fprintln(w, "----------------------------------------------------------------")
}
