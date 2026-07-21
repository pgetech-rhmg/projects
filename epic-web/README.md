# epic-web

The web dashboard for EPIC (Enterprise Pipeline for Infrastructure and Cloud) — PG&E's internal developer platform for managing CI/CD pipelines across AWS, Azure, and SAP BTP.

epic-web is a single-page Angular app and the frontend for [epic-api](../epic-api). It lists onboarded applications and their pipeline history, lets users trigger and cancel pipeline runs, onboard new apps, and generate the `.pipeline/epic.json` contract via a guided wizard. It surfaces the compliance (Review) gate report and SonarQube scan results inline.

- **Stack:** Angular 20, TypeScript, SCSS
- **State:** Angular signals (no NgRx/RxJS store)
- **Auth:** Entra ID via MSAL (`@azure/msal-angular`)
- **Tests:** Karma + Jasmine

## Getting started

```bash
npm install
npm start        # ng serve — https://localhost:4200
```

> The dev server runs over **HTTPS** (`ng serve` is configured with `ssl: true`, certs in `.certs/`) because MSAL's redirect URI is `https://localhost:4200`. You'll need those local certs present.

Other scripts:

```bash
npm run build      # ng build — production bundle to dist/epic-web/
npm run watch      # ng build --watch (development configuration)
npm test           # ng test — Karma watch mode
npm run test:ci    # ng test --no-watch --code-coverage --browsers=ChromeHeadlessNoSandbox
```

## Architecture

The entire UI lives in a **single standalone `App` component** (`src/app/app.ts` / `app.html` / `app.scss`). Routing is wired up (`provideRouter`, `<router-outlet>`) but `app.routes.ts` is intentionally empty — there are no routes.

```
src/
├── main.ts                          # bootstrapApplication(App, appConfig)
├── app/
│   ├── app.ts / app.html / app.scss # the sole component
│   ├── app.config.ts                # providers, MSAL setup
│   ├── app.routes.ts                # empty (no routing)
│   ├── services/app.service.ts      # HTTP client to epic-api
│   ├── interceptors/user.interceptor.ts  # attaches the Entra ID bearer
│   ├── models/app.model.ts          # interfaces / types
│   ├── environments/                # environment.ts, environment.prod.ts
│   └── wizard/                       # epic.json / epic.md generation
└── public/
    ├── steering/epic-infra.md       # fetched at runtime by the wizard
    └── data/                         # mock JSON fixtures
```

### AppService

`AppService` (`providedIn: 'root'`) is the HTTP client to epic-api, using `environment.apiUrl` as the base. It covers health, the current user's apps, app detail and paged runs, stage detail and step logs, run trigger/cancel, config discovery (`epic.json`), the SonarQube scan-result URL, and the compliance report (markdown, summary, and structured JSON).

The app **polls every 5 seconds** to auto-refresh: after a successful health probe it re-fetches the app list (reconciled with optimistic pending/cancelling state) and, when a modal is open, refreshes the visible app detail, runs page, and any expanded stage/step log. If the backend is offline it shows an offline message and stops calling until the page is reloaded.

### Authentication

`userInterceptor` attaches an **Entra ID bearer** to requests:

- It only touches requests to `environment.apiUrl`, and only in production — **dev sends no token** (epic-api's Development mode bypasses auth).
- It attaches the MSAL **ID token** (`aud=clientId`, via `acquireTokenSilent({ scopes: ['User.Read'] })`) as `Authorization: Bearer …`. Using the ID token avoids needing an "expose an API" app-registration change.
- It **never triggers interactive login** — on any silent-token failure it proceeds unauthenticated (epic-api returns 401), so there are no redirect loops. Interactive login is owned solely by the app's `inProgress$` handler.
- This replaced the old `X-Epic-User` header, which is gone.

MSAL is configured in `app.config.ts` (`clientId`/`tenantId`/`redirectUri` from the environment, session-storage cache, `initialize()` via `APP_INITIALIZER`).

### Environments

`angular.json` swaps `environment.ts` → `environment.prod.ts` for production builds.

| Key | dev (`environment.ts`) | prod (`environment.prod.ts`) |
|-----|------------------------|------------------------------|
| `production` | `false` | `true` |
| `apiUrl` | `https://epic-api-dev.nonprod.pge.com` | `https://epic-api-dev.nonprod.pge.com` |
| `redirectUri` | `https://localhost:4200` | `https://epic-dev.nonprod.pge.com` |
| `msalClientId` / `msalTenantId` | (Entra app + tenant) | same |

To point the dev build at a locally running epic-api, switch `apiUrl` to `http://localhost:5000` (a commented line for this already exists in `environment.ts`).

## Key features

- **Apps table** — one row per managed app with Technology / Cloud / Environment / last run / status / success rate / avg duration / triggered-by, plus filter dropdowns and a repo/app-name search. These display values arrive already derived from epic-api (from the latest ADO build tags).
- **Manage modal** — app detail plus a server-paged runs table with clickable per-stage dots (Review, Build, Test, Scan, Infra deploy, App deploy, Integration test). Expanding a stage loads its steps; expanding a step loads its log. Runs can be cancelled with optimistic UI, and link out to the ADO build.
- **New Run modal** — stage toggles (Review + Build default on; Tests/Scan/Deploy/Integration off) and an infra action (`none`/`plan`/`apply`/`destroy`). Disabling logic enforces the real pipeline rules: BTP/infra appTypes restrict to infrastructure, .NET requires Build to Scan (SonarQube MSBuild mode), Deploy requires Build, infra deploy is blocked without an S3 remote backend, and destroy requires confirmation.
- **Contract-less runs** — when a repo/branch has no `epic.json`, the modal locks all stages except **Review**, so the compliance gate can still run on an un-onboarded repo.
- **Compliance (Review) report** — on a terminal Review stage, an inline summary table (tool + version, verdict counts), a **View Report** modal that renders the structured JSON report (findings grouped by verdict, profile, verdict pills, fullscreen toggle), and a **Download Report** button for the Markdown.
- **Scan results** — on a terminal SonarQube Scan stage, a **View in SonarQube** button opens the dashboard (hidden for Wiz scans).
- **Config generation** — a 3-step "Builder" that assembles an `epic.json` live, and a 5-step **Create New App wizard** that renders an `epic.md` spec via `wizard/wizard.template.ts` (fetching `/steering/epic-infra.md` for reference content). Both cover the full appType set (`angular, react, dotnet, node, python, java, go, html, php, ami, cap, btp, infra`) and clouds (`aws | azure | sap`).

## Testing

Tests run on **Karma + Jasmine** (`karma.conf.js`, `@angular/build:karma`). Coverage is emitted to `reports/coverage/lcov.info`, which the EPIC SonarQube scan consumes (`sonar.javascript.lcov.reportPaths`). CI uses the `ChromeHeadlessNoSandbox` launcher:

```bash
npm run test:ci
```

The suite covers the full component (`app.spec.ts`), the wizard model and template, `AppService`, the interceptor, and app config, driving the component through a mocked `AppService` and stubbed MSAL.

## Conventions

- **State** is managed with Angular signals throughout; styles are SCSS.
- **Prettier** is configured inline in `package.json` (`printWidth: 100`, `singleQuote: true`, `angular` parser for `.html`).
- **`package-lock.json` is committed** for this repo — a deliberate exception to the workspace norm, required by SonarQube rule `text:S8564` (lock file in source control for reproducible installs). Do not re-ignore it.
