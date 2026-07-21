# VEG Onboarding Portal — EPIC Onboarding Runbook (our side)

**For:** us (EPIC team). What EPIC already provides, what we configure, and the order to bring vm-onboarding up. The two external asks live in separate docs:
- `vm-onboarding-access-request-tenant-team.md` — the `pgeextdirdev` tenant team (SPN, roles, Entra app, my state/KV access)
- `vm-onboarding-access-request-ado-team.md` — the ADO team (the `AzureExt` service connection)

**Repo:** `projects/vm-onboarding/` on the **`epic` branch**. Backend `pge.backend/` (Azure Container Apps), frontend `pge.frontend/` (static site). Deploy sub `dfb05368-…`, RG `OnboardXAppResGrp`, region westus2.

---

## Already built in EPIC (no further code needed)

- **Two contracts:** `pge.backend/.pipeline/epic.json` (`appType: infra`, `.infra` from published Azure modules) + `pge.frontend/.pipeline/epic.json` (`appType: react`, code-only).
- **Multi-tenant service connection:** `cloud.azureServiceConnection` (default `'Azure'`); backend+frontend set `"AzureExt"`.
- **Per-subscription state convention:** account `epictfstate<sub>`, RG `rg-epic-tfstate`, container `tfstate` — all derived, all overridable. No state keys in epic.json.
- **Container image build:** backend `cloud.containerImage` block → staged apply (`terraform apply -target=ACR` → `az acr build` → full apply with the built tag). In `infra/azure.yml`.
- **Static-site deploy:** `deploy/azure/static/main.yml` + appType dispatch in `deploy/main.yml` → uploads the built SPA to Storage `$web`.
- **Secret model:** generated (`random_*`) + derived secrets written to Key Vault by Terraform; the Graph client secret + Logz.io token are **hand-loaded** and referenced by constructed KV id (never enter state). Entra app **pre-exists** (no azuread provider).

> These epic-pipeline changes are **working-tree, not yet committed** — commit before a live run.

---

## Prerequisites (from the other two teams)

1. **Tenant team** issues the service principal + roles, confirms the Entra app (client id + secret + consented Graph perms), and grants my account the access to build state storage + load KV secrets.
2. **ADO team** provides (or lets me create) the **`AzureExt`** service connection wired to that SPN + the external tenant id.

---

## Our steps, in order

### 1. Bootstrap the Terraform state storage (once, per subscription)

> **Skip if the tenant team created it (§3 Option A of the tenant-team doc).** If they created the RG/account/container, you don't run this — just confirm you have Storage Blob Data Contributor on the account and move to step 2. Run the commands below only if they chose Option B (grant you Contributor, you create it).

```bash
az login --tenant <EXTERNAL_TENANT_ID>
az account set --subscription dfb05368-7ac8-4c52-8da6-c979315bbb7b
az group create --name rg-epic-tfstate --location westus2
az storage account create \
  --name epictfstatedfb05368 --resource-group rg-epic-tfstate \
  --location westus2 --sku Standard_LRS \
  --min-tls-version TLS1_2 --allow-blob-public-access false
az storage container create --name tfstate --account-name epictfstatedfb05368 --auth-mode login
```
If `epictfstatedfb05368` is globally taken, pick another name and add `cloud.stateStorageAccount` to the backend epic.json.

### 2. Fill in tfvars — `pge.backend/.infra/terraform.auto.tfvars`
- **AMPS tags (validated — real values required):** `appid`, `owner` (exactly 3 LANIDs), `order`.
- **`azure_graph_client_id`** = the pre-existing Entra app's client ID (`4e490edc-…`).
- **`enable_logzio`** = `true` only if loading a Logz.io token.
- Confirm **`frontend_storage_account_name`** (`onboardxappfe`) is globally free — it must match `cloud.staticStorageAccount` in the frontend epic.json.

### 3. Commit the working-tree changes
epic-pipeline (image build, static deploy, state convention, multi-tenant) + vm-onboarding (contracts, `.infra`, removed old `terraform/`). *(User manages commits.)*

### 4. First run — backend infra **plan**
Trigger the backend app in EPIC with infrastructure action = **plan**. Validates the whole module composition against real Azure with zero risk. Fix anything the plan surfaces, then apply.

### 5. Backend apply
Infrastructure action = **apply**. The staged apply builds + pushes the image and stands up all resources incl. the Container App.

### 6. Hand-load the two KV secrets
After the vault exists (created in step 5), before the container app revision must resolve them:
```bash
az keyvault secret set --vault-name <kv-name> --name azure-graph-client-secret --value "<...>"
az keyvault secret set --vault-name <kv-name> --name logzio-token --value "<...>"   # only if enable_logzio=true
```
(Vault name is a Terraform output from step 5.)

### 7. Frontend — build + deploy
Trigger the frontend app with build + deploy on. It builds the Vite SPA and uploads to `$web` of `onboardxappfe` via the new static-deploy path.

---

## Known follow-ups / risks

- **Secrets in git history (deferred):** the original repo committed live secrets (tfstate, Logz token). Must be **rotated**, not just deleted. The Review stage will hard-fail on them until then.
- **App security posture:** HTTP-only App Gateway, public Postgres, `API_COOKIE_SECURE=false`, login leaks full user object, hardcoded `"cornflake-…"` fallback API key — all pre-existing, flagged for later.
- **Global-uniqueness names to confirm:** `epictfstatedfb05368`, `onboardxappfe`.
