// Package profile is the "evaluate" step: before any control rule runs, it
// inspects the repository to determine what the app IS (a client-side SPA, a
// server API, infrastructure-as-code, a library), what it HAS (server request
// handling, an audit sink, IaC), and what it DOES for authentication (delegated
// SSO vs a local login vs none).
//
// That classification lets the engine disposition each control to the
// architectural layer that actually enforces it. A client-side SPA that
// delegates login to an identity provider cannot own account-lockout, a
// system-use banner, concurrent-session caps, or server-side authorization and
// audit-of-record — those are enforced by the IdP, the backend API, or the
// hosting infrastructure. Without this step the reviewer grades every repo
// against the full framework and reports false FAILs for controls the repo
// structurally cannot satisfy.
//
// Detection is deterministic (signature-based over the indexed repo) and, when
// an LLM is configured, refined by a confirmation pass. The deterministic
// result is always the floor: an LLM error never changes the classification,
// so offline CI stays reproducible.
package profile

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
)

// Repo is the read-only view the profiler needs. It is a subset of the
// engine's repo view (rules.Repo satisfies it too), kept separate so the
// profile package depends only on model.
type Repo interface {
	Files(patterns ...string) []string
	Grep(pattern string, filePatterns ...string) []model.Evidence
	AppType() string
}

// LLM is the optional reasoning backend used to confirm/refine the profile.
// It is intentionally a single free-text call so the profiler can prompt for a
// structured classification without coupling to the rules' verdict interface.
type LLM interface {
	Ask(ctx context.Context, system, user string) (string, error)
}

var sourcePatterns = []string{"*.ts", "*.js", "*.jsx", "*.tsx", "*.go", "*.cs", "*.py", "*.java", "*.rb", "*.php"}

// Detect builds a Profile from the repository. When llm is non-nil it runs a
// confirmation pass that may refine the narrative and classification; on any
// LLM error the deterministic profile stands.
func Detect(ctx context.Context, repo Repo, llm LLM) model.Profile {
	p := detectDeterministic(repo)
	p.Narrative = narrate(p)
	if llm != nil {
		refineWithLLM(ctx, llm, &p)
	}
	return p
}

