import {
  APP_TYPE_LABELS,
  AppType,
  BUILD_TEST_TOOL_OPTIONS,
  DEFAULT_RUNTIME_VERSION,
  DeployTarget,
  ENTRA_TENANT_ID,
  INTEGRATION_TEST_TOOL_OPTIONS,
  NO_ARCHITECTURE_APP_TYPES,
  SCAN_TOOL_OPTIONS,
  WizardAnswers,
  relevantDeployTargetKeys,
} from './wizard.model';

interface PipelineModule {
  name: string;
  purpose: string;
}

const AWS_MODULES: PipelineModule[] = [
  { name: 'epic-pipeline-module-aws-api-gateway', purpose: 'API Gateway HTTP/REST APIs' },
  { name: 'epic-pipeline-module-aws-aurora-postgresql', purpose: 'Aurora PostgreSQL clusters' },
  { name: 'epic-pipeline-module-aws-certificate', purpose: 'ACM TLS certificates' },
  { name: 'epic-pipeline-module-aws-cloudfront', purpose: 'CloudFront distributions' },
  { name: 'epic-pipeline-module-aws-cloudtrail', purpose: 'CloudTrail audit logging' },
  { name: 'epic-pipeline-module-aws-cloudwatch', purpose: 'CloudWatch log groups and dashboards' },
  { name: 'epic-pipeline-module-aws-cloudwatch-alarm', purpose: 'CloudWatch metric alarms' },
  { name: 'epic-pipeline-module-aws-deploy-static-site', purpose: 'Pre-baked static-site deploy (S3 + CloudFront wiring)' },
  { name: 'epic-pipeline-module-aws-dynamodb', purpose: 'DynamoDB tables' },
  { name: 'epic-pipeline-module-aws-ec2', purpose: 'EC2 instances' },
  { name: 'epic-pipeline-module-aws-elastic-beanstalk', purpose: 'Elastic Beanstalk applications and environments' },
  { name: 'epic-pipeline-module-aws-iam-role', purpose: 'IAM roles and policies' },
  { name: 'epic-pipeline-module-aws-kms', purpose: 'KMS keys' },
  { name: 'epic-pipeline-module-aws-lambda', purpose: 'Lambda functions' },
  { name: 'epic-pipeline-module-aws-load-balancer', purpose: 'ALB / NLB load balancers' },
  { name: 'epic-pipeline-module-aws-network', purpose: 'VPC, subnets, route tables, NAT/IGW' },
  { name: 'epic-pipeline-module-aws-rds-proxy', purpose: 'RDS Proxy for connection pooling' },
  { name: 'epic-pipeline-module-aws-route53', purpose: 'Route53 hosted zones and records' },
  { name: 'epic-pipeline-module-aws-s3', purpose: 'S3 buckets' },
  { name: 'epic-pipeline-module-aws-secretmanager', purpose: 'Secrets Manager secrets' },
  { name: 'epic-pipeline-module-aws-security-group', purpose: 'VPC security groups' },
  { name: 'epic-pipeline-module-aws-ses', purpose: 'SES email identities and configuration sets' },
  { name: 'epic-pipeline-module-aws-sns', purpose: 'SNS topics and subscriptions' },
  { name: 'epic-pipeline-module-aws-sqs', purpose: 'SQS queues' },
  { name: 'epic-pipeline-module-aws-ssm-parameter-store', purpose: 'SSM Parameter Store entries' },
  { name: 'epic-pipeline-module-aws-static-web', purpose: 'Static web hosting bundle' },
  { name: 'epic-pipeline-module-aws-tags', purpose: 'Standard PG&E tag set — apply on all resources' },
];

const AZURE_MODULES: PipelineModule[] = [
  { name: 'epic-pipeline-module-azure-app-service', purpose: 'Azure App Service (web apps)' },
  { name: 'epic-pipeline-module-azure-function', purpose: 'Azure Functions' },
  { name: 'epic-pipeline-module-azure-key-vault', purpose: 'Azure Key Vault' },
  { name: 'epic-pipeline-module-azure-postgresql', purpose: 'Azure Database for PostgreSQL' },
  { name: 'epic-pipeline-module-azure-sql', purpose: 'Azure SQL Database' },
  { name: 'epic-pipeline-module-azure-storage', purpose: 'Azure Storage accounts (blob/queue/table)' },
  { name: 'epic-pipeline-module-azure-tags', purpose: 'Standard PG&E tag set — apply on all resources' },
];

export function renderEpicMd(answers: WizardAnswers, epicInfraContent: string = ''): string {
  return [
    renderHeader(answers),
    renderPrerequisites(),
    renderResearchFirst(answers),
    renderWorkflow(answers),
    renderAcceptanceCriteria(answers),
    renderAppProfile(answers),
    renderCloudTarget(answers),
    renderArchitecture(answers),
    renderWhatYouMustProduce(answers),
    renderToolingAllowlist(answers),
    renderPgeDefaults(answers),
    renderEpicJsonContract(answers),
    renderInfraContract(answers),
    renderModuleCatalog(answers),
    renderRepoLayout(answers),
    renderExtraNotes(answers),
    renderInfraSteeringEmbed(epicInfraContent),
  ]
    .filter((s) => s.length > 0)
    .join('\n\n')
    .trimEnd() + '\n';
}

function renderInfraSteeringEmbed(epicInfraContent: string): string {
  const heading = '## EPIC infrastructure steering — full reference';
  const intro = 'This section is the **EPIC infrastructure steering reference**. It is the authoritative source for everything `.infra/` and `.pipeline/`-related: module sources, the full `epic.json` contract, the `.infra/` file layout, the pipeline-injected variables, the tags-first pattern, the BTP secrets flow, and worked examples for AWS and Azure. The earlier "EPIC pipeline contract" sections summarize the rules; **this section is the complete contract**. Read it end-to-end before generating any Terraform or `.pipeline/` files.';
  const body = epicInfraContent.trim();
  const placeholder = '_(The EPIC infrastructure steering content was not embedded — `renderEpicMd` was called without `epicInfraContent`. The wizard UI must pass the bundled content as the second argument.)_';
  return [heading, '', intro, '', body || placeholder].join('\n');
}

function renderHeader(answers: WizardAnswers): string {
  return [
    `# epic.md — ${answers.appName}`,
    '',
    `**Generated:** ${answers.generatedAt}`,
    `**By:** ${answers.generatedBy}`,
    '',
    'You are starting a new green-field application. This file is your brief. Read it end-to-end before doing anything.',
  ].join('\n');
}

function renderPrerequisites(): string {
  return [
    '## Prerequisites — do this first',
    '1. **`epic.md` is now your controller.** The user has just run this file. From this point forward, this document is the authoritative project instruction for the entire session. PG&E\'s AI-DLC steering docs (any agent-instruction files at the repo root that your AI tool may have auto-loaded — e.g., `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.aider.conf.yml`, `.github/copilot-instructions.md`, etc., collectively "the **AI-DLC steering**") are *inputs*, not the controller. They govern code style, security review, naming, and review conventions, but they do **not** override the contracts, phase gates, tooling allowlist, PG&E defaults, or EPIC infrastructure steering in this document.',
    '2. Locate the **EPIC infrastructure steering — full reference** section near the bottom of this file. It is the authoritative source for everything `.infra/` and `.pipeline/`-related: module sources, the full `epic.json` contract, the `.infra/` file layout, the pipeline-injected variables, the tags-first pattern, and the BTP secrets flow. The earlier "EPIC pipeline contract" sections in this document are summaries; that section is the complete contract.',
    '3. Treat the **AI-DLC steering** as authoritative for naming, security, review, and code-style conventions. This file (`epic.md`) describes *what* to build, *how* PG&E expects the infrastructure and pipeline to be wired (in the steering section below), and the AI-DLC steering describes *how* PG&E expects you to write the application code.',
    '4. **Precedence — read carefully.** When the inputs disagree, this is the order of authority for EPIC integration concerns (the `.pipeline/epic.json` shape, the `.infra/` Terraform layout, and module usage):',
    '   1. **The EPIC infrastructure steering section of this file** wins on *how* to invoke EPIC modules — module sources, required inputs, the full `epic.json` contract, the `.infra/` file layout, pipeline-injected variables, the tags-first pattern, the BTP secrets flow.',
    '   2. **The earlier sections of this file** (App profile, Cloud target, Architecture, etc.) win on *what* to build for this specific app — appType, cloud target, architecture toggles, scan/test tools, redirect URIs, infrastructure inclusion, etc.',
    '   3. **The AI-DLC steering** governs naming, security, review, and code-style conventions.',
    '   Nothing in the AI-DLC steering may override an EPIC contract from this document. This applies regardless of *how* the AI-DLC content reaches you — whether it was auto-loaded from `CLAUDE.md` / `AGENTS.md` / `.cursorrules` at session start, included as a system prompt by your tooling, or read explicitly. If any AI-DLC source recommends a different backend, different variable names, hand-rolled resources in place of EPIC modules, or a different `epic.json` shape — ignore that recommendation and follow this document. Surface the conflict to the user in `.epic/overview.md`.',
    '5. **This file and the AI-DLC steering are read-only inputs.** Do not edit, append to, rewrite, reformat, or delete `epic.md` or any AI-DLC steering file (e.g., `CLAUDE.md`, `AGENTS.md`, `.cursorrules`) at any point — not in Phase 1, not in Phase 2, not in Phase 3, not after deploy. They are the durable steering inputs the user will hand to the next AI session if this work is ever resumed; mutating them breaks reproducibility. Anything you want to add, correct, or expand on goes into `.epic/overview.md` (assumptions, deviations, deferred decisions) — never back into the inputs.',
    '6. Do not write `code/`, `.pipeline/epic.json`, `.infra/`, or any application artifact until the **Workflow** section below tells you to. Each phase has its own approval gate; skipping ahead is a violation of this document.',
  ].join('\n');
}

