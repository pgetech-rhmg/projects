package profile

import (
	"context"
	"regexp"
	"testing"

	"github.com/pgetech/epic-compliance/internal/model"
)

// fakeRepo maps regex patterns to canned matches, and file globs to canned
// file lists, so profiler tests stay off the filesystem.
type fakeRepo struct {
	appType string
	// content tokens the repo "contains" (matched with the same regex semantics
	// the real repo uses).
	content []string
	// files present, by base name.
	files []string
}

func (r fakeRepo) AppType() string { return r.appType }

func (r fakeRepo) Files(patterns ...string) []string {
	if len(patterns) == 0 {
		return r.files
	}
	var out []string
	for _, f := range r.files {
		for _, p := range patterns {
			if ok, _ := match(p, f); ok {
				out = append(out, f)
				break
			}
		}
	}
	return out
}

func (r fakeRepo) Grep(pattern string, _ ...string) []model.Evidence {
	re, err := regexp.Compile("(?i)" + pattern)
	if err != nil {
		return nil
	}
	var out []model.Evidence
	for _, c := range r.content {
		if re.MatchString(c) {
			out = append(out, model.Evidence{File: "fake", Line: 1, Snippet: c})
		}
	}
	return out
}

// match is filepath.Match-ish for base-name globs used in tests.
func match(pattern, name string) (bool, error) {
	// crude suffix match for "*.ext", exact otherwise — enough for tests.
	if len(pattern) > 1 && pattern[0] == '*' {
		suf := pattern[1:]
		return len(name) >= len(suf) && name[len(name)-len(suf):] == suf, nil
	}
	return pattern == name, nil
}

// TestSPADelegatedSSO is the epic-web case: an Angular SPA whose auth is MSAL.
func TestSPADelegatedSSO(t *testing.T) {
	repo := fakeRepo{
		files:   []string{"package.json", "app.ts"},
		content: []string{`"@angular/core": "20.0.0"`, `import { MsalService } from '@azure/msal-angular'`, `loginRedirect`},
	}
	p := Detect(context.Background(), repo, nil)

	if !p.Has(model.KindFrontendSPA) {
		t.Errorf("expected frontend-spa kind, got %v", p.Kinds)
	}
	if p.AuthModel != model.AuthDelegatedSSO {
		t.Errorf("auth model: got %s, want delegated-sso", p.AuthModel)
	}
	if p.HasServerRequestHandling {
		t.Error("SPA should not be detected as server request handling")
	}
}

// TestBackendAPINotInherited verifies a .NET API keeps server/authZ controls.
func TestBackendAPINotInherited(t *testing.T) {
	repo := fakeRepo{
		files:   []string{"Program.cs", "AppsController.cs"},
		content: []string{`[ApiController]`, `WebApplication.CreateBuilder`, `[Authorize]`},
	}
	p := Detect(context.Background(), repo, nil)
	if !p.HasServerRequestHandling {
		t.Fatal("expected server request handling for a .NET API")
	}
	if inherited, _ := Disposition("AC-03-00", p); inherited {
		t.Error("AC-03 (server authZ) must NOT be inherited when the repo IS the server")
	}
	if inherited, _ := Disposition("CM-07-00", p); inherited {
		t.Error("CM-07 (least functionality) must be graded in-repo when the repo runs a server")
	}
}

// TestBackendAPIJwtBearerIsDelegatedSSO is the epic-api case: a .NET resource
// server that VALIDATES Entra ID bearer tokens. It owns server request handling
// (so AC-03 authZ is graded in-repo) but delegates login to the IdP, so the
// IdP-layer controls (lockout/banner/session-cap/authN) inherit as N/A rather
// than false-failing.
func TestBackendAPIJwtBearerIsDelegatedSSO(t *testing.T) {
	repo := fakeRepo{
		files: []string{"Program.cs", "Epic.Api.csproj", "appsettings.json"},
		content: []string{
			`[ApiController]`, `WebApplication.CreateBuilder`,
			`.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(...)`,
			`"AzureAd": { "TenantId": "..." }`,
		},
	}
	p := Detect(context.Background(), repo, nil)

	if !p.HasServerRequestHandling {
		t.Fatal("expected server request handling for a .NET API")
	}
	if p.AuthModel != model.AuthDelegatedSSO {
		t.Errorf("auth model: got %s, want delegated-sso (JWT bearer resource server)", p.AuthModel)
	}
	if p.IdP != "Microsoft Entra ID" {
		t.Errorf("idp: got %q, want %q", p.IdP, "Microsoft Entra ID")
	}
	// IdP-layer controls inherit (no login surface here): AC-07 lockout, AC-08
	// banner, AC-10 concurrent-session cap, IA-02 authN (canonical worksheet IDs).
	for _, id := range []string{"AC-07-00", "AC-08-00", "AC-10-00", "IA-02-00"} {
		if inherited, _ := Disposition(id, p); !inherited {
			t.Errorf("%s must be inherited from the IdP for a token-validating resource server", id)
		}
	}
	// ... but server-owned controls are still graded in-repo.
	if inherited, _ := Disposition("AC-03-00", p); inherited {
		t.Error("AC-03 (server authZ) must be graded in-repo — the API IS the server")
	}
	if inherited, _ := Disposition("CM-07-00", p); inherited {
		t.Error("CM-07 (least functionality) must be graded in-repo when the repo runs a server")
	}
}

// TestDispositionSPA is the core behavior: on an SSO SPA with no server/IaC,
// IdP/server/IaC/pipeline controls are all inherited (not graded).
func TestDispositionSPA(t *testing.T) {
	p := model.Profile{
		Kinds:     []model.AppKind{model.KindFrontendSPA},
		AuthModel: model.AuthDelegatedSSO,
		IdP:       "Microsoft Entra ID (MSAL)",
	}
	cases := map[string]bool{
		"AC-07-00": true,  // lockout -> IdP
		"AC-08-00": true,  // banner -> IdP
		"AC-10-00": true,  // concurrent sessions -> IdP
		"IA-02-00": true,  // authN -> IdP
		"AC-03-00": true,  // server authZ -> backing API
		"AU-03-00": true,  // audit content -> backing API
		"SC-08-00": true,  // TLS -> IaC
		"SA-10-01": true,  // integrity -> pipeline
		"CM-07-00": true,  // least functionality (ports/services) -> host baseline
		"CM-06-00": false, // not in the layer map -> always graded in-repo
	}
	for id, want := range cases {
		got, from := Disposition(id, p)
		if got != want {
			t.Errorf("Disposition(%s): got inherited=%v, want %v", id, got, want)
		}
		if got && from == "" {
			t.Errorf("Disposition(%s): inherited but no attribution", id)
		}
	}
}

// TestDispositionLocalLoginOwnsIdP verifies an app with its OWN login surface
// is NOT let off the hook for lockout/banner — those are graded in-repo.
func TestDispositionLocalLoginOwnsIdP(t *testing.T) {
	p := model.Profile{
		Kinds:     []model.AppKind{model.KindBackendAPI},
		AuthModel: model.AuthLocalLogin,
	}
	if inherited, _ := Disposition("AC-07-00", p); inherited {
		t.Error("AC-07 (lockout) must be graded in-repo when the app owns a local login")
	}
}
