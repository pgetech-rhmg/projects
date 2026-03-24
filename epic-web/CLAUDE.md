# EPIC Web — Claude Context

## What This App Is

**EPIC Web** is an Angular 20 front-end for the **EPIC-Pipeline** CI/CD framework used at PG&E. It gives engineers a UI to track, manage, and onboard applications into the EPIC pipeline system.

- Live URL (dev): `https://epic-dev.nonprod.pge.com`
- GitHub repo: `pgetech/epic-web`
- Logged-in user (hardcoded for now): **Robb Morgan**

---

## Tech Stack

- **Angular 20** — standalone components, `@if`/`@for` control flow, signals, `computed()`, `inject()`
- **Angular builder**: `@angular/build:application` (esbuild/Vite) — build output goes to `dist/epic-web/browser/`
- **Styles**: SCSS, single component stylesheet (`app.scss`), global base in `styles.scss`
- **HTTP**: `HttpClient` via `provideHttpClient()` in `app.config.ts`
- **No routing in use yet** — `<router-outlet>` is present but empty

### Key Angular 20 notes
- Static assets live in `public/` (not `src/assets/`) and are served at the root path — so `public/data/apps.json` is fetched as `data/apps.json`
- Build output: `dist/epic-web/browser/` — EPIC-Pipeline uses `find dist -name "index.html"` to locate this dynamically

---

## Project Structure

```
epic-web/
├── .pipeline/
│   └── epic.json                  # EPIC-Pipeline contract
├── .infra/                        # Terraform — AWS S3 + CloudFront + Route53
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── terraform.auto.tfvars
├── public/
│   └── data/
│       ├── apps.json              # Current user's app list (mock)
│       ├── master-apps.json       # All apps registered in EPIC (mock)
│       ├── github-repos.json      # All PG&E GitHub repos (mock)
│       └── apps/
│           ├── customer-portal.json
│           ├── billing-api.json
│           ├── outage-tracker.json
│           ├── grid-dashboard.json
│           ├── field-ops-ui.json      # empty runs array (tests no-runs state)
│           └── meter-data-service.json # empty runs array (tests no-runs state)
└── src/
    ├── styles.scss                # Global: html/body reset, font-family
    ├── index.html                 # <title>EPIC</title>
    └── app/
        ├── app.config.ts          # provideHttpClient(), provideRouter()
        ├── app.routes.ts
        ├── app.ts                 # Main component (all logic lives here for now)
        ├── app.html               # Main template
        ├── app.scss               # All component styles
        ├── models/
        │   └── app.model.ts       # All TypeScript interfaces/types
        ├── interceptors/
        │   └── user.interceptor.ts  # Adds X-Epic-User header to all requests
        └── services/
            └── app.service.ts     # All HTTP calls to epic-api
```

---

## Data Layer

The frontend calls `epic-api` for all data. Environment config controls the API URL:
- `src/environments/environment.ts` — `http://localhost:5000` (dev)
- `src/environments/environment.prod.ts` — `https://epic-api-dev.nonprod.pge.com` (production)

### `AppService` methods

| Method | API Endpoint | Purpose |
|--------|-------------|---------|
| `getApps()` | `GET /api/users/me/apps` | User's tracked apps (main table) |
| `getApp(name)` | `GET /api/apps/{name}` | App detail + pipeline run history (manage modal) |
| `checkRepo(repo)` | `GET /api/apps/check?repo={repo}` | Repo validation for onboarding (GitHub + DB check) |
| `addToMyApps(masterApp)` | `POST /api/users/me/apps` | Add existing EPIC app to user's list |
| `onboardApp(repo, branch)` | `POST /api/apps` | Onboard new app (fetches GitHub metadata) |
| `triggerRun(appName, branch, env)` | `POST /api/apps/{name}/runs` | Trigger pipeline run (stub — needs ADO REST) |

### HTTP Interceptor

`interceptors/user.interceptor.ts` adds `X-Epic-User: rhmg` header to every request. Replace with MSAL identity when auth is wired up.

### Error Handling

All subscribe calls use `{ next, error }` pattern with user-facing toast on failure.

---

## Models (`app.model.ts`)

```ts
type RunStatus = 'Success' | 'Failed' | 'Running' | 'Cancelled' | 'Skipped'

interface ManagedApp       // flat row in the main table
interface AppDetail        // full detail shown in the manage modal
interface PipelineRun      // one row in the runs table inside the modal
interface AppLookup        // lightweight shape used in master-apps.json
interface RepoCheckResult  // returned by checkRepo()
```

---

## UI Features

### Main page
- **Header**: EPIC brand (left) + "Welcome / Robb Morgan" avatar chip (right)
- **Toolbar**: 5 filter dropdowns (Technology, Cloud, Environment, Run Status, Triggered By) + search input + "Clear" button
- **Table**: 7 columns — App Name, Technology, Cloud, Environment, Last Pipeline Run, Run Status, Triggered By
  - Entire row is clickable → opens manage modal
  - Sticky headers — only the table scrolls, page does not
  - `pageSize = 25`, paginated with prev/next + numbered page buttons
  - "Triggered By" column shows a user chip; if it's the current user it shows "You"
