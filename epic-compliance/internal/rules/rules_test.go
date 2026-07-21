package rules

import (
	"context"
	"regexp"
	"testing"

	"github.com/pgetech/epic-compliance/internal/model"
	"github.com/pgetech/epic-compliance/internal/profile"
)

// fakeRepo is an in-memory Repo for unit tests: it maps a regex-ish substring
// to canned evidence. It keeps rule tests independent of the filesystem.
type fakeRepo struct {
	appType string
	// hits maps a mechanism substring -> whether the repo "contains" it.
	present map[string]bool
}

func (r fakeRepo) AppType() string            { return r.appType }
func (r fakeRepo) Files(_ ...string) []string { return nil }

// Grep matches when the rule's pattern actually matches one of the registered
// "present" tokens — using the same regex semantics the real repo uses, so the
// test exercises the rule's real pattern rather than a loose substring proxy.
func (r fakeRepo) Grep(pattern string, _ ...string) []model.Evidence {
	re, err := regexp.Compile("(?i)" + pattern)
	if err != nil {
		return nil
	}
	for token, ok := range r.present {
		if ok && re.MatchString(token) {
			return []model.Evidence{{File: "fake.go", Line: 1, Snippet: token}}
		}
	}
	return nil
}

// TestRegistryMapsToCodeControls guards the invariants that (a) every rule maps
// to a known control, (b) no control has two rules, and (c) exactly the
// ClassCode controls have rules — manual/unspecified controls must NOT have one
// (the engine auto-emits those as MANUAL).
func TestRegistryMapsToCodeControls(t *testing.T) {
	seen := map[string]bool{}
	for _, r := range Registry {
		id := r.ControlID()
		c, ok := Controls[id]
		if !ok {
			t.Errorf("rule references unknown control %q", id)
			continue
		}
		if c.Class != model.ClassCode {
			t.Errorf("control %q has a rule but Class=%q (want %q)", id, c.Class, model.ClassCode)
		}
		if seen[id] {
			t.Errorf("duplicate rule for control %q", id)
		}
		seen[id] = true
	}
	// Every ClassCode control must have a rule.
	for id, c := range Controls {
		if c.Class == model.ClassCode && !seen[id] {
			t.Errorf("code control %q has no rule in the registry", id)
		}
	}
}

// TestCatalogSize documents that the full framework subset is present: the
// AI-DLC UCF worksheet's 69 app-applicable controls, plus any EPIC-added
// controls (flagged AddedByEPIC — e.g. IA-05 committed-secrets, which the
// worksheet does not contain but EPIC enforces).
func TestCatalogSize(t *testing.T) {
	worksheet, epicAdded := 0, 0
	for _, c := range Controls {
		if c.AddedByEPIC {
			epicAdded++
		} else {
			worksheet++
		}
	}
	if worksheet != 69 {
		t.Errorf("catalog has %d worksheet controls, want 69 (the AI-DLC UCF app-applicable subset)", worksheet)
	}
	if epicAdded != 1 {
		t.Errorf("catalog has %d EPIC-added controls, want 1 (IA-05 committed-secrets)", epicAdded)
	}
}

// ruleFor returns the registered rule for a control id (or nil).
func ruleFor(id string) Rule {
	for _, r := range Registry {
		if r.ControlID() == id {
			return r
		}
	}
	return nil
}

// TestAuthGatedRuleNAWithoutAuth verifies the access-control HARD rules report
// N/A (not FAIL) when the repo has no authentication surface. Account lockout
// is the canonical AC-07 (the worksheet's ID; the old catalog mislabeled it
// AC-06 = Least Privilege).
func TestAuthGatedRuleNAWithoutAuth(t *testing.T) {
	repo := fakeRepo{present: map[string]bool{}} // nothing present
	f := ruleFor("AC-07-00").Evaluate(context.Background(), repo, nil)
	if f.Verdict != model.VerdictNA {
		t.Fatalf("AC-07-00 with no auth: got %s, want N/A", f.Verdict)
	}
}

// TestAuthGatedRuleFailWithAuthNoMechanism verifies a FAIL when auth exists but
// the specific mechanism (lockout) does not — and that the absent-mechanism
// FAIL still carries a location (search scope), per the "file/line on every
// FAIL" requirement.
func TestAuthGatedRuleFailWithAuthNoMechanism(t *testing.T) {
	repo := fakeRepo{present: map[string]bool{"login": true, "password": true}}
	f := ruleFor("AC-07-00").Evaluate(context.Background(), repo, nil)
	if f.Verdict != model.VerdictFail {
		t.Fatalf("AC-07-00 with auth but no lockout: got %s, want FAIL", f.Verdict)
	}
	// The absent-mechanism FAIL must record where it looked (SearchScope), even
	// though there is no matching line, plus the anchor evidence from the auth
	// surface it did find.
	if f.SearchScope == nil {
		t.Error("absent-mechanism FAIL must carry a SearchScope location")
	}
	if !hasAnchorOrScope(f) {
		t.Error("absent-mechanism FAIL must carry an anchor or search-scope location")
	}
	if f.CheckedFor == "" {
		t.Error("every finding must set CheckedFor")
	}
}