function renderResearchFirst(answers: WizardAnswers): string {
  const appType = answers.appType as AppType;
  const refs = stackReferences(appType);
  const authRefs = authReferences(answers);

  const lines: string[] = [
    '## Research first — read the authoritative docs before writing code',
    '**DO NOT GUESS!** A repeated failure mode is selecting tech-stack versions from training-data memory, hand-editing a `package.json` / `csproj` / `requirements.txt`, encountering an `ERESOLVE` or runtime error, and then patching version-by-version until it works. This is not acceptable. Before writing any code in Phase 2 — and before re-touching any subsystem in Phase 3 — read the **current** authoritative documentation for the technologies you are about to use. The framework\'s official documentation is the source of truth, not prior assumptions.',
    '',
    'Apply this protocol on every new dependency, framework, library, or auth integration:',
    '',
    '1. **Identify the canonical doc site for the technology.** Use the references below as the starting point — not Stack Overflow, not blog posts, not training-data memory.',
    '2. **Read the "getting started" / quickstart for the version you intend to use.** Note the supported runtime version, peer-dependency matrix, and the recommended initializer / scaffolder. If the framework publishes a "version compatibility" or "supported versions" table, *read it*.',
    '3. **Cross-check the peer-dependency graph before installing.** For Node-based stacks, run `npm view <pkg>@<version> peerDependencies` (or the framework\'s published compatibility table) to confirm the surrounding packages match. Do not pin individual versions by hand and "see what happens."',
    '4. **For auth especially** (MSAL, OIDC, JWT validators): follow the Microsoft / vendor sample for *your specific framework*. MSAL has different sample apps for Angular vs. React vs. Node vs. .NET — they are not interchangeable. Match the sample\'s configuration shape, redirect-handling pattern, and component placement. Do not invent your own glue code.',
    '5. **If the docs disagree with the AI-DLC steering on framework conventions, follow the docs.** The AI-DLC steering is authoritative for PG&E security, naming, and review style — not for "how Angular wires MSAL." Surface the conflict in `.epic/overview.md` if it matters.',
    '6. **Cite what you read.** In `.epic/overview.md` under "Assumptions made" (or a "References consulted" subsection), list the doc URLs you used to make the version / library / integration choices. If you skipped a doc and used training memory, say so explicitly and flag it for human review.',
    '',
    `### References for this app (\`appType: ${appType}\`)`,
    'Start here. These are the authoritative sources for this stack:',
    '',
    ...refs.map((r) => `- **${r.label}** — ${r.url}`),
  ];

  if (authRefs.length > 0) {
    lines.push('');
    lines.push('### Authentication references for this app');
    lines.push('Auth is selected for this app. Follow the official Microsoft / vendor samples for *your framework*, not generic OIDC blog posts:');
    lines.push('');
    authRefs.forEach((r) => lines.push(`- **${r.label}** — ${r.url}`));
  }

  lines.push('');
  lines.push(renderFollowTheSampleRule());

  const msalAngularExample = msalAngularWiringExample(answers);
  if (msalAngularExample) {
    lines.push('');
    lines.push(msalAngularExample);
  }

  lines.push('');
  lines.push('If a reference URL has moved or been replaced, find the current canonical equivalent on the same vendor\'s docs site — do not fall back to a third-party tutorial.');

  return lines.join('\n');
}

function renderFollowTheSampleRule(): string {
  return [
    '### Follow the sample — do not invent glue (applies to every appType and every library)',
    'When a framework, library, or vendor publishes an **official sample, quickstart, or "getting started" project** for the integration you are about to build, **use it as the structural template** — bootstrap order, DI registration, lifecycle hooks, routing guards, config-loading pattern, env wiring, build / test / deploy commands, and any other plumbing. Do not write your own glue when an authoritative sample exists. This applies to *every* `appType` and *every* dependency in `code/`, not just auth and not just Angular.',
    '',
    'Concrete failure modes this rule prevents (all observed in real handoffs):',
    '- Race conditions because the AI bootstrapped the framework before async init finished (e.g., MSAL `initialize()` / `handleRedirectPromise()` running *after* `bootstrapApplication`, ASP.NET DI scopes resolved before `IHostedService.StartAsync` finishes, FastAPI startup events not awaited).',
    '- Wrong DI lifetime — `useFactory` where the sample uses `useValue`, `Scoped` where the sample uses `Singleton`, `@Component`-level injection where the sample uses module-level providers.',
    '- Custom guards / middlewares / interceptors duplicating logic the library already ships (e.g., a hand-rolled `AuthGuard` instead of the library\'s, a custom CORS middleware instead of the framework\'s, a hand-written retry instead of the SDK\'s built-in).',
    '- Wrong lifecycle method — calling init logic in `app.component.ts` / `App.tsx` / a controller constructor when the sample does it in `main.ts` / `Program.cs` / `app.py`.',
    '- Inventing config-loading patterns when the framework ships one (`environment.ts` for Angular, Vite env for React, `IConfiguration` for .NET, `pydantic-settings` for FastAPI, `application.yml` profiles for Spring, etc.).',
    '',
    'Protocol:',
    '1. **Locate the official sample** — the framework\'s own GitHub org or docs site (e.g., `AzureAD/microsoft-authentication-library-for-js` for MSAL, `dotnet/AspNetCore.Docs` for ASP.NET Core, `tiangolo/fastapi` examples, `spring-projects/spring-boot` examples, `vercel/next.js` examples). Use the references earlier in this section as a starting point.',
    '2. **Mirror its file-and-function structure for the integration.** Same files, same function boundaries, same call order. Adapt naming and types to your project — do not reorganize the lifecycle.',
    '3. **Match the sample\'s versions** for the integration libraries unless your **App profile** runtime version forces a bump; then check the sample\'s version-compatibility matrix.',
    '4. **Cite the sample.** In `.epic/overview.md`, list the sample URL you mirrored under "References consulted" so the reviewer can compare your code against it.',
    '5. **If you find yourself fixing a string of bootstrap, DI, or lifecycle bugs**, stop. That is the signal you skipped the sample. Re-read it, refactor to match, do not patch symptom-by-symptom.',
  ].join('\n');
}

function msalAngularWiringExample(answers: WizardAnswers): string | null {
  if (
    answers.appType !== 'angular' ||
    !answers.hasFrontend ||
    !answers.frontend ||
    answers.frontend.authMode !== 'msal'
  ) {
    return null;
  }
  return [
    '### Worked example — MSAL + Angular wiring (concrete application of the rule above)',
    'Your `appType` is `angular` and the wizard selected MSAL. The official `@azure/msal-angular` sample has a specific bootstrap and DI shape; **do not deviate from it**. If your code does not match the bullets below, it is wrong:',
    '',
    '- **`main.ts`** — create the `PublicClientApplication`, then `await msal.initialize()`, then `await msal.handleRedirectPromise()`, then call `msal.setActiveAccount(...)` from the redirect result (or the existing accounts), and *only after that* call `bootstrapApplication(AppComponent, appConfig)`. No race. The active account must be resolvable synchronously by the time DI starts.',
    '- **`msal.config.ts`** (or equivalent) — export the `PublicClientApplication` instance as a **singleton** (e.g., a module-scoped `getMsalInstance()` that returns the same already-initialized instance). Both `main.ts` and DI hand out the same object — no factory that calls `new PublicClientApplication(...)` twice.',
    '- **`app.config.ts`** — register `MSAL_INSTANCE` with `useValue: getMsalInstance()`, **not** `useFactory`. The factory pattern re-creates the instance under DI and breaks because it is no longer initialized. Provide `MsalService`, `MsalBroadcastService`, and `MSAL_GUARD_CONFIG` / `MSAL_INTERCEPTOR_CONFIG` per the sample.',
    '- **`app.routes.ts`** — protect routes with the library\'s `MsalGuard`. Do **not** write a custom `AuthGuard` that duplicates MSAL\'s logic; it will desync from the library\'s account state.',
    '- **`auth.service.ts`** (if you have one) — this is a **mirror** of MSAL events into a Signal/Observable for your UI (e.g., header avatar). It must not initialize MSAL, must not call `handleRedirectPromise`, must not own bootstrap. Subscribe to `MsalBroadcastService.msalSubject$` for `LOGIN_SUCCESS` / `LOGOUT_SUCCESS`, mirror to a signal, done.',
    '- **`app.component.ts`** — does not call `auth.initialize()` or any MSAL bootstrap method. By the time the component runs, `main.ts` has already finished init/redirect handling.',
    '',
    'If you find yourself debugging "the page reloads in a loop after login" or "active account is null on first render," you have violated the bootstrap order. Stop, re-read the sample, fix the root cause — do not paper it over with `setTimeout` or extra subscriptions.',
    '',
    '*This example is a concrete instance of the **Follow the sample** rule above. The same pattern of "official sample > invented glue" applies to every framework integration in this app.*',
  ].join('\n');
}

interface DocRef {
  label: string;
  url: string;
}

