# Access Request — Azure DevOps Team

**For:** the team that administers the Azure DevOps organization/project where EPIC runs.
**Requestor:** _(your name / LANID)_
**Context:** the VEG Onboarding Portal deploys to Azure through EPIC's existing ADO pipelines. To reach its Azure tenant, EPIC needs **one Azure Resource Manager service connection**. This is the only ADO ask; all Azure/tenant grants are handled separately by the Azure tenant team.

---

## What I need

One of the following (either works):

**Option A — grant me the role, I create the connection.**
Grant me **Endpoint Administrator** (or **Endpoint Creator**), or **Project Administrator**, in **the existing ADO project that hosts the EPIC orchestrator/engine pipelines** (not a new or app-specific project). I'll create the service connection myself.

**Option B — you create the connection for me.**
Create the service connection using the service-principal details I provide (below). Then no role grant to me is needed.

Either way, the connection is created **once at the project level** and is **reused by every app EPIC deploys to this Azure tenant** — it is not specific to this application.

---

## The service connection to create

- **Type:** Azure Resource Manager → **Service principal (manual)**
  *(the "manual" variant is required so the target Tenant ID can be entered explicitly — this connection targets a tenant that is **not** the ADO org's home tenant)*
- **Name:** **`AzureExt`**  *(must match exactly — the app's config references this name)*
- **Subscription ID:** `dfb05368-7ac8-4c52-8da6-c979315bbb7b`
- **Tenant ID:** _(the external tenant's Directory ID — I'll provide it)_
- **Service Principal ID (client ID):** _(I'll provide from the Azure tenant team)_
- **Service Principal key (client secret):** _(I'll provide)_

I will supply the client ID / secret / tenant ID / subscription ID once the Azure tenant team issues the service principal.

---

## Why "manual" / a separate connection

An ADO organization is tied to one Entra tenant for **sign-in**, but its service connections can deploy to **any** tenant — each connection just authenticates with its own service principal and an explicitly-set Tenant ID. This app deploys to a different Azure tenant than the ADO org's home tenant, which is why it needs its own `AzureExt` connection (rather than reusing a default `Azure` connection).
