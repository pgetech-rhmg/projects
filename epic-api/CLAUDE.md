# EPIC API — Claude Context

## What This Is

**EPIC API** is the .NET 10 backend for the EPIC web application. It provides the REST API that `epic-web` (Angular) consumes for app management, pipeline tracking, onboarding, and run triggering.

- GitHub repo: `pgetech/epic-api`
- Domain (dev): `epic-api-dev.nonprod.pge.com`
- Port: 5000 (behind ALB with TLS termination)

---

## Tech Stack

- **.NET 10** (`net10.0`), C# with nullable reference types
- **ASP.NET Core** — controllers, DI, CORS, `JsonStringEnumConverter`
- **Entity Framework Core** + **Npgsql** — PostgreSQL ORM
- **PostgreSQL 16** (local Docker) / **Aurora PostgreSQL Serverless v2** (AWS)
- **GitHub API** — repo validation and metadata (language, description, default branch)
- **ADO REST API** — pipeline run queries via build tags
- **AWS Secrets Manager** — loads config at startup in production (key normalization: `__` → `:`)
- **Swagger/OpenAPI** — API documentation at `/swagger`
- **xUnit + Moq** — unit testing

---

## Local Development

```bash
# Start PostgreSQL
docker compose up -d

# Run the API
cd Epic.Api
dotnet run

# API available at http://localhost:5000
# Swagger at http://localhost:5000/swagger
```

Credentials and connection string come from `Properties/launchSettings.json` (gitignored). Copy from `.env.example` pattern.

Auto-migration runs on startup via `db.Database.Migrate()` — idempotent in all environments.

### Seed local data
```bash
docker exec -i epic-postgres psql -U epic -d epicdb < seed.sql
```

### Generate a new migration
```bash
cd Epic.Api
dotnet ef migrations add <MigrationName> --output-dir Data/Migrations
```

---

## Build & Test

```bash
cd epic-api
dotnet build
dotnet test                    # xUnit
dotnet publish                 # self-contained linux-x64
```

---

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/health` | Health check (used by ALB) |
| `GET` | `/api/users/me/apps` | User's tracked apps (refreshes latest run from ADO) |
| `POST` | `/api/users/me/apps` | Add an existing EPIC app to user's list (refreshes latest run) |
| `DELETE` | `/api/users/me/apps/{name}` | Remove an app from user's tracked list |
| `GET` | `/api/apps/{name}` | App detail + runs (refreshes from GitHub + ADO) |
| `GET` | `/api/apps/check?repo={repo}` | Repo validation (GitHub API + DB check) |
| `POST` | `/api/apps` | Onboard new app (reads epic.json from repo for appName/appType) |
| `POST` | `/api/apps/{name}/runs` | Trigger pipeline run (stub — needs ADO REST) |
| `DELETE` | `/api/diag/purge` | Purge all data from all tables |
| `GET` | `/api/diag/ado/{appName}` | Diagnostic — test ADO tag query |
| `GET` | `/api/diag/ado-raw/{appName}` | Diagnostic — raw ADO API response |
| `GET` | `/api/diag/ado-orchestrator/{appName}` | Diagnostic — raw orchestrator pipeline builds |
| `GET` | `/api/diag/github/{repo}` | Diagnostic — test GitHub repo lookup |

---

## Project Structure

```
epic-api/
├── Epic.Api.sln
├── docker-compose.yml                   # Local PostgreSQL 16 (reads .env)
├── .env.example                         # Template for .env (gitignored)
├── seed.sql                             # Seed data for local testing
├── .pipeline/epic.json                  # EPIC Pipeline contract
├── .infra/                              # Terraform — EC2 + ALB + Aurora + S3 + Secrets + Route53
├── Epic.Api/
│   ├── Program.cs                       # DI, CORS, Swagger, EF Core, Secrets Manager
│   ├── appsettings.json                 # AWS_REGION, AWS_SECRETS_NAME (no secrets)
│   ├── Properties/
│   │   └── launchSettings.json          # Local dev credentials (gitignored)
│   ├── Auth/
│   │   ├── ICurrentUser.cs              # User identity interface
│   │   └── HeaderCurrentUser.cs         # Reads X-Epic-User header (swap to MSAL later)
│   ├── Controllers/
│   │   ├── HealthController.cs          # GET /api/health
│   │   ├── AppsController.cs            # App CRUD, check, onboard, trigger
│   │   ├── UserAppsController.cs        # User's tracked apps
│   │   └── DiagController.cs            # Temporary diagnostic endpoints
│   ├── Models/
│   │   ├── App.cs                       # API response models
│   │   └── Requests.cs                  # Request DTOs
│   ├── Data/
│   │   ├── EpicDbContext.cs             # EF Core DbContext (apps, pipeline_runs, user_apps)
│   │   ├── Entities/                    # DB entities
│   │   └── Migrations/                  # EF Core migrations
│   └── Services/
│       ├── IAppService.cs               # App service interface
│       ├── AppService.cs                # Main service (DB + GitHub refresh + ADO refresh)
│       ├── IGitHubService.cs            # GitHub repo metadata interface
│       ├── GitHubService.cs             # GitHub API (repo info, languages)
│       ├── IAdoService.cs               # ADO pipeline runs interface
│       └── AdoService.cs                # ADO Builds API (tag-filtered queries + timeline)
└── Epic.Api.UnitTests/
    └── HealthControllerTests.cs
