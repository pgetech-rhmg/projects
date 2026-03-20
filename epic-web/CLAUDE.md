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
        └── services/
            └── app.service.ts     # All HTTP calls (mock → real API swap point)
```

---

## Data Layer (Mock → API)

All mock data is in `public/data/`. The service is structured so swapping a URL is all that's needed to go live.

### Three mock data files

| File | Represents | Real API equivalent |
|---|---|---|
| `apps.json` | Apps the current user is tracking/contributing to | `GET /api/users/me/apps` |
| `master-apps.json` | All apps registered in EPIC across all users | `GET /api/apps` |
| `github-repos.json` | All PG&E GitHub repos (access check mock) | `GET /api/github/repos/{repo}` |
| `apps/{name}.json` | Full detail + pipeline run history for one app | `GET /api/apps/{name}` |

### `AppService` methods

```ts
getApps(): Observable<ManagedApp[]>
// Mock: GET data/apps.json
// Real: GET /api/users/me/apps

getApp(name: string): Observable<AppDetail>
// Mock: GET data/apps/{name}.json
// Real: GET /api/apps/{name}

checkRepo(repo: string): Observable<RepoCheckResult>
// Mock: three sequential fetches (github-repos → master-apps → apps)
// Real: GET /api/apps/check?repo={repo}  ← collapses all three checks server-side
// Returns: { status: 'available' | 'in-epic-not-mine' | 'already-mine' | 'not-found', masterApp? }

addToMyApps(masterApp: AppLookup): Observable<ManagedApp>
// Mock: returns constructed ManagedApp via of()
// Real: POST /api/users/me/apps  { name: "grid-automation" }
```

### Still needs service calls (placeholders only today)
- **Onboard new app** — `POST /api/apps` `{ repo, branch }` — currently fires a toast only
- **Trigger new run** — `POST /api/apps/{name}/runs` — currently fires a toast only

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
- Footer: **Close** + **New Run** (New Run fires a toast — placeholder for `POST /api/apps/{name}/runs`)

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
- `onboardApp()` and `onNewRun()` fire toasts only — need real service calls once the API exists.
- Auth is hardcoded (`currentUser = 'Robb Morgan'`). Will need to wire up real identity.
- The "New Run" button should eventually allow branch selection before triggering.
- No unit tests written yet (`app.spec.ts` is the default scaffold).