- **+ New App button** → opens onboard modal

### Manage modal
- Shows app metadata grid (Team, Last Updated By, Technology, Environment, GitHub Repo, Branch, Cloud, Domain)
- Pipeline runs table with columns: Run #, Status, Branch, Environment, Triggered By, Started, Duration, Build, Test, Scan, Deploy
  - Run # is a clickable link → fires a toast (placeholder for ADO run navigation)
  - Stage columns use colored dot indicators
  - If `runs` array is empty → shows a dashed empty-state message instead of the table
- Footer: **Close** + **New Run** (closes manage modal and opens the New Run modal)

### New Run modal
- Triggered from the manage modal's "New Run" button — closes the manage modal first, then opens this one
- Shows a 3-tile metadata summary: GitHub Repo, Technology, Cloud
- **Branch input** (required):
  - `main` and `master` are blocked — shows red error: `"main" is not allowed — use a feature or release branch.`
  - If branch matches `release`, `release1`, `release2`, etc. (`/^release\d*$/i`), environment is forced to `prod` and the dropdown is disabled with a hint
  - Placeholder guides users: `e.g. feature/my-branch`
- **Environment dropdown** (required):
  - Options: dev, test, qa, stage
  - Defaults to `dev`
  - `prod` is **not selectable** — it only appears (and is auto-selected) when a release branch is entered
- **Run button** is disabled until branch is valid and environment is selected
- On confirm → closes modal → fires toast: `A new pipeline run for "{name}" on branch "{branch}" for the "{env}" environment has been queued...`
- Still a placeholder — no service call yet (`POST /api/apps/{name}/runs`)

### Onboard modal ("+ New App")
- **Repo name input** with on-blur validation via `checkRepo()`
  - Green border + "Repository is available to onboard" → `available`
  - Blue border + "Already in EPIC but not on your list. You can add it below." → `in-epic-not-mine`
  - Red border + "Already in your list." → `already-mine`
  - Red border + "Repo not found. Verify the name or check your access." → `not-found`
- **Branch input** — hidden when status is `in-epic-not-mine` or `already-mine`
- Footer button:
  - **Onboard** (enabled only when `available` + both fields filled) → toast confirming submission
  - **Add to My List** (shown when `in-epic-not-mine`) → adds app to table immediately + toast

### Toast system
- Fixed bottom-center, dark background, slide-in animation
- Auto-dismisses after 5 seconds
- Stays open while the user hovers over it (timer pauses on `mouseenter`, restarts on `mouseleave`)
- X button for manual dismiss

---

## Infrastructure (`.infra/`)

Terraform provisions: ACM cert, S3 bucket, CloudFront distribution, Route53 records (public + private hosted zones).

Key values:
- AWS Account: `514712703977`
- Org: `o-7vgpdbu22o`
- Domain: `epic-dev.nonprod.pge.com`
- S3 bucket name and CloudFront distribution ID are exported as Terraform outputs — consumed by the EPIC-Pipeline deploy stage

---

## EPIC-Pipeline Contract (`.pipeline/epic.json`)

```json
{
  "appName": "epic-web",
  "appType": "angular",
  "codePath": "/",
  "nodeVersion": "20",
  "scanTool": "sonarqube",
  "unitTestTool": "jest",
  "awsAccountId": "514712703977",
  "awsRegion": "us-west-2"
}
```

`codePath: "/"` is intentional — Angular 20's new builder outputs to `dist/epic-web/browser/` and EPIC-Pipeline detects this dynamically using `find dist -name "index.html"`.

---

## Known Gaps / Next Steps

- Only 6 apps have detail JSON files (`apps/{name}.json`). The other 49 apps in `apps.json` will show "Loading..." if their row is clicked. Need to either generate the remaining files or add a 404 handler in the modal.
- `onboardApp()` and `onConfirmNewRun()` fire toasts only — need real service calls once the API exists.
- Auth is hardcoded (`currentUser = 'Robb Morgan'`). Will need to wire up real identity.
- No unit tests written yet (`app.spec.ts` is the default scaffold).

### Component state for the New Run modal

| Signal / Property | Type | Purpose |
|---|---|---|
| `showNewRunModal` | `signal(false)` | Toggles modal visibility |
| `newRunApp` | `signal<AppDetail \| null>(null)` | Holds the app detail for context |
| `newRunBranch` | `string` | Two-way bound branch input |
| `newRunEnvironment` | `string` | Two-way bound environment select |
| `newRunBranchError` | `signal<string \| null>(null)` | Validation error for blocked branches |
| `newRunEnvLocked` | `signal(false)` | True when a release branch forces prod |
| `canRunNewPipeline` | getter | Composite validation (branch valid + env selected) |
