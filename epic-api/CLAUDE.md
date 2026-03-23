# EPIC API — Claude Context

## What This Is

**EPIC API** is the .NET 10 backend for the EPIC web application. It provides the REST API that `epic-web` (Angular) consumes for app management, pipeline tracking, onboarding, and run triggering.

- GitHub repo: `pgetech/epic-api`
- Domain (dev): `epic-api-dev.nonprod.pge.com`
- Port: 5000 (behind ALB with TLS termination)

---

## Tech Stack

- **.NET 10** (`net10.0`), C# with nullable reference types
- **ASP.NET Core** — controllers, DI, CORS
- **Entity Framework Core** + **Npgsql** — PostgreSQL ORM
- **PostgreSQL 16** (local Docker) / **Aurora PostgreSQL Serverless v2** (AWS)
- **Swagger/OpenAPI** — API documentation at `/swagger`
- **xUnit + Moq** — unit testing
- **SonarQube** — code scanning via EPIC Pipeline

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
# Database: localhost:5432/epicdb (epic/epic)
```

Auto-migration runs on startup in Development mode — no manual `dotnet ef` needed.

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

These match the mock URLs in `epic-web/src/app/services/app.service.ts`:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/health` | Health check (used by ALB) |
| `GET` | `/api/users/me/apps` | Get apps tracked by the current user |
| `POST` | `/api/users/me/apps` | Add an existing EPIC app to user's list |
| `GET` | `/api/apps/{name}` | Full app detail + pipeline run history |
| `GET` | `/api/apps/check?repo={repo}` | Check if a repo can be onboarded |
| `POST` | `/api/apps` | Onboard a new application into EPIC |
| `POST` | `/api/apps/{name}/runs` | Trigger a new pipeline run |

---

## Project Structure

```
epic-api/
├── Epic.Api.sln
├── docker-compose.yml                   # Local PostgreSQL 16
├── .pipeline/epic.json                  # EPIC Pipeline contract
├── .infra/                              # Terraform — EC2 + ALB + Aurora + S3 + Route53
├── Epic.Api/
│   ├── Program.cs                       # DI, CORS, Swagger, EF Core + Npgsql
│   ├── appsettings.json                 # Local connection string
│   ├── Controllers/
│   │   ├── HealthController.cs          # GET /api/health
│   │   ├── AppsController.cs            # App detail, check, onboard, trigger runs
│   │   └── UserAppsController.cs        # User's tracked apps
│   ├── Models/
│   │   ├── App.cs                       # API response models (match epic-web TypeScript)
│   │   └── Requests.cs                  # Request DTOs
│   ├── Data/
│   │   ├── EpicDbContext.cs             # EF Core DbContext
│   │   ├── Entities/
│   │   │   ├── AppEntity.cs             # apps table
│   │   │   ├── PipelineRunEntity.cs     # pipeline_runs table
│   │   │   └── UserAppEntity.cs         # user_apps table (user ↔ app tracking)
│   │   └── Migrations/                  # EF Core migrations
│   └── Services/
│       ├── IAppService.cs               # Service interface
│       └── AppService.cs                # EF Core implementation
└── Epic.Api.UnitTests/
    └── HealthControllerTests.cs
```

---

## Database Schema

Three tables:

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `apps` | All applications registered in EPIC | `name` (unique), `github_repo` (unique), `app_type`, `technology`, `cloud`, `environment` |
| `pipeline_runs` | Pipeline execution history | `app_id` (FK), `status`, `branch`, `environment`, stage statuses |
| `user_apps` | Which users track which apps | `user_id` + `app_id` (unique composite), enables per-user app lists |

**Relationships:** `apps` 1→N `pipeline_runs`, `apps` 1→N `user_apps`

---

## Models

API response models mirror the TypeScript interfaces in `epic-web/src/app/models/app.model.ts`:

| C# Model | TypeScript Equivalent | Used By |
|-----------|----------------------|---------|
| `ManagedApp` | `ManagedApp` | User's app list (main table) |
| `AppDetail` | `AppDetail` | Manage modal (full detail + runs) |
| `PipelineRun` | `PipelineRun` | Runs table inside manage modal |
| `AppLookup` | `AppLookup` | Master app list / onboard check |
| `RepoCheckResult` | `RepoCheckResult` | Onboard modal repo validation |

DB entities (`Data/Entities/`) are separate from API models — `AppService` maps between them.

---

## Infrastructure (`.infra/`)

- **ACM cert** for `epic-api-dev.nonprod.pge.com`
- **ALB** — TLS termination, health check at `/api/health`
- **EC2** — Amazon Linux 2023, .NET app as systemd service on port 5000
- **Aurora PostgreSQL Serverless v2** — auto-scaling 0.5–2 ACUs, encrypted, managed password
- **S3** — Deployment artifact bucket
- **Security groups** — CloudFront/CCOE → ALB:443 → EC2:5000 → Aurora:5432
- **Route53** — Private zone CNAME to ALB
- **Outputs** — `instance_id`, `bucket_name`, `db_cluster_endpoint`, `db_secret_arn`

---

## EPIC Pipeline Contract (`.pipeline/epic.json`)

```json
{
  "app": {
    "appName": "epic-api",
    "appType": "dotnet",
    "codePath": "/Epic.Api",
    "dotnetVersion": "10.x",
    "scanTool": "sonarqube",
    "unitTestTool": "xunit"
  },
  "cloud": {
    "awsAccountId": "514712703977",
    "awsRegion": "us-west-2",
    "appExecutable": "Epic.Api"
  }
}
```

---

## EF Core Migrations

Migrations run automatically on app startup via `db.Database.Migrate()` in all environments. This is idempotent — EF Core checks `__EFMigrationsHistory` and only applies new migrations.

To add a new migration:
```bash
cd Epic.Api
dotnet ef migrations add <MigrationName> --output-dir Data/Migrations
```

Commit the generated migration files. On next deploy, the app starts, applies the new migration, then serves requests.

---

## Next Steps

- **ADO integration** — `TriggerRunAsync` should call the Azure DevOps REST API to invoke the EPIC orchestrator pipeline.
- **Auth** — No authentication wired yet. Will need Azure AD / MSAL integration (same pattern as paige-api). The hardcoded `CurrentUserId` in AppService needs to be replaced with real identity.
- **AWS connection string** — In production, the connection string is stored in AWS Secrets Manager (provisioned by `.infra/` Secrets Manager module). The app loads it at startup via `Program.cs` (same pattern as paige-api).
