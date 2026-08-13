# VEG Onboarding Portal — EPIC Onboarding Runbook (our side)

**For:** us (EPIC team). What EPIC already provides, what we configure, and the order to bring vm-onboarding up. The two external asks live in separate docs:
- `vm-onboarding-access-request-tenant-team.md` — the **PGEEXTDIR** tenant team (one pipeline SPN with roles on both subs, Entra app, my state/KV access)
- `vm-onboarding-access-request-ado-team.md` — the ADO team (the `AzureExt` + `AzureExt-Dev` service connections)

**Repo:** `projects/vm-onboarding/` on the **`epic` branch**. Backend `pge.backend/` (Azure Container Apps), frontend `pge.frontend/` (static site). Tenant **PGEEXTDIR** (`0ec5ddf3-8577-4207-9beb-26b37ec9b44b`), region westus2.

**Two subscriptions, four environments:**

| Environment | Subscription | Service connection | Resource group |
|---|---|---|---|
| dev  | nonprod | `AzureExt-Dev` | `rg-veg-dev`  |
| qa   | nonprod | `AzureExt-Dev` | `rg-veg-qa`   |
| uat  | prod    | `AzureExt`     | `rg-veg-uat`  |
| prod | prod    | `AzureExt`     | `rg-veg-prod` |

---

## Already built in EPIC (no further code needed)

- **Two contracts:** `pge.backend/.pipeline/epic.json` (`appType: infra`, `.infra` from published Azure modules) + `pge.frontend/.pipeline/epic.json` (`appType: react`, code-only).
- **Per-environment cloud config:** epic.json `cloud.environments.<env>` maps each of dev/qa/uat/prod to its service connection + resource group. The **subscription is NOT in epic.json** — it comes from whichever service connection is active (nonprod connection → nonprod sub, prod connection → prod sub). Resolved in the orchestrator (connection) + `infra/azure.yml` (`az account show`).
- **UAT is a first-class EPIC environment** (added to the orchestrator env enum + epic-web New Run modal). Order: dev, test, qa, **uat**, stage, prod.
- **State co-located in the app RG:** state lives in each environment's own RG (`rg-veg-<env>`) in a per-env account (`vegonboardtfstate<env>`), container `tfstate`. Set per-env in epic.json (`stateResourceGroup` = the app RG, `stateStorageAccount`). With `bootstrapState: true` the pipeline creates the account inside the (pre-existing) app RG on the first run — no separate `rg-epic-tfstate`, no extra permissions beyond the Contributor the SPN already has on the RG.
- **Container image build:** backend `cloud.containerImage` block → staged apply (`terraform apply -target=ACR` → `az acr build` → full apply with the built tag). In `infra/azure.yml`.
- **Static-site deploy:** `deploy/azure/static/main.yml` + appType dispatch in `deploy/main.yml` → uploads the built SPA to Storage `$web`. Per-env storage account resolved from `cloud.environments.<env>.staticStorageAccount`.
- **Frontend storage naming (shared convention):** the backend `.infra` provisions the frontend static-site storage account as `<base><environment>` (base `onboardxappfe` → `onboardxappfedev/qa/uat/prod`). The frontend epic.json lists the **same** names per env. One formula on both sides, so they always match (backend owns the account; frontend just uploads).
- **Secret model:** generated (`random_*`) + derived secrets written to Key Vault by Terraform; the Graph client secret + Logz.io token are **hand-loaded** and referenced by constructed KV id (never enter state). Entra app **pre-exists** (no azuread provider).

> These epic-pipeline changes are **working-tree, not yet committed** — commit before a live run.

---

## Prerequisites (from the other two teams)

1. **Tenant team** assigns the pipeline SPN (client ID `0e115603-…`) its roles on **both** subscriptions, confirms the Entra app (client id + secret + consented Graph perms), ensures the four RGs exist, and grants my account the access to build state storage + load KV secrets.
2. **ADO team** provides (or lets me create) the **`AzureExt`** (prod sub) and **`AzureExt-Dev`** (nonprod sub) service connections — both use the **same** SPN (client ID `0e115603-…`), differing only by subscription.