// TestPresenceAbsentFailHasLocation verifies a presence-rule absent FAIL (here
// AU-08 UTC timestamps) records a SearchScope so the report can show WHERE the
// mechanism was looked for.
func TestPresenceAbsentFailHasLocation(t *testing.T) {
	repo := fakeRepo{present: map[string]bool{}} // no timestamp mechanism
	f := ruleFor("AU-08-00").Evaluate(context.Background(), repo, nil)
	if f.Verdict != model.VerdictFail {
		t.Fatalf("AU-08-00 with no timestamps: got %s, want FAIL", f.Verdict)
	}
	if f.SearchScope == nil {
		t.Error("absent-mechanism FAIL must carry a SearchScope location")
	}
}

func hasAnchorOrScope(f model.Finding) bool {
	if f.SearchScope != nil {
		return true
	}
	for _, e := range f.Evidence {
		if e.Role == model.EvidenceAnchor {
			return true
		}
	}
	return false
}

// TestSecretsRuleHardControl verifies EPIC's committed-secrets gate (IA-05-00):
// it is a HARD rule, PASSes a clean repo, and FAILs (deterministically, no LLM)
// when a real-looking secret is present.
func TestSecretsRuleHardControl(t *testing.T) {
	rule := ruleFor("IA-05-00")
	if rule == nil {
		t.Fatal("no rule registered for IA-05-00 (committed-secrets)")
	}
	if rule.Kind() != model.KindHard {
		t.Fatalf("IA-05-00 kind = %s, want HARD (must gate the pipeline)", rule.Kind())
	}
	// Confirm it is NOT profile-inherited under any profile (must always run,
	// every repo — a committed secret is never "someone else's layer").
	for _, p := range []model.Profile{
		{AuthModel: model.AuthDelegatedSSO},
		{HasServerRequestHandling: false},
		{HasIaC: false},
	} {
		if inh, _ := profile.Disposition("IA-05-00", p); inh {
			t.Errorf("IA-05-00 must not be layer-inherited (profile %+v); it should always run", p)
		}
	}

	clean := fakeRepo{present: map[string]bool{"const x = 1": true}}
	if f := rule.Evaluate(context.Background(), clean, nil); f.Verdict != model.VerdictPass {
		t.Errorf("clean repo: got %s, want PASS", f.Verdict)
	}

	// An AWS access-key id is a high-signal real secret; must FAIL with no LLM.
	leaked := fakeRepo{present: map[string]bool{"aws_key = AKIAIOSFODNN7EXAMPLE": true}}
	f := rule.Evaluate(context.Background(), leaked, nil)
	if f.Verdict != model.VerdictFail {
		t.Fatalf("repo with committed AWS key: got %s, want FAIL", f.Verdict)
	}
	if len(f.Evidence) == 0 {
		t.Error("secrets FAIL must carry evidence of the match")
	}

	// Regression (vm-onboarding #22055 passed IA-05 in error): a DEFINITE secret
	// — real Azure AccountKey — must FAIL and the LLM must NOT be able to
	// downgrade it, even when the LLM insists everything is a placeholder.
	// Also include a benign placeholder so a naive "all placeholders → PASS"
	// judgment would wrongly pass if the LLM were consulted.
	azureKey := fakeRepo{present: map[string]bool{
		"AZURE_STORAGE_CONNECTION_STRING=\"...AccountKey=rZfiXkKgNWxyEASgbYHvU8rQ2c8m72btxv8hVySQVRC1gYWqELPAEcw==;\"": true,
		"# API_MYSQL_PASSWORD=TO_LOAD_FROM_AWS_LEAVE_COMMENTED":                                                          true,
	}}
	f = rule.Evaluate(context.Background(), azureKey, alwaysPassLLM{})
	if f.Verdict != model.VerdictFail {
		t.Fatalf("definite Azure AccountKey with a downgrade-happy LLM: got %s, want FAIL (LLM must not downgrade a definite secret)", f.Verdict)
	}

	// Ambiguous-only (a placeholder password assignment) MAY be downgraded by the
	// LLM to PASS — this is the legitimate placeholder path.
	placeholder := fakeRepo{present: map[string]bool{"password = CHANGE_ME_PLEASE": true}}
	f = rule.Evaluate(context.Background(), placeholder, alwaysPassLLM{})
	if f.Verdict != model.VerdictPass {
		t.Errorf("ambiguous placeholder with LLM downgrade: got %s, want PASS", f.Verdict)
	}
	// ...but the SAME ambiguous match with NO LLM must stay FAIL (fail-closed).
	f = rule.Evaluate(context.Background(), placeholder, nil)
	if f.Verdict != model.VerdictFail {
		t.Errorf("ambiguous match, no LLM: got %s, want FAIL (fail-closed without a vetting LLM)", f.Verdict)
	}
}

// alwaysPassLLM is a test LLM that always votes PASS — used to prove a DEFINITE
// secret cannot be downgraded (the rule must not even consult it).
type alwaysPassLLM struct{}

func (alwaysPassLLM) Judge(_ context.Context, _ model.Control, _ []model.Evidence, _ string) (model.Verdict, string, error) {
	return model.VerdictPass, "all matches look like placeholders", nil
}

// TestGateFailedPolicy verifies only HARD FAILs gate under hard-fail.
func TestGateFailedPolicy(t *testing.T) {
	rep := model.Report{Findings: []model.Finding{
		{Kind: model.KindPresence, Verdict: model.VerdictFail}, // must NOT gate
	}}
	if rep.GateFailed("hard-fail") {
		t.Error("presence FAIL should not gate under hard-fail")
	}
	rep.Findings = append(rep.Findings, model.Finding{Kind: model.KindHard, Verdict: model.VerdictFail})
	if !rep.GateFailed("hard-fail") {
		t.Error("hard FAIL should gate under hard-fail")
	}
}