// detectDeterministic runs signature-based classification over the repo.
func detectDeterministic(repo Repo) model.Profile {
	var p model.Profile
	var sig []string

	hasPkg := len(repo.Files("package.json")) > 0

	// ---- App kind(s) ----
	isSPA := hasPkg && has(repo, `"@angular/core"|"react"\s*:|"vue"\s*:|"svelte"\s*:`, "package.json")
	if isSPA {
		p.Kinds = append(p.Kinds, model.KindFrontendSPA)
		sig = append(sig, "SPA framework dependency in package.json")
	}

	server := detectServer(repo, &sig)
	p.HasServerRequestHandling = server
	if server {
		p.Kinds = append(p.Kinds, model.KindBackendAPI)
	}

	if len(repo.Files("*.tf")) > 0 {
		p.Kinds = append(p.Kinds, model.KindIaC)
		p.HasIaC = true
		sig = append(sig, "Terraform (*.tf) present")
	}

	if len(p.Kinds) == 0 {
		if hasPkg || len(repo.Files("go.mod", "*.csproj", "pyproject.toml", "pom.xml")) > 0 {
			p.Kinds = append(p.Kinds, model.KindLibrary)
			sig = append(sig, "package manifest but no app/server/IaC signals")
		} else {
			p.Kinds = append(p.Kinds, model.KindUnknown)
		}
	}

	// ---- Auth model ----
	switch {
	case has(repo, `@azure/msal|PublicClientApplication|loginRedirect|msal-browser|msal-angular`, append(sourcePatterns, "package.json")...):
		p.AuthModel = model.AuthDelegatedSSO
		p.IdP = "Microsoft Entra ID (MSAL)"
		sig = append(sig, "MSAL / Entra ID SSO integration")
	case has(repo, `react-oauth2-code-pkce|oidc-client|openid-client|keycloak-js|@auth0/`, append(sourcePatterns, "package.json")...):
		p.AuthModel = model.AuthDelegatedSSO
		p.IdP = "external OIDC provider"
		sig = append(sig, "OIDC/PKCE SSO integration")
	case has(repo, `AddJwtBearer|AddMicrosoftIdentityWebApi|Microsoft\.Identity\.Web|JwtBearerDefaults|oauth2ResourceServer|spring-boot-starter-oauth2-resource-server|aws-jwt-verify|jwks-rsa|passport-jwt|express-jwt`,
		append(sourcePatterns, "*.csproj", "package.json", "pom.xml", "build.gradle")...):
		// Server-side resource server that VALIDATES externally-issued bearer/JWT
		// tokens. It owns no login surface — login, account lockout, use-notification
		// banner, and session limits all live in the external IdP — so this is
		// delegated-SSO for disposition purposes (the IdP-layer controls inherit).
		p.AuthModel = model.AuthDelegatedSSO
		if has(repo, `Microsoft\.Identity|microsoftonline|AzureAd|msal|entra`, append(sourcePatterns, "*.csproj", "*.json")...) {
			p.IdP = "Microsoft Entra ID"
		} else {
			p.IdP = "external OIDC provider (JWT bearer)"
		}
		sig = append(sig, "server-side JWT/OIDC bearer-token validation")
	case has(repo, `passport-local|bcrypt|comparePassword|type=["']password["']|LoginController|signInWithPassword`, append(sourcePatterns, "*.html")...):
		p.AuthModel = model.AuthLocalLogin
		sig = append(sig, "local credential/login handling")
	default:
		p.AuthModel = model.AuthNone
	}

	// ---- Audit sink ----
	if has(repo, `pino|winston|serilog|slog\.|zap\.|logrus|ILogger|structlog`, sourcePatterns...) {
		p.HasAuditSink = true
		sig = append(sig, "structured logging framework")
	}

	p.Signals = sig
	return p
}

// detectServer reports whether the repo contains server-side request handling
// across the common stacks EPIC apps use, recording the matched signal.
func detectServer(repo Repo, sig *[]string) bool {
	checks := []struct {
		pattern string
		files   []string
		label   string
	}{
		{`\[ApiController\]|MapControllers|WebApplication\.CreateBuilder|Microsoft\.AspNetCore`, []string{"*.cs"}, ".NET ASP.NET Core API"},
		{`"express"|"fastify"|"@nestjs/core"|"koa"`, []string{"package.json"}, "Node server framework"},
		{`exports\.handler|export const handler|export async function handler`, []string{"*.js", "*.ts", "*.mjs"}, "Lambda handler"},
		{`net/http|gin-gonic|http\.HandleFunc|chi\.NewRouter|echo\.New\(`, []string{"*.go"}, "Go HTTP server"},
		{`Flask\(|@app\.route|FastAPI\(|django`, []string{"*.py"}, "Python web framework"},
		{`@RestController|@SpringBootApplication`, []string{"*.java"}, "Spring API"},
	}
	for _, c := range checks {
		if has(repo, c.pattern, c.files...) {
			*sig = append(*sig, c.label)
			return true
		}
	}
	return false
}

// has reports whether the pattern matches anywhere in the given file patterns.
func has(repo Repo, pattern string, files ...string) bool {
	return len(repo.Grep(pattern, files...)) > 0
}

// narrate builds a deterministic one-line description of the app.
func narrate(p model.Profile) string {
	var kinds []string
	for _, k := range p.Kinds {
		kinds = append(kinds, string(k))
	}
	desc := strings.Join(kinds, " + ")
	switch p.AuthModel {
	case model.AuthDelegatedSSO:
		idp := p.IdP
		if idp == "" {
			idp = "an external identity provider"
		}
		desc += fmt.Sprintf("; authentication delegated to %s (no login surface in this repo)", idp)
	case model.AuthLocalLogin:
		desc += "; owns a local login/credential surface"
	case model.AuthNone:
		desc += "; no interactive user authentication in this repo"
	}
	if !p.HasServerRequestHandling {
		desc += "; no server-side request handling (authZ and audit-of-record belong to the backing API)"
	}
	return desc
}