```

---

## External Integrations

### GitHub API

`GitHubService` calls three endpoints:
- `GET /repos/{org}/{repo}` — name, description, language, default branch
- `GET /repos/{org}/{repo}/languages` — fallback language detection by bytes
- `GET /repos/{org}/{repo}/contents/{path}?ref={branch}` — fetch file content (base64 decoded)

Used by:
- `CheckRepoAsync` — validates repo exists before onboarding
- `OnboardAppAsync` — fetches `.pipeline/epic.json` for `appName`/`appType`, GitHub metadata for description
- `GetAppAsync` — refreshes description on each detail view (technology/appType are NOT refreshed from GitHub — they come from epic.json at onboard time)

### ADO REST API

`AdoService` queries two pipelines:
- **Engine (ID 194)** — run data: status, stages, timing, branch, environment
  - `GET /build/builds?definitions=194&tagFilters={appName}&$top=N&queryOrder=queueTimeDescending` — finds runs for a specific app
  - `GET /build/builds/{buildId}/timeline` — stage-level results (Build, Test, Scan, DeployInfra, Deploy)
- **Orchestrator (ID 133)** — triggeredBy: the real `requestedFor` user
  - `GET /build/builds?definitions=133&tagFilters={appName}&$top=N&queryOrder=finishTimeDescending` — matched to engine runs by time proximity

Both pipelines are tagged with `appName` (engine by `TagBuild` job in `epic-engine.yml`, orchestrator by a tag step in `epic-orchestrator.yml`).

The engine's `requestedFor` is the service account (triggered via REST). The orchestrator's `requestedFor` is the real user. `AdoService` resolves this by querying orchestrator builds and matching to engine builds by time proximity.

Stage statuses: `Success`, `Failed`, `Running`, `Cancelled`, `Skipped` (intentionally skipped), `Pending` (hasn't run yet), `External`.

Used by:
- `GetUserAppsAsync` — lightweight refresh (latest run per app, parallel, no timeline)
- `GetAppAsync` — full run history with stage details

### AWS Secrets Manager

Loaded at startup in non-Development environments. Keys with `__` are normalized to `:` for .NET configuration compatibility (e.g., `ConnectionStrings__EpicDb` → `ConnectionStrings:EpicDb`).

Required secrets: `ConnectionStrings__EpicDb`, `GITHUB_BASE_URL`, `GITHUB_TOKEN`, `ADO_PAT`

---

## Database Schema

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `apps` | All applications registered in EPIC | `name` (unique), `github_repo` (unique), `app_type`, `technology`, `cloud`, `environment` |
| `pipeline_runs` | Pipeline execution history | `app_id` (FK), `status`, `branch`, `environment`, stage statuses |
| `user_apps` | Which users track which apps | `user_id` + `app_id` (unique composite) |

---

## Infrastructure (`.infra/`)

- **ACM cert** for `epic-api-dev.nonprod.pge.com`
- **ALB** — TLS termination, health check at `/api/health`
- **EC2** — Amazon Linux 2023, .NET app as systemd service on port 5000
- **Aurora PostgreSQL Serverless v2** — 0.5–2 ACUs, encrypted, managed password
- **Secrets Manager** — app config (connection string, tokens)
- **S3** — Deployment artifact bucket
- **Security groups** — CloudFront/CCOE → ALB:443 → EC2:5000 → Aurora:5432
- **Route53** — Private zone CNAME to ALB

---

## Onboarding Data Flow

When `OnboardAppAsync` is called:
1. Validates repo exists via GitHub API
2. Fetches `.pipeline/epic.json` from the repo via `GetFileContentAsync`
3. Reads `app.appName` → becomes `Name` in the DB (falls back to repo name if missing)
4. Reads `app.appType` → mapped to `Technology` via `MapAppTypeToTechnology()` (e.g., `angular` → `Angular`, `dotnet` → `.NET`)
5. Detects cloud from `cloud.awsAccountId` or `cloud.azureSubscription` → normalized to `AWS` or `Azure`
6. Fetches latest ADO run so the main table shows run data immediately

## Next Steps

- **`TriggerRunAsync`** — Needs ADO REST API call to invoke the EPIC orchestrator pipeline.
- **Auth** — Replace `X-Epic-User` header with MSAL/JWT (same pattern as paige-api).
- **Remove DiagController** — Once ADO/GitHub integrations are verified working.
