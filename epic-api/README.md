# epic-api

The REST API behind EPIC (Enterprise Pipeline for Infrastructure and Cloud) — PG&E's internal developer platform for managing CI/CD pipelines across AWS, Azure, and SAP BTP.

epic-api is the backend for the [epic-web](../epic-web) dashboard. It tracks onboarded applications and the users who manage them, reads repository state from the GitHub API, and triggers/reads pipeline runs through the Azure DevOps REST API. It merges its own database records with live ADO data on every request, so the UI reflects current pipeline state without a background sync job.

- **Stack:** .NET 10 (C#), ASP.NET Core Web API
- **Data:** EF Core + PostgreSQL (Npgsql), RDS in deployed environments
- **Auth:** Entra ID JWT bearer (MSAL); dev-bypassed
- **Integrations:** GitHub REST API, Azure DevOps REST API

## Project layout

```
Epic.Api.sln
├── Epic.Api/                     # the API (Microsoft.NET.Sdk.Web, net10.0)
│   ├── Program.cs                # startup: config, CORS, auth, DI, migrations, Swagger
│   ├── Auth/                     # ICurrentUser, ClaimsCurrentUser, DevCurrentUser, IAuditLog
│   ├── Controllers/              # AppsController, UserAppsController, HealthController
│   ├── Services/                 # AppService, GitHubService, AdoService
│   ├── Data/                     # EpicDbContext, Entities/, Migrations/
│   ├── Models/                   # DTOs
│   └── Startup/                  # SecretsLoader (AWS Secrets Manager)
└── Epic.Api.UnitTests/           # xUnit + Moq test suite
```

## Getting started

```bash
dotnet restore                           # restore NuGet packages
dotnet build                             # build the solution
dotnet run --project Epic.Api            # run at http://localhost:5000
```

Swagger UI is served at `/swagger` in all environments.

In **Development** the app listens on `http://localhost:5000`, **bypasses authentication** (see below), and expects a local PostgreSQL at the connection string in `Epic.Api/Properties/launchSettings.json`. Running against a real database locally is not otherwise wired up — set `ConnectionStrings:EpicDb` manually if you need a different target.

### Local `launchSettings.json`

`Epic.Api/Properties/launchSettings.json` is **gitignored** (it carries real PATs), so it isn't in the repo — create it yourself. Below is a sanitized template; replace the placeholder token values with your own. The `GITHUB_TOKEN` needs SSO authorized for the `pgetech` org, and the `ADO_PAT` needs Build (read & execute) scope on the `EPIC-Pipeline` project.

```jsonc
{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": false,
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ConnectionStrings__EpicDb": "Host=localhost;Port=5432;Database=epicdb;Username=epic;Password=epic",
        "GITHUB_BASE_URL": "https://github.com/pgetech",
        "GITHUB_TOKEN": "<your-github-pat>",
        "ADO_PAT": "<your-azure-devops-pat>"
      }
    }
  }
}
```

The connection string matches the local PostgreSQL that [`local.sh`](../local.sh) starts in Docker. Note that `__` (double underscore) in the env var names maps to the config `:` separator (`ConnectionStrings__EpicDb` → `ConnectionStrings:EpicDb`).

## Configuration

Configuration is layered: `appsettings.json` → `appsettings.{Environment}.json` → environment variables.

| Key | Purpose |
|-----|---------|
| `ConnectionStrings:EpicDb` | PostgreSQL connection string (Development / manual override) |
| `AzureAd:Instance` / `TenantId` / `ClientId` | Entra ID authority + audience for JWT validation |
| `AWS_REGION` | AWS region (default `us-west-2`) |
| `AWS_SECRETS_NAME` | Secrets Manager secret holding app config in deployed environments |
| `AWS_RDS_SECRET_ARN` / `AWS_RDS_ENDPOINT` | RDS credentials + endpoint used to assemble the DB connection string |
| `GITHUB_BASE_URL` / `GITHUB_TOKEN` | GitHub API base + PAT |
| `ADO_PAT` | Azure DevOps PAT (Basic auth) |
| `EPIC_RUN_MIGRATIONS` | Set to `false` to skip auto-migration on startup |

In non-Development environments, `Startup/SecretsLoader` pulls app secrets from AWS Secrets Manager (`AWS_SECRETS_NAME`, keys with `__` mapped to config `:` sections) and, when `AWS_RDS_SECRET_ARN`/`AWS_RDS_ENDPOINT` are set, assembles the RDS connection string at startup.

> **Note:** because the connection string is built once at startup, an Aurora master-password rotation currently requires a redeploy to pick up the new credentials.

CORS policy `ApiCorsPolicy` allows `https://epic-dev.nonprod.pge.com` and `http(s)://localhost:4200`, with credentials.

## Authentication

The API validates **Entra ID JWT bearer tokens** and derives identity from them; there is no legacy `X-Epic-User` header.

- **Token validation** (`Program.cs`): `AddJwtBearer` with authority `{Instance}/{TenantId}/v2.0`, `ValidIssuer` = that authority, `ValidAudience` = `ClientId` (the epic-web app registration — an ID token, `aud=clientId`). JWKS is fetched automatically; signatures are RS256.
- **Deny-by-default:** a fallback authorization policy requires an authenticated user on every endpoint. `HealthController` is `[AllowAnonymous]` for load-balancer probes.
- **Identity** (`Auth/`): `ICurrentUser` exposes `UserId` — the 4-char PG&E **corpId** derived from the token email claim (`email` → `preferred_username` → `upn` → …), which scopes all user-owned endpoints — and `DisplayName` (the `name` claim), used for audit records and the pipeline "Triggered By" value.
- **Dev bypass:** in Development, JWT validation is skipped and `DevCurrentUser` (a fixed identity) is registered, so `dotnet run` needs no token. Production uses `ClaimsCurrentUser`.
- **Audit logging:** `IAuditLog`/`AuditLog` emits a six-field structured record (event, actor corpId, resource, outcome, source IP, UTC timestamp) at every state-changing action — onboarding, adding/removing an app, triggering/cancelling a run (NIST AC-12 / AU-02).

## Endpoints

### `AppsController` — `api/apps`

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/apps/{name}` | App detail |
| GET | `/api/apps/{name}/runs` | Paged pipeline runs (`?page=&pageSize=`) |
| GET | `/api/apps/{name}/runs/{runId}/stages/{stageName}` | Stage detail (steps) |
| GET | `/api/apps/{name}/runs/{runId}/logs/{logId}` | Step log |
| GET | `/api/apps/{name}/runs/{runId}/scan-result-url` | SonarQube dashboard URL for the Scan stage |
| GET | `/api/apps/{name}/runs/{runId}/compliance-report` | Compliance report (Markdown) |
| GET | `/api/apps/{name}/runs/{runId}/compliance-summary` | Compliance verdict summary |
| GET | `/api/apps/{name}/runs/{runId}/compliance-report-json` | Structured compliance report (JSON) |
| GET | `/api/apps/check?repo=` | Validate a GitHub repo |
| GET | `/api/apps/configs?repo=&branch=` | Find `.pipeline/epic.json` configs |
| GET | `/api/apps/configs/check?repo=&branch=&config=` | Infra + appType details for a config |
| POST | `/api/apps` | Onboard an app |
| POST | `/api/apps/{name}/runs` | Trigger a pipeline run |
| POST | `/api/apps/{name}/runs/{runId}/cancel` | Cancel a run (orchestrator + engine pair) |

### `UserAppsController` — `api/users/me/apps`

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/users/me/apps` | The current user's managed apps |
| POST | `/api/users/me/apps` | Add an app to the current user |
| DELETE | `/api/users/me/apps/{name}` | Remove an app from the current user |

### `HealthController` — `api/health`

`GET /api/health` — `[AllowAnonymous]`; 200 when the database is reachable, 503 otherwise.

## Services

- **`AppService`** — core business logic. Merges DB records with live GitHub + ADO data; owns onboarding, user-app tracking, run triggering/cancellation, run paging, stage/log retrieval, scan-URL and compliance-report extraction. Technology/Cloud/Environment on a `ManagedApp` are derived from the latest ADO engine build's tags, with a GitHub-language fallback for the Technology column.
- **`GitHubService`** — reads repositories, file contents, and path existence from the GitHub API; finds `epic.json` configs and inspects `.infra/`. URL segments are percent-encoded (SSRF defense); successful responses are cached ~30s.
- **`AdoService`** — Azure DevOps REST client (org `pgetech`, project `EPIC-Pipeline`). Gets runs, timelines/stage detail, step logs; triggers and cancels orchestrator builds; parses compliance and scan output. Pinned to `api-version=7.1`, sends `User-Agent`/`Accept` headers, and retries `429`/`408`/`5xx` with exponential backoff honoring `Retry-After` (a retry-only resilience handler — deliberately no circuit breaker, so the "serve stale on failure" contract holds).

Both `GitHubService` and `AdoService` use typed `HttpClient`s with a 60-second timeout.

## Data & migrations

EF Core with PostgreSQL. Three entities in `EpicDbContext`:

- **`AppEntity`** → table `apps`
- **`PipelineRunEntity`** → table `pipeline_runs` (per-stage status columns: `StageReview`, `StageBuild`, `StageTest`, `StageScan`, `StageInfraDeploy`, `StageAppDeploy`, `StageIntegrationTest`)
- **`UserAppEntity`** → table `user_apps`

Table names are snake_case; column names are PascalCase (matching the C# properties).

Migrations under `Data/Migrations/` **auto-apply on startup** (unless `EPIC_RUN_MIGRATIONS=false` — use that on additional instances to avoid concurrent-migrate races). Add a migration with:

```bash
dotnet ef migrations add <MigrationName> --project Epic.Api
```

## Testing

```bash
dotnet test                                              # run all tests
dotnet test --filter "FullyQualifiedName~AdoServiceTests"  # a single class
```

The `Epic.Api.UnitTests` project uses **xUnit + Moq**, with EF Core InMemory/Sqlite for data fakes and a `FakeHttpMessageHandler`/`RoutingHttpMessageHandler` pair (in `TestHelpers/`) to stub GitHub and ADO HTTP calls against the real JSON-parsing paths. Coverage is collected via **coverlet**; `Program.cs`, `Startup/`, and `Migrations/` are excluded (bootstrap/generated code) both in the csproj and in the SonarQube scan config.

## Key package versions

Packages are pinned (not floating `10.*`) for reproducible builds:

- `Microsoft.AspNetCore.Authentication.JwtBearer` 10.0.9
- `Microsoft.EntityFrameworkCore` / `.Design` 10.0.9
- `Npgsql.EntityFrameworkCore.PostgreSQL` 10.0.3
- `Microsoft.Extensions.Http.Resilience` 10.7.0
- `AWSSDK.SecretsManager` 3.7.504.41
- `Swashbuckle.AspNetCore` 7.2.0
```