function stackReferences(appType: AppType): DocRef[] {
  switch (appType) {
    case 'angular':
      return [
        { label: 'Angular official docs', url: 'https://angular.dev' },
        { label: 'Angular CLI overview', url: 'https://angular.dev/tools/cli' },
        { label: 'Angular update guide (version compatibility)', url: 'https://angular.dev/update-guide' },
      ];
    case 'react':
      return [
        { label: 'React official docs', url: 'https://react.dev' },
        { label: 'Vite (recommended bundler) docs', url: 'https://vitejs.dev' },
        { label: 'TypeScript handbook', url: 'https://www.typescriptlang.org/docs/handbook/intro.html' },
      ];
    case 'node':
      return [
        { label: 'Node.js official docs', url: 'https://nodejs.org/docs/latest/api/' },
        { label: 'npm CLI / package.json reference', url: 'https://docs.npmjs.com/cli' },
        { label: 'Framework docs (pick one) — Express', url: 'https://expressjs.com' },
        { label: 'Framework docs (pick one) — Fastify', url: 'https://fastify.dev/docs/latest/' },
        { label: 'Framework docs (pick one) — NestJS', url: 'https://docs.nestjs.com' },
      ];
    case 'dotnet':
      return [
        { label: '.NET official docs', url: 'https://learn.microsoft.com/dotnet/' },
        { label: 'ASP.NET Core docs', url: 'https://learn.microsoft.com/aspnet/core/' },
        { label: '.NET versioning / lifecycle policy', url: 'https://dotnet.microsoft.com/platform/support/policy' },
      ];
    case 'python':
      return [
        { label: 'Python official docs', url: 'https://docs.python.org/3/' },
        { label: 'PyPA packaging guide', url: 'https://packaging.python.org' },
        { label: 'Framework docs (pick one) — FastAPI', url: 'https://fastapi.tiangolo.com' },
        { label: 'Framework docs (pick one) — Django', url: 'https://docs.djangoproject.com' },
        { label: 'Framework docs (pick one) — Flask', url: 'https://flask.palletsprojects.com' },
      ];
    case 'java':
      return [
        { label: 'Java SE docs', url: 'https://docs.oracle.com/en/java/javase/' },
        { label: 'Spring Boot reference', url: 'https://docs.spring.io/spring-boot/index.html' },
        { label: 'Spring Initializr', url: 'https://start.spring.io' },
      ];
    case 'php':
      return [
        { label: 'PHP official docs', url: 'https://www.php.net/manual/en/' },
        { label: 'Composer docs', url: 'https://getcomposer.org/doc/' },
        { label: 'Framework docs (pick one) — Laravel', url: 'https://laravel.com/docs' },
        { label: 'Framework docs (pick one) — Symfony', url: 'https://symfony.com/doc/current/index.html' },
      ];
    case 'html':
      return [
        { label: 'MDN Web Docs (HTML/CSS/JS reference)', url: 'https://developer.mozilla.org' },
        { label: 'Web.dev (modern web app guidance)', url: 'https://web.dev' },
      ];
    case 'ami':
      return [
        { label: 'AWS EC2 Image Builder docs', url: 'https://docs.aws.amazon.com/imagebuilder/' },
        { label: 'AWS CLI reference', url: 'https://docs.aws.amazon.com/cli/latest/reference/imagebuilder/' },
      ];
    case 'btp':
      return [
        { label: 'SAP BTP documentation', url: 'https://help.sap.com/docs/btp' },
        { label: 'Cloud Foundry CLI docs', url: 'https://docs.cloudfoundry.org/cf-cli/' },
        { label: 'SAP Terraform provider docs', url: 'https://registry.terraform.io/providers/SAP/btp/latest/docs' },
      ];
    case 'infra':
      return [
        { label: 'Terraform docs', url: 'https://developer.hashicorp.com/terraform/docs' },
        { label: 'AWS provider docs', url: 'https://registry.terraform.io/providers/hashicorp/aws/latest/docs' },
        { label: 'AzureRM provider docs', url: 'https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs' },
      ];
  }
}

function authReferences(answers: WizardAnswers): DocRef[] {
  const refs: DocRef[] = [];
  const front = answers.frontend;
  if (answers.hasFrontend && front && frontendAuthUsesEntra(front.authMode)) {
    if (front.authMode === 'msal') {
      const appType = answers.appType as AppType;
      if (appType === 'angular') {
        refs.push({ label: 'MSAL for Angular — official sample', url: 'https://github.com/AzureAD/microsoft-authentication-library-for-js/tree/dev/samples/msal-angular-samples' });
        refs.push({ label: '@azure/msal-angular package', url: 'https://www.npmjs.com/package/@azure/msal-angular' });
        refs.push({ label: 'msal-angular API reference', url: 'https://azuread.github.io/microsoft-authentication-library-for-js/ref/modules/_azure_msal_angular.html' });
      } else if (appType === 'react') {
        refs.push({ label: 'MSAL for React — official sample', url: 'https://github.com/AzureAD/microsoft-authentication-library-for-js/tree/dev/samples/msal-react-samples' });
        refs.push({ label: '@azure/msal-react package', url: 'https://www.npmjs.com/package/@azure/msal-react' });
      } else {
        refs.push({ label: 'MSAL.js (browser) docs', url: 'https://learn.microsoft.com/entra/identity-platform/tutorial-v2-javascript-spa' });
      }
    }
    if (front.authMode === 'oidc-entra') {
      refs.push({ label: 'Microsoft identity platform — OIDC + PKCE for SPA', url: 'https://learn.microsoft.com/entra/identity-platform/v2-oauth2-auth-code-flow' });
    }
    refs.push({ label: 'Microsoft Entra ID app registration docs', url: 'https://learn.microsoft.com/entra/identity-platform/quickstart-register-app' });
  }
  const back = answers.backend;
  if (answers.hasBackend && back && back.authStyle === 'jwt-validator') {
    refs.push({ label: 'Microsoft identity platform — protected web API', url: 'https://learn.microsoft.com/entra/identity-platform/scenario-protected-web-api-overview' });
    refs.push({ label: 'JWT validation guidance (Microsoft)', url: 'https://learn.microsoft.com/entra/identity-platform/access-tokens#validating-tokens' });
  }
  return refs;
}