---

## Our steps, in order

### 1. Terraform state storage — automatic (co-located in the app RG)

The backend epic.json sets **`"bootstrapState": true`** and points state at each environment's own RG (`stateResourceGroup` = `rg-veg-<env>`, `stateStorageAccount` = `vegonboardtfstate<env>`). On the first run EPIC's infra stage **creates that storage account inside the (already-existing) app RG and no-ops thereafter** (first run == 100th run). **No manual bootstrap step, no separate `rg-epic-tfstate`.** The state storage is managed imperatively by the pipeline (it's where Terraform state lives, so it can't itself be in Terraform state).

**Requirement this places on the SPN:** just **Contributor on each `rg-veg-*` RG** — which it already has to deploy the app there. No subscription-scoped grant and no state RG are needed for state. The only prerequisite is that the four `rg-veg-*` RGs **already exist** (the `.infra` reads them as data sources).

If a chosen state account name is globally taken, pick another and update `stateStorageAccount` for that environment.

### 2. Fill in tfvars — `pge.backend/.infra/terraform.auto.tfvars`
- **AMPS tags (validated — real values required):** `appid`, `owner` (exactly 3 LANIDs), `order`.
- **`azure_graph_client_id`** = the pre-existing PGEEXTDIR Entra app's client ID.
- **`entra_tenant_id`** = `0ec5ddf3-8577-4207-9beb-26b37ec9b44b` (already set).
- **`enable_logzio`** = `true` only if loading a Logz.io token.
- **`frontend_storage_account_base_name`** (`onboardxappfe`): confirm `<base><env>` for all four envs is globally free (`onboardxappfedev/qa/uat/prod`) — these must match the frontend epic.json.
- **`resource_group_name`** is supplied per-env by EPIC (from epic.json) — leave it out of tfvars.

### 3. Commit the working-tree changes
epic-pipeline (per-env connection/sub/RG resolution, uat env, image build, static deploy) + epic-web (uat option) + vm-onboarding (contracts, `.infra`). *(User manages commits.)*

### 4. First run — backend infra **plan** (start with dev)
Trigger the backend app in EPIC: environment = **dev**, infrastructure action = **plan**. Validates the whole module composition against real Azure (nonprod sub, via `AzureExt-Dev`) with zero risk. Fix anything the plan surfaces, then apply. Repeat per environment as you promote.

### 5. Backend apply (per environment)
Infrastructure action = **apply**. The staged apply builds + pushes the image and stands up all resources incl. the Container App, in that env's RG + sub.

### 6. Hand-load the two KV secrets (per environment's vault)
After each env's vault exists (created in step 5), before its container app revision must resolve them:
```bash
az keyvault secret set --vault-name <kv-name> --name azure-graph-client-secret --value "<...>"
az keyvault secret set --vault-name <kv-name> --name logzio-token --value "<...>"   # only if enable_logzio=true
```
(Vault name is a Terraform output from step 5.)

### 7. Frontend — build + deploy (per environment)
Trigger the frontend app with build + deploy on, per environment. It builds the Vite SPA and uploads to `$web` of that env's storage account (`onboardxappfe<env>`) via the static-deploy path.

---

## Known follow-ups / risks

- **Secrets in git history (deferred):** the original repo committed live secrets (tfstate, Logz token) tied to the **old dev tenant** — now invalid for PGEEXTDIR, but must still be **rotated**, not just deleted. The Review stage will hard-fail on them until then.
- **New-tenant secret values:** the hand-loaded Graph client secret + Logz.io token must be the **PGEEXTDIR** values (the old dev-tenant values won't work).
- **App security posture:** HTTP-only App Gateway, public Postgres, `API_COOKIE_SECURE=false`, login leaks full user object, hardcoded `"cornflake-…"` fallback API key — all pre-existing, flagged for later.
- **Global-uniqueness names to confirm:** `vegonboardtfstatedev/qa/uat/prod` (state accounts) and `onboardxappfedev/qa/uat/prod` (frontend static sites).