// llmProfileReply is the structured refinement we ask the model for.
type llmProfileReply struct {
	Kinds     []string `json:"kinds"`
	AuthModel string   `json:"authModel"`
	IdP       string   `json:"idp"`
	Narrative string   `json:"narrative"`
}

// refineWithLLM asks the model to confirm/adjust the deterministic profile.
// Deterministic classification is the floor: the LLM may add app kinds and
// supply a narrative, and may correct the auth model/IdP, but an error or an
// unparseable reply leaves the deterministic profile untouched.
func refineWithLLM(ctx context.Context, llm LLM, p *model.Profile) {
	system := "You are a software architecture classifier for a compliance reviewer. " +
		"Given detection signals from a repository, classify the app. Respond ONLY with compact JSON: " +
		`{"kinds":["frontend-spa|backend-api|iac|library"],"authModel":"delegated-sso|local-login|none","idp":"<name or empty>","narrative":"one or two sentences describing what the app is, what it has, and how it authenticates"}. ` +
		"Be conservative: a client-side SPA that redirects to an IdP has authModel=delegated-sso and no login surface of its own."

	var b strings.Builder
	fmt.Fprintf(&b, "Detected kinds: %v\n", p.Kinds)
	fmt.Fprintf(&b, "Detected auth model: %s (IdP: %s)\n", p.AuthModel, p.IdP)
	fmt.Fprintf(&b, "Has server request handling: %v\n", p.HasServerRequestHandling)
	fmt.Fprintf(&b, "Has audit sink: %v\n", p.HasAuditSink)
	fmt.Fprintf(&b, "Has IaC: %v\n", p.HasIaC)
	fmt.Fprintf(&b, "Signals: %s\n", strings.Join(p.Signals, "; "))

	raw, err := llm.Ask(ctx, system, b.String())
	if err != nil {
		p.Narrative += " [profile LLM confirmation skipped: " + truncate(err.Error(), 200) + "]"
		return
	}
	reply, ok := parseProfileReply(raw)
	if !ok {
		return // keep deterministic profile
	}
	p.LLMConfirmed = true
	if reply.Narrative != "" {
		p.Narrative = reply.Narrative
	}
	if am := normalizeAuth(reply.AuthModel); am != "" {
		p.AuthModel = am
		p.IdP = reply.IdP
	}
	for _, k := range reply.Kinds {
		if kind := normalizeKind(k); kind != "" && !p.Has(kind) {
			p.Kinds = append(p.Kinds, kind)
		}
	}
}

func parseProfileReply(raw string) (llmProfileReply, bool) {
	s := raw
	if i := strings.Index(s, "{"); i >= 0 {
		if j := strings.LastIndex(s, "}"); j > i {
			s = s[i : j+1]
		}
	}
	var r llmProfileReply
	if err := json.Unmarshal([]byte(s), &r); err != nil {
		return llmProfileReply{}, false
	}
	return r, true
}

func normalizeAuth(s string) model.AuthModel {
	switch model.AuthModel(strings.ToLower(strings.TrimSpace(s))) {
	case model.AuthDelegatedSSO:
		return model.AuthDelegatedSSO
	case model.AuthLocalLogin:
		return model.AuthLocalLogin
	case model.AuthNone:
		return model.AuthNone
	default:
		return ""
	}
}

func normalizeKind(s string) model.AppKind {
	switch model.AppKind(strings.ToLower(strings.TrimSpace(s))) {
	case model.KindFrontendSPA:
		return model.KindFrontendSPA
	case model.KindBackendAPI:
		return model.KindBackendAPI
	case model.KindIaC:
		return model.KindIaC
	case model.KindLibrary:
		return model.KindLibrary
	default:
		return ""
	}
}

func truncate(s string, n int) string {
	if len(s) > n {
		return s[:n] + "…"
	}
	return s
}