function renderWorkflow(answers: WizardAnswers): string {
  const includeInfra = shouldIncludeInfra(answers);
  const infraDesignBullet = includeInfra
    ? '- `infra-design.md` — Terraform module list, resource topology, IAM/secrets approach, environment differences\n'
    : '';
  const phase3Title = includeInfra
    ? '### Phase 3 — Wire to EPIC: build `.pipeline/` and `.infra/` (only after Phase 2 approval)'
    : '### Phase 3 — Wire to EPIC: build `.pipeline/` (only after Phase 2 approval)';
  const phase3Reconcile = includeInfra
    ? '**Before writing anything in this phase, reconcile against the actual Phase 2 result.** The `.epic/` design docs from Phase 1 describe what was *intended*; `code/` after Phase 2 approval describes what *exists*. They will diverge — the user may have asked for a swap (e.g., switched the DB, added a queue, dropped a scheduler), corrected an assumption, added an env var, changed a port, picked a different auth scope, or pinned a different runtime. Phase 3 must wire EPIC to **what actually got built**, not to the stale design. Concretely, before generating `.pipeline/epic.json` or `.infra/`: (1) re-read `code/` end-to-end — `package.json` / `csproj` / `requirements.txt` / `pom.xml` for the runtime, language, and dependency surface; entry points and listeners for ports and protocols; `.env.development` / `appsettings.Development.json` / equivalent for every config key the app reads at runtime; data-access code for which databases/queues/buckets/secrets are actually referenced; auth wiring for tenant/client IDs, redirect URIs, and audiences. (2) Diff that reality against `.epic/app-design.md`, `.epic/infra-design.md`, and `.epic/pipeline-design.md`. (3) For every divergence, **update the `.epic/` doc to match `code/`** and append a row to `overview.md` under a new "Phase 2 → Phase 3 reconciliation" subsection (what the design said, what `code/` does, which one Phase 3 will follow — almost always `code/`). Do not silently rewrite design docs; the reconciliation entry is how the user audits the change. (4) Only then generate `.pipeline/epic.json` (its `app.appType`, `app.codePath`, `app.runtimeVersion`, `cloud.secretsManager.keys`, etc. must reflect `code/`) and the `.infra/` Terraform project (modules, resource counts, IAM policies, secret keys must match what `code/` actually consumes). If you find yourself copying a value from `.epic/` that contradicts `code/`, **stop** — the design lost; reconcile first.'
    : '**Before writing anything in this phase, reconcile against the actual Phase 2 result.** The `.epic/` design docs from Phase 1 describe what was *intended*; `code/` after Phase 2 approval describes what *exists*. They will diverge — the user may have asked for a swap (e.g., changed an env var, picked a different auth scope, switched runtimes, dropped a planned subsystem). Phase 3 must wire EPIC to **what actually got built**, not to the stale design. Concretely, before generating `.pipeline/epic.json`: (1) re-read `code/` end-to-end — `package.json` / `csproj` / `requirements.txt` / `pom.xml` for the runtime, language, and dependency surface; entry points and listeners for ports; `.env.development` / `appsettings.Development.json` / equivalent for every config key the app reads at runtime; auth wiring for tenant/client IDs, redirect URIs, and audiences. (2) Diff that reality against `.epic/app-design.md` and `.epic/pipeline-design.md`. (3) For every divergence, **update the `.epic/` doc to match `code/`** and append a row to `overview.md` under a new "Phase 2 → Phase 3 reconciliation" subsection (what the design said, what `code/` does, which one Phase 3 will follow — almost always `code/`). Do not silently rewrite design docs; the reconciliation entry is how the user audits the change. (4) Only then generate `.pipeline/epic.json` — its `app.appType`, `app.codePath`, `app.runtimeVersion`, etc. must reflect `code/`. If you find yourself copying a value from `.epic/` that contradicts `code/`, **stop** — the design lost; reconcile first.';
  const phase3Body = includeInfra
    ? `${phase3Reconcile}\n\nWith reconciliation done, wire the working app into EPIC. Generate \`.pipeline/epic.json\` and the \`.infra/\` Terraform project per the **EPIC pipeline contract** sections in this document. Do not touch \`code/\` again unless the user explicitly asks. When complete, **stop and summarize**: paths created, modules called, TODO placeholders left in \`terraform.auto.tfvars\`, the **Phase 2 → Phase 3 reconciliation** entries you added to \`overview.md\`, and which **Action required before deploy** items the user must clear before the first pipeline run. Wait for explicit approval before considering the work done.`
    : `${phase3Reconcile}\n\nWith reconciliation done, wire the app into EPIC. Generate \`.pipeline/epic.json\` per the **EPIC pipeline contract** section in this document. The user did not request infrastructure, so do not create \`.infra/\`. Do not touch \`code/\` again unless the user explicitly asks. When complete, **stop and summarize** what was created, the **Phase 2 → Phase 3 reconciliation** entries you added to \`overview.md\`, and any **Action required before deploy** items. Wait for explicit approval before considering the work done.`;
  return [
    '## Workflow — three phases, three approval gates',
    'You will work in three phases. Each phase ends with a stop-and-wait checkpoint. **Do not start the next phase until the user has explicitly approved the current one.** This sequencing is deliberate: the user must be able to build and test the running app before any infrastructure or pipeline wiring locks the shape of the deployment.',
    '',
    '### Phase 1 — Design (write to `.epic/` only)',
    'Create a `.epic/` folder at the repo root and put **every** design document, architecture diagram, data-model sketch, API surface, infra topology note, and other steering artifact you produce inside it. Nothing outside `.epic/` is created in this phase.',
    '',
    '**Avoid asking the user questions during this phase.** This file plus the conventions in the AI-DLC steering should give you enough to make sensible defaults for almost any decision (naming, layout, runtime, library choices, IAM scope, table keys, retry/timeouts, log retention, environment differences, etc.). When you hit a decision the inputs don\'t resolve, **make a reasonable assumption and write it down** — do not block on the user. Only stop and ask when an assumption could materially break security, cost, or contractual constraints (e.g., picking the wrong AWS account, mis-naming a regulated data field, exposing a public bucket).',
    '',
    'At minimum, `.epic/` should contain:',
    '- `overview.md` — **also serves as the assumption ledger.** This is the user\'s single source of truth for everything you decided on their behalf. Structure it as:',
    '  - **Acceptance criteria** — restated from this file, plus the design intent in your own words.',
    '  - **Assumptions made** — bulleted list. Each row: *what was assumed*, *the value you chose*, *why* (one line). Group by area (App, Infra, Pipeline, Auth, Data, Ops).',
    '  - **Action required before deploy** — anything the user must verify, populate, or replace before this app is safe to run in any environment (e.g., "AWS account ID is a placeholder", "client ID needs an app registration", "Secrets Manager keys are listed but unpopulated", "DB instance size assumed `db.t3.medium` — confirm before prod").',
    '  - **Action required before production** — assumptions that are fine for `dev` but must be revisited before `stage`/`prod` (e.g., scaling parameters, retention, alarm thresholds).',
    '  - **Deferred decisions** — anything you intentionally did not decide and the AI-DLC review or user must address later.',
    '  Every assumption you make goes here. If the Assumptions section is empty, you didn\'t actually make assumptions — you punted on the work.',
    '- `app-design.md` — language/framework choices, module layout, key components, auth/data flow',
    infraDesignBullet +
      '- `pipeline-design.md` — the planned shape of `.pipeline/epic.json` and any rationale for non-default fields',
    '',
    '**Phase 1 gate.** When `.epic/` is complete, stop and present `overview.md` to the user. Outline what you intend to create in Phases 2 and 3, call out the **Action required before deploy** items explicitly, and wait for approval. If the user wants to change an assumption, update the relevant `.epic/` doc and `overview.md`, then ask again.',
    '',
    '### Phase 2 — App: build `code/` and verify it runs locally (only after Phase 1 approval)',
    'Build the application itself. Generate everything under `code/` per the approved design — source, tests, README, `.gitignore`, local dev scripts (e.g. `npm run dev`, `dotnet run`, `uvicorn ...`), and any local config (e.g. `.env.development`, `appsettings.Development.json`). The goal of this phase is **a runnable, testable app on the user\'s machine** with no dependency on cloud resources or the EPIC pipeline.',
    '',
    'Do not touch `.pipeline/` or `.infra/` in this phase. If a piece of the app needs cloud state (a real DB, a real queue, real secrets) to run end-to-end, stub or in-memory it for local dev — and capture each stub in `overview.md` under "Action required before deploy" so the user knows what gets swapped in Phase 3.',
    '',
    'Update `overview.md` as you implement. New assumptions, new dev-only stubs, library version pins, anything the user should know about the working app — append to the relevant section.',
    '',
    '**Phase 2 must finish with a fully provisioned local environment, not just source files.** Before declaring Phase 2 complete:',
    '- **Install all dependencies** (`npm install`, `pip install -r requirements.txt` / `uv sync` / `poetry install`, `dotnet restore`, `mvn install -DskipTests`, `composer install`, etc.) and confirm exit code 0. The user must be able to run `npm start` / `dotnet run` immediately after pulling, with no extra "first install the deps" step.',
    '- **Resolve every tooling-configuration diagnostic.** Per the **Bootstrap a working project** protocol above, every `tsconfig*.json` / `angular.json` / `.csproj` / `pyproject.toml` / `pom.xml` / `composer.json` / `eslint.config.*` / `*.tf` must compile or validate with zero warnings *about the config itself*. Specifically: `tsc --noEmit` produces no diagnostics, `ng build` shows no `Angular compiler` config warnings, `dotnet build` shows no `MSBxxxx`/`CSxxxx` project warnings, `npx eslint --max-warnings=0 .` exits 0, `terraform validate` exits 0, etc. **No editor tooltip on a config field is acceptable.** Do not silence diagnostics with flags like `--legacy-peer-deps`, `--quiet`, `--no-error-on-unmatched-pattern`, or by suppressing rule IDs — fix the underlying configuration.',
    '- **Generate trusted local TLS certs** per the **Local-development TLS / HTTPS** section above (`mkcert`, `dotnet dev-certs https --trust`, etc.) and wire them into the dev server. The user must not see a "Not Secure" badge on `https://localhost:*`, and Entra-backed auth must redirect cleanly without browser warnings.',
    '- **Smoke-test the boot.** Actually run the dev server / runtime once and confirm it serves the expected URL with no startup errors *and no tooling warnings*. A boot test is mandatory; "I wrote the code, the test runner exits 0" is not enough.',
    '- **Validate auth wiring (if any).** If the design uses MSAL, OIDC/Entra, JWT validation, or any other auth, *prove* it actually works locally before the gate — do not stop at "the package is installed and the import compiles." Concretely: (1) for **frontend** auth, walk a sign-in round-trip through the dev server (load the app, click sign-in, verify the redirect to `login.microsoftonline.com/<tenantId>` with the expected `client_id` and `redirect_uri`, complete the redirect back, confirm an account is present and a token can be acquired silently); (2) for **backend** JWT validation, hit a protected endpoint with no token (expect 401), then with an expired/wrong-audience token (expect 401), then with a valid token (expect 200) — using a small script or a documented `curl` recipe in the README; (3) confirm the configured `tenantId`, `clientId`, audience, and redirect URI exactly match the values in the **Architecture** section above and the local-dev defaults from **PG&E defaults**. **The redirect URI in code (e.g., `MsalConfiguration.auth.redirectUri`, `PublicClientApplication` config, OIDC PKCE `redirect_uri`) must be byte-identical to the value registered with Entra — including scheme, host, port, and trailing slash; no `/redirect` / `/auth/callback` / `/signin-oidc` / etc. suffixes unless the framework genuinely requires one *and* the user added that exact path to the Entra app registration.** Mismatch produces `AADSTS50011`; if you see that error during validation, the wiring is wrong, fix it before declaring Phase 2 complete. Capture the validation steps you ran (and any "to be provided by IDM" placeholders that blocked full validation) in `overview.md` so the user can re-run them.',
    '',
    '**Phase 2 gate.** When `code/` is complete and the install + cert + boot + auth-validation steps above are done, stop and tell the user how to run and test it locally (commands, expected URLs, expected output, the one-shot setup command if the user is on a fresh machine, and — if auth is wired — exactly how to verify the auth round-trip). The user will exercise the app — happy path and edge cases — and either approve, or send you back with corrections. Do not start Phase 3 until they explicitly approve.',
    '',
    phase3Title,
    phase3Body,
    '',
    'Throughout all three phases: **`.epic/`** is your scratch space for design and the assumption ledger. **`epic.md`** and the **AI-DLC steering files** at the repo root (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) are read-only inputs and must never be modified.',
  ].join('\n');
}

function renderAcceptanceCriteria(answers: WizardAnswers): string {
  const ac = answers.acceptanceCriteria.trim() || '_(no acceptance criteria provided)_';
  return ['## Acceptance criteria', ac].join('\n');
}

function renderAppProfile(answers: WizardAnswers): string {
  const appType = answers.appType as AppType;
  const lines: string[] = [
    '## App profile',
    `- App name: ${answers.appName}`,
    `- App type: ${APP_TYPE_LABELS[appType]} (\`${appType}\`)`,
  ];
  const runtime = DEFAULT_RUNTIME_VERSION[appType];
  if (runtime) {
    lines.push(`- Runtime version: ${runtime} (EPIC default for \`${appType}\`)`);
  }
  return lines.join('\n');
}

function renderCloudTarget(answers: WizardAnswers): string {
  const lines: string[] = ['## Cloud target', `- Provider: ${answers.cloudProvider.toUpperCase()}`];

  const includeInfra = shouldIncludeInfra(answers);

  if (answers.cloudProvider === 'aws' || answers.appType === 'btp') {
    lines.push(`- AWS account: ${answers.awsAccountId || '_(unspecified)_'}`);
    if (includeInfra) lines.push(`- AWS region: ${answers.awsRegion}`);
  }
  if (answers.cloudProvider === 'azure') {
    lines.push(`- Azure subscription: ${answers.azureSubscriptionId || '_(unspecified)_'}`);
    if (includeInfra) lines.push(`- Azure resource group: ${answers.azureResourceGroup || '_(unspecified)_'}`);
  }

  if (!includeInfra && answers.appType) {
    const targetKeys = relevantDeployTargetKeys(answers.appType as AppType, answers.cloudProvider);
    if (targetKeys.length > 0) {
      lines.push('');
      lines.push(...renderDeployTarget(answers.deployTarget, targetKeys));
    }
  }

  return lines.join('\n');
}

