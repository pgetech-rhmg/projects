package profile

import (
	"fmt"

	"github.com/pgetech/epic-compliance/internal/model"
)

// layer is the architectural tier that enforces a control.
type layer string

const (
	// layerIdP — login, session, account lifecycle, and user-identity controls.
	// Owned by the app only when it has a login surface of its own; otherwise
	// enforced by the external identity provider.
	layerIdP layer = "idp"
	// layerServer — server-side authorization enforcement and audit-of-record.
	// A client-only app has neither; the backing API owns these.
	layerServer layer = "server"
	// layerIaC — transport/at-rest protection and host hardening, enforced in
	// infrastructure-as-code / at the hosting edge.
	layerIaC layer = "iac"
	// layerPipeline — build-time artifact integrity / supply-chain signing,
	// enforced by the EPIC pipeline rather than in app source.
	layerPipeline layer = "pipeline"
	// layerHost — least-functionality of ports/protocols/services. Only a repo
	// that runs a server owns listening ports; a client-only app opens none, so
	// this is enforced by the host/platform baseline.
	layerHost layer = "host"
)

// controlLayer maps each code-checkable control to the layer that enforces it.
// Controls absent from this map are always evaluated in-repo (their rule runs
// regardless of profile). This is the auditable "which layer owns what" table
// — the judgment the profiling step exists to encode.
//
// Control IDs are the CANONICAL NIST 800-53 ids from the AI-DLC UCF worksheet
// (see rules/controls.go) — they supersede the earlier shifted-by-one IDs.
var controlLayer = map[string]layer{
	// IdP: login/session/account/identity.
	"AC-07-00": layerIdP, // account lockout
	"AC-08-00": layerIdP, // system-use notification banner (on the logon page)
	"AC-10-00": layerIdP, // concurrent-session limit
	"IA-02-00": layerIdP, // identification & authentication of org users
	"AC-02-04": layerIdP, // account-management audit actions

	// Server: authZ enforcement + audit-of-record.
	"AC-03-00": layerServer, // server-side access enforcement
	"AU-03-00": layerServer, // audit-record content (six fields)
	"AU-08-00": layerServer, // UTC time stamps on audit records
	"AU-10-00": layerServer, // non-repudiation attribution in audit
	"AU-12-00": layerServer, // audit-record generation (security events)

	// IaC / hosting edge.
	"SC-08-00": layerIaC, // TLS in transit (edge termination)
	"SC-28-00": layerIaC, // encryption at rest

	// Pipeline / supply chain.
	"SA-10-01": layerPipeline, // software/artifact integrity verification

	// Host / platform baseline: least-functionality of ports/protocols/services.
	"CM-07-00": layerHost, // least functionality (needless ports/services)
}

// Disposition reports whether the given control is INHERITED from another layer
// under this profile (and from where). When inherited==true the engine emits an
// N/A finding attributed to that layer and does NOT run the control's rule — so
// a client-side SPA is never failed for server/IdP/pipeline controls it cannot
// own. When inherited==false the rule runs as normal.
func Disposition(controlID string, p model.Profile) (inherited bool, from string) {
	l, ok := controlLayer[controlID]
	if !ok {
		return false, ""
	}
	switch l {
	case layerIdP:
		// Owned in-repo only when the app has its own login surface. When login
		// is delegated to an IdP, the IdP enforces these.
		if p.AuthModel == model.AuthDelegatedSSO {
			return true, idpName(p)
		}
		return false, ""
	case layerServer:
		// A repo with no server-side request handling cannot enforce
		// authorization or generate the system's audit-of-record.
		if !p.HasServerRequestHandling {
			return true, "the backing API (server-side enforcement & audit-of-record)"
		}
		return false, ""
	case layerIaC:
		// When the repo carries no IaC, transport/at-rest protection is enforced
		// by the hosting infrastructure defined elsewhere.
		if !p.HasIaC {
			return true, "the hosting infrastructure (edge TLS / at-rest encryption in IaC)"
		}
		return false, ""
	case layerPipeline:
		// Artifact integrity is a build/supply-chain concern. App/library repos
		// that do no server-side verification of their own inherit it from the
		// EPIC pipeline; a backend that verifies artifacts keeps the rule.
		if !p.HasServerRequestHandling {
			return true, "the EPIC pipeline (artifact signing / supply-chain integrity)"
		}
		return false, ""
	case layerHost:
		// A repo that runs no server opens no listening ports/services, so it
		// cannot own least-functionality of ports/protocols — the host/platform
		// baseline does. A server repo keeps the rule and is graded in-repo.
		if !p.HasServerRequestHandling {
			return true, "the host/platform baseline (least-functionality of ports/protocols/services)"
		}
		return false, ""
	}
	return false, ""
}

func idpName(p model.Profile) string {
	if p.IdP != "" {
		return fmt.Sprintf("the identity provider (%s)", p.IdP)
	}
	return "the identity provider (SSO)"
}
