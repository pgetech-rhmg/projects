# Access Request — Azure DevOps Team

**For:** the team that administers the Azure DevOps organization/project where EPIC runs.
**Requestor:** _(your name / LANID)_
**Context:** the VEG Onboarding Portal deploys to Azure through EPIC's existing ADO pipelines. It targets the **PGEEXTDIR** external tenant, across **two subscriptions** (a nonprod sub for dev/qa and a prod sub for uat/prod). To reach them, EPIC needs **two** Azure Resource Manager service connections. This is the only ADO ask; all Azure/tenant grants are handled separately by the Azure tenant team.

---

## What I need

One of the following (either works):

**Option A — grant me the role, I create the connections.**
Grant me **Endpoint Administrator** (or **Endpoint Creator**), or **Project Administrator**, in **the existing ADO project that hosts the EPIC orchestrator/engine pipelines** (not a new or app-specific project). I'll create both service connections myself.

**Option B — you create the connections for me.**
Create the two service connections using the service-principal details I provide (below). Then no role grant to me is needed.

Either way, the connections are created **once at the project level** and are **reused by every app EPIC deploys to those subscriptions** — they are not specific to this application.

---

## The two service connections to create

Both are the same type and use the **same service principal** (one SPN with roles on both subscriptions); they differ only by subscription and name:

| Field | Nonprod connection | Prod connection |
|---|---|---|
| **Type** | Azure Resource Manager → **App registration or managed identity (manual)**, Credential = **Secret** | same |
| **Name** (must match exactly) | **`AzureExt-Dev`** | **`AzureExt`** |
| **Subscription ID** | _(nonprod sub — I'll provide)_ | _(prod sub — I'll provide)_ |
| **Tenant ID (Directory ID)** | `0ec5ddf3-8577-4207-9beb-26b37ec9b44b` | `0ec5ddf3-8577-4207-9beb-26b37ec9b44b` |
| **Service Principal ID (client ID)** | `0e115603-675d-4c4f-b347-40595d06b6a5` | `0e115603-675d-4c4f-b347-40595d06b6a5` (same) |
| **Service Principal key (client secret)** | _(I'll provide — same secret)_ | _(I'll provide — same secret)_ |

The app's epic.json maps environments to these connections: `dev`/`qa` → `AzureExt-Dev`, `uat`/`prod` → `AzureExt`.

Both connections use the same client ID + secret; only the **Subscription ID** differs. I will supply the client secret + both subscription IDs once the Azure tenant team confirms the SPN's role assignments.

---

## Why "manual" + Secret / two separate connections

- An ADO organization is tied to one Entra tenant for **sign-in**, but its service connections can deploy to **any** tenant — each connection authenticates with its own service principal and an explicitly-set Tenant ID. This app deploys to PGEEXTDIR, a different tenant than the ADO org's home tenant, which is why it needs its own connections (rather than a default `Azure` connection).
- **"Manual" + Secret** (not Workload Identity Federation): WIF requires a federated-credential trust between the ADO org's issuer and the app registration, which is awkward-to-unsupported across tenant boundaries. A manually-entered client secret authenticates the SPN directly against the external tenant, sidestepping the cross-tenant guest/consent problem. Ignore the "Recommended" badge on WIF for this case.
- **Two connections, not one:** the two environments live in two different subscriptions. EPIC selects the connection per environment from epic.json, and the subscription then comes from whichever connection is active (epic.json does **not** restate subscription IDs).