function renderDeployTarget(deployTarget: DeployTarget, keys: (keyof DeployTarget)[]): string[] {
  const lines: string[] = ['### Deploy target — where this app will land', ''];
  lines.push(
    'No Terraform was generated for this app — the user opted out of `.infra/` on the Architecture page. **EPIC still needs to know which existing infrastructure to push artifacts to** — the keys below are read directly by the EPIC deploy stage (`epic-pipeline/deploy/main.yml`) and must be set in `.pipeline/epic.json` under `cloud.*`. Leave blanks as `"TODO"` placeholders and capture them in `overview.md` under "Action required before deploy". When Terraform is present, EPIC instead reads the deploy target from Terraform outputs — these flat `cloud.*` fields are not used.',
  );
  lines.push('');
  for (const key of keys) {
    lines.push(`- \`cloud.${key}\` — ${describeDeployKey(key)}: ${formatField(deployTarget[key])}`);
  }
  return lines;
}

function describeDeployKey(key: keyof DeployTarget): string {
  switch (key) {
    case 's3':
      return 'existing S3 bucket name (the SPA bundle is synced into this bucket)';
    case 'cloudfront':
      return 'existing CloudFront distribution ID (used for cache invalidation after each deploy)';
    case 'ec2InstanceId':
      return 'existing EC2 instance ID (the deploy stage uses SSM `RunCommand` to deliver the artifact)';
    case 'appExecutable':
      return 'name of the executable / process (used to restart the service on the EC2 instance)';
    case 'appServiceName':
      return 'existing Azure App Service site name';
    case 'resourceGroupName':
      return 'Azure resource group containing the App Service';
    case 'configDocPrefix':
      return 'SSM document prefix for AMI build config';
    case 'testDocPrefix':
      return 'SSM document prefix for AMI test runs';
    case 'imageRecipeName':
      return 'EC2 Image Builder recipe name';
    case 'appUrl':
      return 'deployed app URL (used by integration tests as `BASE_URL` when no Terraform `app_url` output exists)';
  }
}

function formatField(value: string): string {
  return value && value.trim() ? `\`${value}\`` : '_(TODO — populate before deploy)_';
}

function renderArchitecture(answers: WizardAnswers): string {
  const lines: string[] = ['## Architecture'];

  if (answers.appType === 'btp' || answers.appType === 'infra' || answers.appType === 'ami') {
    lines.push(deploymentShapeForSpecialType(answers.appType));
    lines.push('');
    lines.push(`Infrastructure: ${shouldIncludeInfra(answers) ? 'included' : 'not included'}`);
    return lines.join('\n');
  }

  if (answers.hasFrontend && answers.frontend) {
    lines.push('### Frontend Auth');
    lines.push(`- Auth mode: ${answers.frontend.authMode}`);
    if (frontendAuthUsesEntra(answers.frontend.authMode)) {
      lines.push(`- Entra tenant ID: \`${ENTRA_TENANT_ID}\` (PG&E lab tenant)`);
      lines.push(`- Entra client ID: ${answers.frontend.authClientId ? `\`${answers.frontend.authClientId}\`` : '_(to be provided by PG&E IDM team — request app registration before wiring auth)_'}`);
    }
    lines.push(`- Needs API base URL config: ${answers.frontend.apiBaseUrlNeeded ? 'yes' : 'no'}`);
  }

  if (answers.hasBackend && answers.backend) {
    lines.push('### Backend');
    lines.push(`- Style: ${answers.backend.style}`);
    lines.push(`- Runtime: ${answers.backend.runtime || '_(use AI-DLC default for ' + answers.appType + ')_'}`);
    lines.push(`- Auth: ${answers.backend.authStyle}`);
    if (answers.backend.authStyle === 'jwt-validator') {
      lines.push(`- Entra tenant ID: \`${ENTRA_TENANT_ID}\` (PG&E lab tenant)`);
      lines.push(`- Entra client ID (audience): ${answers.backend.authClientId ? `\`${answers.backend.authClientId}\`` : '_(to be provided by PG&E IDM team — request app registration before wiring auth)_'}`);
    }
  }

  if (answers.needsDatabase && answers.database) {
    lines.push('### Database');
    lines.push(`- Engine: ${answers.database.engine}`);
    lines.push(`- Scale: ${answers.database.scale}`);
  }

  if (answers.needsQueue && answers.queue) {
    lines.push('### Messaging');
    lines.push(`- ${answers.queue.kind}`);
  }

  if (answers.needsScheduler) {
    lines.push('### Scheduler');
    lines.push(`- Schedule: ${answers.schedulerCron || '_(rule TBD — confirm with user)_'}`);
  }

  if (answers.needsStorage && answers.storage) {
    lines.push('### Object storage');
    lines.push(`- ${answers.storage.kind}`);
  }

  if (lines.length === 1) {
    lines.push('_(no architecture toggles selected; this is a minimal scaffold)_');
  }

  lines.push('');
  lines.push(`Infrastructure: ${shouldIncludeInfra(answers) ? 'included' : 'not included'}`);

  return lines.join('\n');
}

function renderWhatYouMustProduce(answers: WizardAnswers): string {
  const includeInfra = shouldIncludeInfra(answers);
  const lines: string[] = [
    '## What you must produce',
    'This app must be runnable through **EPIC** — PG&E\'s `epic-pipeline` orchestrator. Every artifact below has a fixed contract that `epic-pipeline` reads at run time. Deviating from these contracts will break orchestration. Read the contract sections later in this document before writing anything in Phase 3.',
    '',
    'The artifacts below are produced across the three phases described in **Workflow**. Do not produce a later artifact before its phase has been approved.',
    '',
    '**Phase 2 — App** (must run locally before Phase 3 begins):',
    '- **`code/`** — application source code, tests, README, `.gitignore`, and local-dev scripts/config. All app code lives under `code/` at the repo root. Build / test / scan tooling chosen here must match what EPIC expects for this `appType`; the relevant tooling for the chosen `appType` is captured in this document. The app must be runnable and testable on the user\'s machine without needing the EPIC pipeline or any cloud resources.',
    '',
    '**Phase 3 — Wire to EPIC** (only after the user approves the running app):',
    '- **`.pipeline/epic.json`** — must conform exactly to the contract in **EPIC pipeline contract — `.pipeline/epic.json`** later in this document. Stage selection at run time is controlled by the EPIC web UI, **not** this file, so do not embed stage flags.',
  ];
  if (includeInfra) {
    lines.push(
      '- **`.infra/` Terraform project** — must conform exactly to the contract in **EPIC pipeline contract — `.infra/`** (variables, backend, providers, module-only resources). Generate only the resources actually implied by the architecture and approved in `.epic/infra-design.md`.',
    );
  } else {
    lines.push(
      '- _(No `.infra/` folder.)_ The user did not select infrastructure for this app — do not generate Terraform. `epic-pipeline` will skip the infra stage automatically because the folder is absent.',
    );
  }
  lines.push('');
  lines.push(
    'Do not commit secrets. List required Secrets Manager keys in the README and let PG&E ops populate them.',
  );
  return lines.join('\n');
}

function renderToolingAllowlist(answers: WizardAnswers): string {
  const appType = answers.appType as AppType;
  if (NO_ARCHITECTURE_APP_TYPES.includes(appType)) return '';

  const supportedTestTools = BUILD_TEST_TOOL_OPTIONS[appType] ?? [];
  const supportedScanTools = SCAN_TOOL_OPTIONS;
  const supportedIntegrationTools = INTEGRATION_TEST_TOOL_OPTIONS[appType] ?? [];

  const testList = supportedTestTools.length
    ? supportedTestTools.map((t) => `\`${t}\``).join(', ')
    : '_(none — `appType: ' + appType + '` has no EPIC-supported unit-test runner)_';
  const scanList = supportedScanTools.map((t) => `\`${t}\``).join(', ');
  const integrationList = supportedIntegrationTools.length
    ? supportedIntegrationTools.map((t) => `\`${t}\``).join(', ')
    : '_(none — `appType: ' + appType + '` has no EPIC-supported integration-test runner)_';

  const userTestTool = answers.buildTestTool;
  const userScanTool = answers.scanTool;
  const userIntegrationTool = answers.integrationTestTool;

  const lines: string[] = [
    '## Tooling allowlist — only these tools may be added to `code/`',
    `EPIC only knows how to run a fixed set of build/test/scan tools per \`appType\`. **Adding any other tool to \`code/\` is forbidden** — even if it is the framework default. Do not install Karma into Angular, Jasmine into anything, ESLint plugins beyond what the AI-DLC steering specifies, or any other "natural" tool — only the ones listed below.`,
    '',
    `**For \`appType: ${appType}\`, the EPIC-supported tools are:**`,
    `- Unit-test runners: ${testList}`,
    `- Code-scan tools: ${scanList}`,
    `- Integration-test runners: ${integrationList}`,
    '',
    'Apply this rule consistently across both phases:',
    '',
    `**Phase 2 (\`code/\`)** — install, configure, and write tests using **only** the test runner the user selected${userTestTool ? ` (**\`${userTestTool}\`**)` : ' (the user did not select one)'}. Install **only** the scan tool the user selected${userScanTool ? ` (**\`${userScanTool}\`**)` : ' (the user did not select one)'}. Install **only** the integration-test runner the user selected${userIntegrationTool ? ` (**\`${userIntegrationTool}\`**)` : ' (the user did not select one)'}. ${describeToolingPhase2Behavior(answers)}`,
    '',
    `**Phase 3 (\`epic.json\`)** — write \`buildTestTool\` ${userTestTool ? `as \`"${userTestTool}"\`` : '**only if** the user selected one (they did not — omit this field entirely)'}. Write \`scanTool\` ${userScanTool ? `as \`"${userScanTool}"\`` : '**only if** the user selected one (they did not — omit this field entirely)'}. Write \`integrationTestTool\` ${userIntegrationTool ? `as \`"${userIntegrationTool}"\`` : '**only if** the user selected one (they did not — omit this field entirely)'}.`,
    '',
    'If the user later asks to add an unsupported tool, push back: tell them EPIC won\'t run it, and ask whether to (a) drop the request, (b) pick a supported alternative from the list above, or (c) request a new EPIC pipeline capability via the platform team.',
  ];
  return lines.join('\n');
}

function describeToolingPhase2Behavior(answers: WizardAnswers): string {
  const noTest = !answers.buildTestTool;
  const noScan = !answers.scanTool;
  const noIntegration = !answers.integrationTestTool;
  const baseRule = 'Do not pull in framework-default tools (e.g., Karma for Angular, Jasmine, default ESLint configs beyond what the AI-DLC steering specifies) just because they are conventional. The selected tools above are the *only* ones permitted.';
  if (!noTest && !noScan && !noIntegration) return baseRule;
  const omissions: string[] = [];
  if (noTest) {
    omissions.push(
      'do not add **any** unit-testing framework or runner to `code/` — that includes the framework default (e.g., **no Karma/Jasmine for Angular**, no Vitest/Jest for React, no pytest for Python, no JUnit for Java). The user did not select one in the wizard, which means they want the project skipped of unit tests until they decide',
    );
  }
  if (noScan) {
    omissions.push('do not add SonarQube, Wiz, or any other code-scan tooling');
  }
  if (noIntegration) {
    omissions.push('do not add **any** integration-test runner to `code/` (e.g., no Playwright, no Cypress). The user did not select one in the wizard, so leave integration tests out until they decide');
  }
  return `${baseRule} In particular, ${omissions.join('; and ')}. Capture the omission in \`overview.md\` under "Action required before deploy" so the user can opt in later by re-running the wizard or editing \`epic.json\`.`;
}

function renderPgeDefaults(answers: WizardAnswers): string {
  const lines: string[] = [
    '## PG&E defaults — apply these unless the **Detailed Description / Notes** says otherwise',
    'These are the standing PG&E policies. Treat each one as authoritative unless the user overrode it explicitly in the **Detailed Description / Notes** section above. If overridden, log the override in `overview.md` under "Assumptions made" so the reviewer sees it.',
    '',
    '### Bootstrap a working project before writing any feature code',
    'Repeated failure mode: the AI starts writing app code, then fights through a series of `ERESOLVE` / version-mismatch errors mid-stream (e.g., Angular 20 needs TypeScript 5.8+ and `zone.js` ~0.15, `npm install` fails, packages get bumped one at a time after the fact). **This is forbidden.** Set up a clean, installable, runnable project *before* writing a single feature line. Apply this protocol on every new app, regardless of tech stack:',
    '',
    '1. **Use the canonical project initializer for the chosen tech stack.** Examples:',
    '   - Angular → `npx --yes @angular/cli@<major> new <app> --skip-install --skip-git --routing --style=scss` (let the CLI pick the matching TS / RxJS / zone.js versions).',
    '   - React → `npm create vite@latest <app> -- --template react-ts` (or the equivalent recommended scaffolder for React + Vite).',
    '   - Node API → `npm init -y` plus the framework\'s recommended init (e.g., `npx fastify generate`, `nest new`, `express-generator`).',
    '   - .NET → `dotnet new <template> -n <Project> --framework net<X>.0` for the runtime version listed in the **App profile**.',
    '   - Python → `uv init` / `poetry new` / `python -m venv .venv` plus the framework\'s recommended layout (`fastapi[standard]`, `django-admin startproject`, etc.).',
    '   - Java → Spring Initializr CLI, Gradle/Maven init.',
    '   - PHP → `composer create-project` with the framework\'s recommended template.',
    '   Whichever scaffolder you pick, **let it choose the dependency versions** — do not hand-edit `package.json` / `requirements.txt` / `csproj` / `pom.xml` / `composer.json` to invent versions.',
    '',
    '2. **Verify the cold install before doing anything else.** Run the install command (`npm ci` / `npm install`, `pip install`, `dotnet restore`, `mvn -q -DskipTests package`, `composer install`, etc.) and confirm exit code 0. If it fails, **stop, read the actual error**, and fix the *root cause* — do not paper over it with a different version pin. `peerDependencies` conflicts are not solved by `--legacy-peer-deps` or `--force` unless the framework\'s own docs explicitly recommend it.',
    '',
    '3. **Verify the dev server / runtime starts.** Run `npm start` / `dotnet run` / `python -m uvicorn ...` / etc. and confirm it boots cleanly. Boot output must be free of errors *and* free of tooling-configuration warnings (see step 4). This is the floor of "the project works."',
    '',
    '4. **Treat tooling-configuration diagnostics as errors, not warnings.** Editor tooltips, language-server squiggles, build-time deprecation notices, and lint warnings about *configuration files themselves* (not your application code) must be resolved at scaffold time, not deferred. Common examples — fix every one of these before moving on:',
    '   - **TypeScript** — every `tsconfig*.json` must compile with **zero `tsc --noEmit` diagnostics**. Resolve every `TSxxxx` config-level diagnostic (e.g., `TS6504` "common source directory" → set `rootDir`, `TS5023`/`TS5024` invalid options, `TS6133`/`TS6196` unused declarations from compiler flags). If your editor surfaces a tooltip on a config field, that is an unresolved diagnostic — fix it.',
    '   - **ESLint / Prettier** — `npx eslint --max-warnings=0 .` must exit 0. Resolve config-discovery errors, missing parser packages, and "no parserOptions" complaints at the config layer; don\'t suppress them with `--quiet` or `--no-error-on-unmatched-pattern`.',
    '   - **Angular** — `ng build` and `ng serve` must report zero `NG`-prefix or `Angular compiler` warnings about config files (`angular.json`, `tsconfig.app.json`, `tsconfig.spec.json`). Add `"rootDir"` to each project tsconfig if the compiler asks for one.',
    '   - **.NET** — `dotnet build` must produce zero `CSxxxx` / `MSBxxxx` warnings about the `.csproj` / `.sln` itself. Fix `<TargetFramework>` mismatches, missing `<Nullable>` settings, and `<LangVersion>` warnings at the project layer.',
    '   - **Python** — `python -m mypy --strict` (or `pyright --warnings`), `ruff check`, and `python -c "import <pkg>"` must all exit 0. Fix `pyproject.toml` / `setup.cfg` / `mypy.ini` warnings before writing app code.',
    '   - **Java** — `mvn -q -DskipTests verify` and `gradle build --warning-mode all` must produce zero warnings about the build files themselves.',
    '   - **PHP** — `composer validate --strict` must exit 0; `phpstan analyse` and `php-cs-fixer fix --dry-run` must report no issues against config.',
    '   - **Terraform / IaC** — `terraform validate` and `terraform fmt -check` must exit 0. Resolve every provider-version warning before applying.',
    '',
    '   The principle: if a tooling tooltip appears anywhere in the scaffolded *configuration* files (not in your business logic), the configuration is wrong. Fix it at the config layer; do not silence it, do not "TODO it later."',
    '',
    '5. **Verify the test runner runs.** Even with zero tests, run `npm test` / `dotnet test` / `pytest` / `mvn test` and confirm it exits 0. A test runner that doesn\'t start is a sign of a broken install, not a "fix it later" item.',
    '',
    '6. **Pin the runtime version up front.** Add an `.nvmrc` / `engines` block / `global.json` / `runtime.txt` / `.python-version` (whichever is canonical for the stack) matching the **Runtime version** from the **App profile** *before* installing. Avoids the "works on my machine, breaks on the pipeline" gap.',
    '',
    '7. **Only then start writing feature code.** Now you have a known-good baseline; any subsequent install/build break is caused by the work, not by the scaffolding, and is debuggable.',
    '',
    'If the user\'s **Detailed Description / Notes** specifies a tech stack the canonical scaffolder doesn\'t fit (e.g., a custom monorepo, a less-common framework), still follow the spirit of the protocol: lock down a known-good install + boot + test cycle before writing app logic. Capture any deviations in `overview.md`.',
    '',
    '### Local-development redirect URIs (Entra app registrations)',
    'For any Entra app registration you scaffold or document, the **local-development** redirect URIs default to the *exact* values below — **origin only, no path suffix**:',
    '- Web / SPA app (`angular`, `react`, `html`) → `https://localhost:4200`',
    '- Node app (`node`) → `https://localhost:4200` (Node frequently serves a browser-facing SPA on the same origin; treat the redirect as a browser redirect, not an API callback)',
    '- API / backend (`dotnet`, `python`, `java`, `php`) → `http://localhost:5000`',
    '',
    `For this app (\`appType: ${answers.appType}\`), the default local redirect URI is **${defaultLocalRedirectUri(answers.appType as AppType)}** unless the user specified a different URL in the **Detailed Description / Notes**.`,
    '',
    '**Use the value above verbatim.** Do not append `/redirect`, `/auth/callback`, `/signin-oidc`, `/oauth2/callback`, `/login`, `/index.html`, or any other path. Common AI failure mode: training-data tutorials show paths like `/redirect` or `/auth/callback`, but the registered Entra app for this app uses the bare origin. Mismatched paths trigger `AADSTS50011: redirect URI \'...\' specified in the request does not match the redirect URIs configured for the application` at sign-in. The MSAL configuration value (`auth.redirectUri` in `MsalConfiguration`, `redirect_uri` in PKCE flows, etc.) and the value registered with Entra **must be byte-identical**.',
    '',
    'If the chosen framework genuinely requires a path-suffix redirect (rare — confirm in the framework\'s official docs first, not a tutorial), you must (a) call this out as an assumption in `overview.md`, (b) tell the user the exact path you used, and (c) tell the user it must be added to the Entra app registration before sign-in will succeed. Default behavior is still: no path suffix.',
    '',
    'Production redirect URIs are not assumed — leave them as TODOs in `overview.md` for the user to confirm.',
    '',
    '### Local-development TLS / HTTPS',
    'Any app that runs on `https://localhost:*` locally — which includes every SPA / Node app on `4200` because Entra requires HTTPS for redirect URIs — **must serve a trusted local certificate** so the browser does not display the "Not Secure" badge or block MSAL redirects. As part of Phase 2, scaffold trusted local TLS:',
    '',
    '1. **Generate trusted local certs** with the right tool for the platform:',
    '   - **Node / SPA / cross-platform** → `mkcert` (preferred — installs a local trust root once, then `mkcert localhost 127.0.0.1 ::1` produces a cert + key the OS already trusts).',
    '   - **.NET API** → `dotnet dev-certs https --trust` (built into the SDK, no extra tooling).',
    '   - **Python / Java / PHP API** → `mkcert` is fine; document the path to the generated `.pem` files.',
    '2. **Wire the cert into the local dev server** (`ng serve --ssl --ssl-cert ... --ssl-key ...`, Vite\'s `server.https`, `app.UseHttpsRedirection()` for ASP.NET, `uvicorn --ssl-keyfile/--ssl-certfile` for FastAPI, etc.). Drop the generated `*.pem` files into a `code/.certs/` folder and add `.certs/` to `.gitignore` — never commit certs.',
    '3. **Add a one-shot setup script** (`npm run setup:certs`, `make certs`, or equivalent) that the README points at. The user runs it once per machine; from then on `npm start` / `dotnet run` "just works" with HTTPS and no browser warnings.',
    '4. **Document it in the README** under a "Local development" section: the prerequisite (`mkcert` install or `dotnet dev-certs --trust`), the one-shot command, and the URL the dev server lands on.',
    '',
    'If the user explicitly opted out of local HTTPS in the **Detailed Description / Notes**, skip this — but log the deviation in `overview.md` under "Assumptions made," because Entra-backed auth will not work without HTTPS.',
    '',
    '### CloudFront / public exposure',
    '**Default access posture is PG&E-internal only.** Do not configure a CloudFront distribution (or any other resource) for public-internet access unless the user explicitly asked for it in the **Detailed Description / Notes**. When in doubt, scope to PG&E\'s internal network — viewer-restriction policy, internal WAF rule set, no public OAI bypass — and note the choice in `overview.md`.',
    '',
    '### `.infra/terraform.auto.tfvars` placeholders',
    'For any value in `.infra/terraform.auto.tfvars` that the user did not pin down in the wizard or hints (account IDs, ARNs, hostnames, certificate ARNs, KMS key IDs, alert email recipients, etc.), write a **TODO placeholder** in the file rather than guessing or omitting the variable. Example:',
    '',
    '```hcl',
    'aws_account_id = "TODO" # 12-digit AWS account ID — required before deploy',
    'alarm_email    = "TODO" # ops contact for CloudWatch alarms',
    '```',
    '',
    'Every TODO must be listed in `overview.md` under **Action required before deploy** so the user has one place to clear them.',
  ];
  return lines.join('\n');
}

function renderEpicJsonContract(answers: WizardAnswers): string {
  const lines: string[] = [
    '## EPIC pipeline contract — `.pipeline/epic.json`',
    'The EPIC orchestrator reads this file at run time to detect cloud provider, resolve `infraPath`, tag the run, and pass parameters to the engine. The shape below is the contract; do not invent fields, do not rename fields, and do not move them.',
    '',
    '**Required fields:**',
    '- `app.appName` (string) — must match the directory and ADO build tag.',
    `- \`app.appType\` (string) — must be \`${answers.appType}\`. The engine dispatches build/test/scan templates by this exact value.`,
    '- `app.codePath` (string, default `/`) — path to source under the repo root. With this template, set to `code/`.',
    '- `app.infraPath` (string, default `.infra`) — path to the Terraform project. The orchestrator skips the infra stage entirely when this folder is missing.',
    '- `cloud.*` — cloud-target fields. The orchestrator detects provider via this rule:',
    '  - `app.appType == "btp"` → BTP (with AWS Secrets Manager for credentials).',
    '  - `cloud.awsAccountId` present → AWS.',
    '  - `cloud.azureSubscriptionId` present → Azure.',
    `- **Deploy-target fields under \`cloud.*\` (only when \`.infra/\` is absent).** ${describeDeployTargetContract(answers)}`,
    '',
    'Write `.pipeline/epic.json` exactly like this (replace placeholder values; keep keys and nesting):',
    '',
    '```json',
    renderEpicJsonSkeleton(answers),
    '```',
    '',
    'Optional fields the orchestrator/engine recognize:',
    '- `app.runtimeVersion` — runtime override; defaults are baked into engine templates by appType.',
    '- `app.scanTool` — code-scan tool (e.g. `sonarqube`).',
    '- `app.buildTestTool` — unit-test runner (e.g. `jest`, `pytest`, `xunit`).',
    '- `app.integrationTestTool` — integration-test runner.',
    '- `app.approvalEnvironments` — array of environments (e.g. `["prod"]`) that require an approval gate.',
    '',
    `**Optional-field omission rule.** The skeleton above is the *complete* set of fields you should write. ${describeToolFieldOmissions(answers)} Do not invent fields, do not add custom fields, and do not write \`scanTool\` / \`buildTestTool\` / \`integrationTestTool\` keys with empty or null values "for completeness" — omit them. The **Tooling allowlist** section earlier in this document is also binding here: if you did not install a tool in \`code/\`, it must not appear in \`epic.json\`.`,
    '',
    'Anything not listed above is ignored by `epic-pipeline`. Do not add custom fields hoping the engine will pick them up — it will not.',
  ];
  return lines.join('\n');
}

function describeToolFieldOmissions(answers: WizardAnswers): string {
  const omitted: string[] = [];
  if (!answers.scanTool) omitted.push('`scanTool`');
  if (!answers.buildTestTool) omitted.push('`buildTestTool`');
  if (!answers.integrationTestTool) omitted.push('`integrationTestTool`');
  if (omitted.length === 0) return 'All optional fields the user asked for are already in the skeleton.';
  return `The user did not select ${omitted.join(' or ')} in the wizard, so **omit ${omitted.length === 1 ? 'this field' : 'these fields'} entirely** from \`.pipeline/epic.json\`.`;
}

function renderEpicJsonSkeleton(answers: WizardAnswers): string {
  const appType = answers.appType as AppType;
  const app: Record<string, any> = {
    appName: answers.appName,
    appType,
    codePath: 'code/',
    infraPath: '.infra',
  };
  const runtime = DEFAULT_RUNTIME_VERSION[appType];
  if (runtime) app['runtimeVersion'] = runtime;
  if (answers.scanTool) app['scanTool'] = answers.scanTool;
  if (answers.buildTestTool) app['buildTestTool'] = answers.buildTestTool;
  if (answers.integrationTestTool) app['integrationTestTool'] = answers.integrationTestTool;
  const cloud: Record<string, any> = {};
  if (answers.cloudProvider === 'aws' || answers.appType === 'btp') {
    cloud['awsAccountId'] = answers.awsAccountId || '<12-digit-account-id>';
    cloud['awsRegion'] = answers.awsRegion;
  }
  if (answers.cloudProvider === 'azure') {
    cloud['azureSubscriptionId'] = answers.azureSubscriptionId || '<subscription-uuid>';
  }
  if (answers.appType === 'btp') {
    cloud['secretsManager'] = {
      name: `${answers.appName}-btp-secrets`,
      keys: ['BTP_USERNAME', 'BTP_PASSWORD', 'CF_USER', 'CF_PASSWORD'],
    };
  }
  if (!shouldIncludeInfra(answers) && answers.appType) {
    const targetKeys = relevantDeployTargetKeys(answers.appType as AppType, answers.cloudProvider);
    for (const key of targetKeys) {
      cloud[key] = answers.deployTarget[key] && answers.deployTarget[key].trim() ? answers.deployTarget[key] : 'TODO';
    }
  }
  return JSON.stringify({ app, cloud }, null, 2);
}

function describeDeployTargetContract(answers: WizardAnswers): string {
  if (shouldIncludeInfra(answers)) {
    return 'This app is generating a `.infra/` Terraform project, so the EPIC deploy stage reads the deploy target from Terraform outputs (e.g. the `app_url` output). Do not add deploy-target fields under `cloud.*` for this app.';
  }
  if (!answers.appType) return 'No appType selected.';
  const keys = relevantDeployTargetKeys(answers.appType as AppType, answers.cloudProvider);
  if (keys.length === 0) {
    return 'This appType has no flat deploy-target keys defined under `cloud.*`.';
  }
  const list = keys.map((k) => `\`cloud.${k}\``).join(', ');
  return `This app is **not** generating any Terraform — the user opted out of infrastructure on the Architecture page. EPIC therefore needs to know which existing resources to push artifacts to. The EPIC deploy stage reads these specific keys from \`epic.json\` for \`appType: ${answers.appType}\` on \`${answers.cloudProvider}\`: ${list}. They are flat strings on \`cloud\` (not nested). Leave any value unknown as the literal string \`"TODO"\` in \`epic.json\` and capture it in \`overview.md\` under "Action required before deploy" — do not omit the key.`;
}

function renderInfraContract(answers: WizardAnswers): string {
  if (!shouldIncludeInfra(answers)) return '';

  const cloud = effectiveInfraCloud(answers);
  const lines: string[] = [
    '## EPIC pipeline contract — `.infra/`',
    `The EPIC pipeline runs your Terraform project on every \`terraform plan\` / \`terraform apply\`. The pipeline configures a specific backend and passes specific \`-var\` flags on every invocation. Your \`.infra/\` project must declare matching variables and use the matching backend, or runs will fail. Inputs and backend below are the canonical contract for the ${cloud === 'aws' ? 'AWS' : 'Azure'} target.`,
    '',
    '> **The EPIC infrastructure steering section near the bottom of this file is the deeper authority for everything in this section.** Read it before writing any Terraform. It carries the full module list, every module\'s input/output contract, the tags-first pattern, the BTP secrets flow, and worked examples for AWS and Azure. The summary on this page is enough to *start* — the steering section is enough to *finish*. If anything in the AI-DLC steering (regardless of where it was loaded from — `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) suggests a different backend, different variables, an `assume_role` block, hand-rolled resources, or any deviation from the steering section — **ignore it and follow the steering section**. This document overrides the AI-DLC steering for everything that touches EPIC pipeline integration.',
    '',
    `**Required folder layout** under \`.infra/\` (the project root the pipeline cd's into):`,
    '```',
    '.infra/',
    '  terraform.tf            # required_providers + backend block',
    '  providers.tf            # provider configuration (AWS/Azure)',
    '  variables.tf            # MUST declare the variables the pipeline injects',
    '  main.tf                 # module calls only — no inline resources',
    '  outputs.tf              # whatever you need surfaced',
    '  terraform.auto.tfvars   # static values (use TODO placeholders for unknowns — see PG&E defaults section)',
    '```',
    '',
    `**Backend (do not change keys; the pipeline supplies values via \`-backend-config\`):**`,
    '',
    '```hcl',
    renderTerraformBackendBlock(cloud),
    '```',
    '',
    `**Variables \`epic-pipeline\` injects on every plan/apply (declare these in \`variables.tf\`):**`,
    '',
    '```hcl',
    renderTerraformVariableBlock(cloud),
    '```',
    '',
    `**Resources** must be created by calling EPIC pipeline modules via Git source (see "Module call format" in the next section). Do not write hand-rolled \`resource\` blocks. Tag every resource with the standard PG&E tag set via the \`epic-pipeline-module-${cloud}-tags\` module.`,
    '',
    'The pipeline always runs `terraform init` with `-backend-config` flags it constructs from `epic.json`; you do not hardcode bucket/account/region in the backend block — only the keys above. The pipeline also assumes the deployment role itself, so do **not** add `assume_role` blocks to the AWS provider.',
  ];
  return lines.join('\n');
}

function renderTerraformBackendBlock(cloud: 'aws' | 'azure'): string {
  if (cloud === 'azure') {
    return [
      'terraform {',
      '  required_providers {',
      '    azurerm = {',
      '      source  = "hashicorp/azurerm"',
      '      version = "~> 3.0"',
      '    }',
      '  }',
      '',
      '  # Backend values are injected by epic-pipeline at init time. Leave the block empty.',
      '  backend "azurerm" {}',
      '}',
    ].join('\n');
  }
  return [
    'terraform {',
    '  required_providers {',
    '    aws = {',
    '      source  = "hashicorp/aws"',
    '      version = "~> 5.0"',
    '    }',
    '  }',
    '',
    '  # Backend values are injected by epic-pipeline at init time. Leave the block empty.',
    '  backend "s3" {}',
    '}',
  ].join('\n');
}

function renderTerraformVariableBlock(cloud: 'aws' | 'azure'): string {
  if (cloud === 'azure') {
    return [
      'variable "subscription_id" {',
      '  description = "Injected by epic-pipeline (CLOUD_AZURE_SUBSCRIPTION_ID)."',
      '  type        = string',
      '}',
      '',
      'variable "tenant_id" {',
      '  description = "Injected by epic-pipeline (Azure CLI tenant)."',
      '  type        = string',
      '}',
      '',
      'variable "azure_region" {',
      '  description = "Injected by epic-pipeline (CLOUD_AZURE_REGION)."',
      '  type        = string',
      '}',
      '',
      'variable "environment" {',
      '  description = "Injected by epic-pipeline (dev | test | stage | prod)."',
      '  type        = string',
      '}',
    ].join('\n');
  }
  return [
    'variable "aws_account_id" {',
    '  description = "Injected by epic-pipeline (CLOUD_AWS_ACCOUNT_ID)."',
    '  type        = string',
    '}',
    '',
    'variable "aws_region" {',
    '  description = "Injected by epic-pipeline (CLOUD_AWS_REGION)."',
    '  type        = string',
    '}',
    '',
    'variable "environment" {',
    '  description = "Injected by epic-pipeline (dev | test | stage | prod)."',
    '  type        = string',
    '}',
  ].join('\n');
}

function effectiveInfraCloud(answers: WizardAnswers): 'aws' | 'azure' {
  // BTP and infra projects still use AWS-side state and Secrets Manager.
  if (answers.cloudProvider === 'azure') return 'azure';
  return 'aws';
}

function renderRepoLayout(answers: WizardAnswers): string {
  const includeInfra = shouldIncludeInfra(answers);
  const layout = [
    '<repo-root>/',
    '  AGENTS.md / CLAUDE.md / .cursorrules / etc.   # PG&E AI-DLC steering (already in place, read-only)',
    '  .epic/         # design docs from Phase 1 (kept in the repo)',
    '  .pipeline/',
    '    epic.json',
    includeInfra ? '  .infra/          # Terraform project' : null,
    '  code/            # application source',
    '  epic.md    # this file (read-only) — includes EPIC infrastructure steering',
  ]
    .filter((l): l is string => l !== null)
    .join('\n');
  return ['## Final repo layout (after Phase 2)', '```', layout, '```'].join('\n');
}

function renderExtraNotes(answers: WizardAnswers): string {
  const notes = answers.extraNotes.trim();
  if (!notes) return '';
  return ['## Open items / extra notes', notes].join('\n');
}

function renderModuleCatalog(answers: WizardAnswers): string {
  if (!shouldIncludeInfra(answers)) return '';

  const modules = modulesForAnswers(answers);
  if (modules.length === 0) return '';

  const lines: string[] = [
    '## EPIC pipeline modules — use these for `.infra/`',
    '**This list is authoritative.** Every Terraform resource in `.infra/` must be created by calling one of the modules below. Do not hand-roll resources, do not invent module names, and do not substitute equivalents from the public Terraform registry. The catalog is scoped to the cloud target selected for this app.',
    '',
    '### Module call format',
    'Every module is hosted as its own GitHub repo under the `pgetech` org. Source each module by Git URL with the `main` ref. Example:',
    '',
    '```hcl',
    'module "tags" {',
    '  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"',
    '',
    '  # ...module inputs...',
    '}',
    '```',
    '',
    'Substitute the module name from the catalog below. **Do not** use a local `source = "../..."` path or any local filesystem reference — this repo is self-contained and the modules live in separate repos.',
    '',
    '### Module catalog',
    '',
    '| Module | Purpose |',
    '| --- | --- |',
    ...modules.map((m) => `| \`${m.name}\` | ${m.purpose} |`),
    '',
    'For each module you call, **first** consult the **EPIC infrastructure steering** section near the bottom of this file for the module\'s documented input/output signature and any required tagging conventions. If that section does not cover a specific input, fetch and read the module\'s own `variables.tf` and `outputs.tf` from its GitHub repo (`https://github.com/pgetech/<module-name>`) before writing the call. The catalog above tells you *which* module to use; the steering section and the module\'s own files together tell you *how* to call it.',
    '',
    'If the design calls for a cloud resource that has no module above:',
    '1. **Stop and tell the user.** Name the missing capability (e.g. "AWS ElastiCache Redis", "Azure Cosmos DB") and explain why the app needs it.',
    '2. Instruct the user to request a new EPIC pipeline module by opening a request with the EPIC platform team — a new `epic-pipeline-module-<cloud>-<resource>` repo will be created under the `pgetech` GitHub org.',
    '3. Capture the gap in `.epic/infra-design.md` under an "Awaiting modules" section so the design review surfaces it.',
    '4. Do **not** silently hand-roll the resource in `.infra/`. Wait for the new module, or get explicit user approval to use a stop-gap inline resource that will be migrated once the module exists.',
  ];

  return lines.join('\n');
}

function modulesForAnswers(answers: WizardAnswers): PipelineModule[] {
  if (answers.cloudProvider === 'azure') return AZURE_MODULES;
  // AWS, BTP (BTP infra still uses AWS Secrets Manager etc.), and infra default to AWS catalog.
  return AWS_MODULES;
}

function frontendAuthUsesEntra(authMode: string): boolean {
  return authMode === 'oidc-entra' || authMode === 'msal';
}

function defaultLocalRedirectUri(appType: AppType): string {
  if (appType === 'angular' || appType === 'react' || appType === 'html' || appType === 'node') {
    return 'https://localhost:4200';
  }
  if (appType === 'dotnet' || appType === 'python' || appType === 'java' || appType === 'php') {
    return 'http://localhost:5000';
  }
  return '_(no default — this app type does not host an HTTP entrypoint)_';
}

function shouldIncludeInfra(answers: WizardAnswers): boolean {
  if (answers.appType === 'infra') return true;
  return answers.includeInfra;
}

function deploymentShapeForSpecialType(appType: 'btp' | 'infra' | 'ami'): string {
  switch (appType) {
    case 'btp':
      return 'This is a SAP BTP / Cloud Foundry deployment. There is no separate frontend/backend/database to scaffold — the deliverable is the BTP environment definition plus its Terraform.';
    case 'infra':
      return 'This is an infrastructure-only project. There is no application code — the deliverable is the Terraform under `.infra/`.';
    case 'ami':
      return 'This is an AMI/Image Builder project. The deliverable is the AMI definition plus its supporting infrastructure.';
  }
}
