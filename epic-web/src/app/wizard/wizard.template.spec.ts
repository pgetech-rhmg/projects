import { renderEpicMd } from './wizard.template';
import { WizardAnswers, emptyAnswers } from './wizard.model';

function baseAnswers(overrides: Partial<WizardAnswers> = {}): WizardAnswers {
  return {
    ...emptyAnswers('Test User'),
    appName: 'sample-app',
    appType: 'angular',
    acceptanceCriteria: '- Returns 200 on /health\n- Persists records',
    generatedAt: '2026-06-09T00:00:00Z',
    generatedBy: 'Test User',
    awsAccountId: '123456789012',
    ...overrides,
  };
}

describe('renderEpicMd', () => {
  it('always emits the canonical section headings', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('# epic.md — sample-app');
    expect(md).toContain('## Prerequisites — do this first');
    expect(md).toContain('## Workflow — three phases, three approval gates');
    expect(md).toContain('## Acceptance criteria');
    expect(md).toContain('## App profile');
    expect(md).toContain('## Cloud target');
    expect(md).toContain('## Architecture');
    expect(md).toContain('## What you must produce');
    expect(md).toContain('## Final repo layout (after Phase 2)');
  });

  it('locks epic.md and the AI-DLC steering files as read-only inputs', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('**This file and the AI-DLC steering are read-only inputs.**');
    expect(md).toContain('Do not edit, append to, rewrite, reformat, or delete');
    expect(md).toContain('CLAUDE.md');
    expect(md).toContain('AGENTS.md');
  });

  it('asserts epic.md as the controller for the session', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('**`epic.md` is now your controller.**');
    expect(md).toContain('regardless of *how* the AI-DLC content reaches you');
  });

  it('points the AI at the embedded EPIC infrastructure steering section', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('Locate the **EPIC infrastructure steering — full reference** section near the bottom of this file.');
  });

  it('keeps the final repo layout free of the old standalone steering file', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).not.toContain('epic-infra.md');
    expect(md).toContain('epic.md    # this file (read-only) — includes EPIC infrastructure steering');
  });

  it('emits the EPIC infrastructure steering section header', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('## EPIC infrastructure steering — full reference');
  });

  it('embeds the steering content when provided', () => {
    const md = renderEpicMd(baseAnswers(), '# Test Steering Content\n\nHello world.');
    expect(md).toContain('# Test Steering Content');
    expect(md).toContain('Hello world.');
  });

  it('emits a placeholder warning when steering content is missing', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('was not embedded');
  });

  it('cites the embedded steering section as the deeper authority in the .infra contract', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('The EPIC infrastructure steering section near the bottom of this file is the deeper authority');
  });

  it('cites the embedded steering section as the per-module input source', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('**first** consult the **EPIC infrastructure steering** section near the bottom of this file');
  });

  it('does not emit a Goal section (description field has been removed)', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).not.toContain('## Goal');
  });

  it('embeds the EPIC default runtime in the App profile', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'react' }));
    expect(md).toContain('Runtime version: 20 (EPIC default for `react`)');
  });

  it('omits runtime line for app types with no runtime (btp/infra/ami)', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'btp', cloudProvider: 'aws' }));
    expect(md).not.toContain('Runtime version:');
  });

  it('embeds runtimeVersion in the epic.json skeleton when applicable', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'python' }));
    expect(md).toContain('"runtimeVersion": "3.11"');
  });

  it('omits runtimeVersion in the epic.json skeleton for infra apps', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'infra' }));
    expect(md).not.toContain('"runtimeVersion"');
  });

  it('emits all three phases with explicit approval gates between them', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('Phase 1 — Design (write to `.epic/` only)');
    expect(md).toContain('Phase 2 — App: build `code/` and verify it runs locally (only after Phase 1 approval)');
    expect(md).toContain('Phase 3 — Wire to EPIC');
    expect(md).toContain('only after Phase 2 approval');
    expect(md).toContain('Phase 1 gate');
    expect(md).toContain('Phase 2 gate');
  });

  it('makes Phase 2 about a runnable local app, not the pipeline', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('a runnable, testable app on the user\'s machine');
    expect(md).toContain('Do not touch `.pipeline/` or `.infra/` in this phase');
  });

  it('requires Phase 2 to install deps, generate certs, smoke-test the boot, and validate auth before the gate', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('**Phase 2 must finish with a fully provisioned local environment, not just source files.**');
    expect(md).toContain('**Install all dependencies**');
    expect(md).toContain('**Generate trusted local TLS certs**');
    expect(md).toContain('**Smoke-test the boot.**');
    expect(md).toContain('**Validate auth wiring (if any).**');
    expect(md).toContain('do not stop at "the package is installed and the import compiles."');
    expect(md).toContain('walk a sign-in round-trip through the dev server');
    expect(md).toContain('hit a protected endpoint with no token (expect 401)');
  });

  it('Phase 3 title includes .infra when infra is selected', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('Phase 3 — Wire to EPIC: build `.pipeline/` and `.infra/`');
  });

  it('Phase 3 title omits .infra when infra is not selected', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: false }));
    expect(md).toContain('Phase 3 — Wire to EPIC: build `.pipeline/`');
    expect(md).not.toContain('Phase 3 — Wire to EPIC: build `.pipeline/` and `.infra/`');
  });

  it('forces Phase 3 to reconcile the design docs against what was actually built in Phase 2', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('**Before writing anything in this phase, reconcile against the actual Phase 2 result.**');
    expect(md).toContain('describe what was *intended*');
    expect(md).toContain('describes what *exists*');
    expect(md).toContain('wire EPIC to **what actually got built**');
    expect(md).toContain('Phase 2 → Phase 3 reconciliation');
    expect(md).toContain('the design lost; reconcile first');
  });

  it('reconciliation rule applies even when only .pipeline/ is being written', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: false }));
    expect(md).toContain('**Before writing anything in this phase, reconcile against the actual Phase 2 result.**');
    expect(md).toContain('Phase 2 → Phase 3 reconciliation');
  });

  it('tells the AI to avoid asking questions during design and to record assumptions in overview.md', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('**Avoid asking the user questions during this phase.**');
    expect(md).toContain('make a reasonable assumption and write it down');
    expect(md).toContain('`overview.md` — **also serves as the assumption ledger.**');
    expect(md).toContain('Action required before deploy');
    expect(md).toContain('Action required before production');
    expect(md).not.toContain('summary.md');
  });

  it('forbids stage flags in epic.json (run-time concern)', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md).toContain('do not embed stage flags');
  });

  it('includes infra design doc and .infra artifact when includeInfra=true', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('infra-design.md');
    expect(md).toContain('`.infra/` Terraform project');
    expect(md).toContain('Infrastructure: included');
    expect(md).toContain('.infra/          # Terraform project');
  });

  it('omits infra design doc and .infra artifact when includeInfra=false', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: false }));
    expect(md).not.toContain('infra-design.md');
    expect(md).not.toContain('`.infra/` Terraform project');
    expect(md).toContain('Infrastructure: not included');
    expect(md).toContain('do not generate Terraform');
    expect(md).not.toContain('.infra/          # Terraform project');
  });

  it('forces infra=included for appType=infra regardless of toggle', () => {
    const md = renderEpicMd(
      baseAnswers({ appType: 'infra', includeInfra: false }),
    );
    expect(md).toContain('Infrastructure: included');
    expect(md).toContain('infra-design.md');
  });

  it('replaces architecture toggles with deployment-shape line for btp', () => {
    const md = renderEpicMd(
      baseAnswers({
        appType: 'btp',
        cloudProvider: 'aws',
        hasFrontend: true,
        hasBackend: true,
      }),
    );
    expect(md).toContain('SAP BTP / Cloud Foundry deployment');
    expect(md).not.toContain('### Frontend Auth');
    expect(md).not.toContain('### Backend');
  });

  it('replaces architecture toggles with deployment-shape line for ami', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'ami', hasBackend: true }));
    expect(md).toContain('AMI/Image Builder project');
    expect(md).not.toContain('### Backend');
  });

  it('replaces architecture toggles with deployment-shape line for infra', () => {
    const md = renderEpicMd(baseAnswers({ appType: 'infra', hasBackend: true }));
    expect(md).toContain('infrastructure-only project');
    expect(md).not.toContain('### Backend');
  });

  it('renders Frontend Auth section with auth mode when hasFrontend is true', () => {
    const md = renderEpicMd(
      baseAnswers({
        appType: 'react',
        hasFrontend: true,
        frontend: { authMode: 'oidc-entra', authClientId: '', apiBaseUrlNeeded: true },
      }),
    );
    expect(md).toContain('### Frontend Auth');
    expect(md).toContain('Auth mode: oidc-entra');
    expect(md).toContain('Needs API base URL config: yes');
    // Framework label was dropped — appType already conveys the framework via App profile.
    expect(md).not.toContain('Framework:');
  });

  it('renders backend section with runtime when hasBackend is true', () => {
    const md = renderEpicMd(
      baseAnswers({
        appType: 'node',
        hasBackend: true,
        backend: { style: 'lambda-per-endpoint', runtime: 'nodejs20.x', authStyle: 'jwt-validator', authClientId: '' },
      }),
    );
    expect(md).toContain('### Backend');
    expect(md).toContain('Style: lambda-per-endpoint');
    expect(md).toContain('Runtime: nodejs20.x');
    expect(md).toContain('Auth: jwt-validator');
  });

  describe('Entra auth (frontend)', () => {
    it('emits the static Entra tenant ID when authMode is oidc-entra', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'react',
          hasFrontend: true,
          frontend: { authMode: 'oidc-entra', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('Entra tenant ID: `44ae661a-ece6-41aa-bc96-7c2c85a08941`');
    });

    it('emits the static Entra tenant ID when authMode is msal', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'angular',
          hasFrontend: true,
          frontend: { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('Entra tenant ID: `44ae661a-ece6-41aa-bc96-7c2c85a08941`');
    });

    it('emits the user-provided client ID when set', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'react',
          hasFrontend: true,
          frontend: { authMode: 'oidc-entra', authClientId: 'abc-123', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('Entra client ID: `abc-123`');
    });

    it('emits a placeholder when no client ID is provided', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'react',
          hasFrontend: true,
          frontend: { authMode: 'oidc-entra', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('to be provided by PG&E IDM team');
    });

    it('omits Entra fields when authMode is none', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'react',
          hasFrontend: true,
          frontend: { authMode: 'none', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      // Workflow text includes "client ID" as an example assumption; check the architecture section specifically.
      expect(md).not.toContain('- Entra tenant ID');
      expect(md).not.toContain('- Entra client ID');
    });
  });

  describe('Entra auth (backend jwt-validator)', () => {
    it('emits tenant + client ID when authStyle is jwt-validator', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'node',
          hasBackend: true,
          backend: { style: 'lambda-per-endpoint', runtime: '', authStyle: 'jwt-validator', authClientId: 'svc-456' },
        }),
      );
      expect(md).toContain('Entra tenant ID: `44ae661a-ece6-41aa-bc96-7c2c85a08941`');
      expect(md).toContain('Entra client ID (audience): `svc-456`');
    });

    it('omits Entra fields when authStyle is api-key', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'node',
          hasBackend: true,
          backend: { style: 'rest-api', runtime: '', authStyle: 'api-key', authClientId: '' },
        }),
      );
      expect(md).not.toContain('- Entra tenant ID');
    });
  });

  describe('scan/test tools', () => {
    it('emits scanTool in epic.json skeleton when set', () => {
      const md = renderEpicMd(baseAnswers({ scanTool: 'sonarqube' }));
      expect(md).toContain('"scanTool": "sonarqube"');
    });

    it('emits buildTestTool in epic.json skeleton when set', () => {
      const md = renderEpicMd(baseAnswers({ buildTestTool: 'jest' }));
      expect(md).toContain('"buildTestTool": "jest"');
    });

    it('emits integrationTestTool in epic.json skeleton when set', () => {
      const md = renderEpicMd(baseAnswers({ integrationTestTool: 'playwright' }));
      expect(md).toContain('"integrationTestTool": "playwright"');
    });

    it('omits scanTool/buildTestTool/integrationTestTool when not set', () => {
      const md = renderEpicMd(baseAnswers({ scanTool: '', buildTestTool: '', integrationTestTool: '' }));
      expect(md).not.toContain('"scanTool"');
      expect(md).not.toContain('"buildTestTool"');
      expect(md).not.toContain('"integrationTestTool"');
    });

    it('explicitly tells the AI to omit scanTool when only it is unselected', () => {
      const md = renderEpicMd(
        baseAnswers({ scanTool: '', buildTestTool: 'jest', integrationTestTool: 'playwright' }),
      );
      expect(md).toContain('did not select `scanTool` in the wizard');
      expect(md).toContain('omit this field');
    });

    it('explicitly tells the AI to omit all three tool fields when none are selected', () => {
      const md = renderEpicMd(baseAnswers({ scanTool: '', buildTestTool: '', integrationTestTool: '' }));
      expect(md).toContain('did not select `scanTool` or `buildTestTool` or `integrationTestTool`');
      expect(md).toContain('omit these fields');
    });

    it('confirms all optional fields are present when all three tools are selected', () => {
      const md = renderEpicMd(
        baseAnswers({ scanTool: 'sonarqube', buildTestTool: 'jest', integrationTestTool: 'playwright' }),
      );
      expect(md).toContain('All optional fields the user asked for are already in the skeleton.');
    });

    it('lists the per-appType integration-test runner allowlist', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular' }));
      expect(md).toContain('Integration-test runners: `playwright`');
    });
  });

  describe('tooling allowlist', () => {
    it('emits the section for non-special app types', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular' }));
      expect(md).toContain('## Tooling allowlist — only these tools may be added to `code/`');
    });

    it('lists the EPIC-supported test runners for the chosen appType', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'react' }));
      expect(md).toContain('Unit-test runners: `jest`, `vitest`');
    });

    it('forbids framework-default tools (e.g. Karma for Angular) when no test tool is selected', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular', buildTestTool: '' }));
      expect(md).toContain('**no Karma/Jasmine for Angular**');
      expect(md).toContain('do not add **any** unit-testing framework');
      expect(md).toContain('Action required before deploy');
    });

    it('names the selected test tool explicitly when one was chosen', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular', buildTestTool: 'jest' }));
      expect(md).toContain('test runner the user selected (**`jest`**)');
      expect(md).toContain('Do not pull in framework-default tools');
    });

    it('names the selected scan tool explicitly when one was chosen', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'react', scanTool: 'sonarqube' }));
      expect(md).toContain('scan tool the user selected (**`sonarqube`**)');
    });

    it('forbids any scan tool when none is selected', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'react', scanTool: '' }));
      expect(md).toContain('do not add SonarQube, Wiz, or any other code-scan tooling');
    });

    it('omits the section for special app types like btp/infra/ami', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'btp', cloudProvider: 'aws' }));
      expect(md).not.toContain('## Tooling allowlist');
    });

    it('makes the rule binding for both Phase 2 and Phase 3', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'react' }));
      expect(md).toContain('**Phase 2 (`code/`)**');
      expect(md).toContain('**Phase 3 (`epic.json`)**');
    });
  });

  describe('PG&E defaults', () => {
    it('emits the PG&E defaults section with all five rules', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('## PG&E defaults');
      expect(md).toContain('Bootstrap a working project before writing any feature code');
      expect(md).toContain('Local-development redirect URIs');
      expect(md).toContain('CloudFront / public exposure');
      expect(md).toContain('`.infra/terraform.auto.tfvars` placeholders');
    });

    it('forbids version-mismatch firefighting and mandates a known-good baseline', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('canonical project initializer');
      expect(md).toContain('let it choose the dependency versions');
      expect(md).toContain('Verify the cold install before doing anything else');
      expect(md).toContain('Verify the dev server / runtime starts');
      expect(md).toContain('Verify the test runner runs');
      expect(md).toContain('Pin the runtime version up front');
      expect(md).toContain('Only then start writing feature code');
    });

    it('treats tooling-configuration diagnostics as errors across stacks', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('**Treat tooling-configuration diagnostics as errors, not warnings.**');
      expect(md).toContain('TS6504');
      expect(md).toContain('zero `tsc --noEmit` diagnostics');
      expect(md).toContain('--max-warnings=0');
      expect(md).toContain('terraform validate');
      expect(md).toContain('do not silence');
    });

    it('the Phase 2 gate explicitly requires zero config diagnostics', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('**Resolve every tooling-configuration diagnostic.**');
      expect(md).toContain('No editor tooltip on a config field is acceptable.');
      expect(md).toContain('Do not silence diagnostics with flags like `--legacy-peer-deps`');
    });

    it('locks the local web redirect URI to https://localhost:4200', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('Web / SPA app (`angular`, `react`, `html`) → `https://localhost:4200`');
    });

    it('forbids appending path suffixes to the redirect URI', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('**origin only, no path suffix**');
      expect(md).toContain('**Use the value above verbatim.**');
      expect(md).toContain('Do not append `/redirect`');
      expect(md).toContain('AADSTS50011');
      expect(md).toContain('byte-identical');
    });

    it('reinforces the byte-identical redirect rule inside the Phase 2 auth-validation gate', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('redirect URI in code');
      expect(md).toContain('must be byte-identical to the value registered with Entra');
      expect(md).toContain('if you see that error during validation, the wiring is wrong');
    });

    it('locks the local API redirect URI to http://localhost:5000', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('API / backend (`dotnet`, `python`, `java`, `php`) → `http://localhost:5000`');
    });

    it('defaults Node apps to the SPA redirect URI (https://localhost:4200)', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'node' }));
      expect(md).toContain('Node app (`node`) → `https://localhost:4200`');
      expect(md).toContain('the default local redirect URI is **https://localhost:4200**');
    });

    it('points the per-app default at the SPA URI for an angular app', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular' }));
      expect(md).toContain('the default local redirect URI is **https://localhost:4200**');
    });

    it('points the per-app default at the API URI for a dotnet app', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'dotnet' }));
      expect(md).toContain('the default local redirect URI is **http://localhost:5000**');
    });

    it('instructs the AI to scaffold trusted local TLS certs', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('### Local-development TLS / HTTPS');
      expect(md).toContain('mkcert');
      expect(md).toContain('dotnet dev-certs https --trust');
      expect(md).toContain('Not Secure');
      expect(md).toContain('Drop the generated `*.pem` files into a `code/.certs/` folder');
      expect(md).toContain('add `.certs/` to `.gitignore`');
    });

    it('forbids public CloudFront access by default', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('**Default access posture is PG&E-internal only.**');
      expect(md).toContain('unless the user explicitly asked for it');
    });

    it('requires TODO placeholders for unknown tfvars values', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('write a **TODO placeholder**');
      expect(md).toContain('aws_account_id = "TODO"');
      expect(md).toContain('Action required before deploy');
    });

    it('lists terraform.auto.tfvars in the .infra folder layout', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('terraform.auto.tfvars');
    });
  });

  it('renders database, queue, scheduler, and storage sections when toggled', () => {
    const md = renderEpicMd(
      baseAnswers({
        appType: 'node',
        needsDatabase: true,
        database: { engine: 'dynamodb', scale: 'single-instance' },
        needsQueue: true,
        queue: { kind: 'sqs' },
        needsScheduler: true,
        schedulerCron: 'cron(0 9 * * ? *)',
        needsStorage: true,
        storage: { kind: 's3' },
      }),
    );
    expect(md).toContain('### Database');
    expect(md).toContain('Engine: dynamodb');
    expect(md).toContain('### Messaging');
    expect(md).toContain('sqs');
    expect(md).toContain('### Scheduler');
    expect(md).toContain('cron(0 9 * * ? *)');
    expect(md).toContain('### Object storage');
    expect(md).toContain('s3');
  });

  it('renders AWS cloud target when provider=aws', () => {
    const md = renderEpicMd(
      baseAnswers({
        cloudProvider: 'aws',
        awsAccountId: '111122223333',
        awsRegion: 'us-east-1',
      }),
    );
    expect(md).toContain('Provider: AWS');
    expect(md).toContain('AWS account: 111122223333');
    expect(md).toContain('AWS region: us-east-1');
    expect(md).not.toContain('Azure subscription:');
  });

  it('renders Azure cloud target when provider=azure', () => {
    const md = renderEpicMd(
      baseAnswers({
        cloudProvider: 'azure',
        azureSubscriptionId: '00000000-0000-0000-0000-000000000000',
        azureResourceGroup: 'rg-test',
      }),
    );
    expect(md).toContain('Provider: AZURE');
    expect(md).toContain('Azure subscription: 00000000-0000-0000-0000-000000000000');
    expect(md).toContain('Azure resource group: rg-test');
    expect(md).not.toContain('AWS account:');
  });

  it('still surfaces AWS fields when appType=btp even if cloudProvider=btp', () => {
    const md = renderEpicMd(
      baseAnswers({
        appType: 'btp',
        cloudProvider: 'btp',
        awsAccountId: '999988887777',
        awsRegion: 'us-west-2',
      }),
    );
    expect(md).toContain('AWS account: 999988887777');
    expect(md).toContain('AWS region: us-west-2');
  });

  it('omits the open items section when extraNotes is empty', () => {
    const md = renderEpicMd(baseAnswers({ extraNotes: '' }));
    expect(md).not.toContain('## Open items / extra notes');
  });

  it('renders the open items section when extraNotes is provided', () => {
    const md = renderEpicMd(baseAnswers({ extraNotes: 'Use GraphQL not REST.' }));
    expect(md).toContain('## Open items / extra notes');
    expect(md).toContain('Use GraphQL not REST.');
  });

  it('always names the file epic.md (download-side concern, but heading uses it)', () => {
    const md = renderEpicMd(baseAnswers({ appName: 'whatever' }));
    expect(md.startsWith('# epic.md — whatever')).toBe(true);
  });

  it('emits the AWS module catalog when infra is included and cloud is aws', () => {
    const md = renderEpicMd(baseAnswers({ cloudProvider: 'aws', includeInfra: true }));
    expect(md).toContain('## EPIC pipeline modules — use these for `.infra/`');
    expect(md).toContain('`epic-pipeline-module-aws-lambda`');
    expect(md).toContain('`epic-pipeline-module-aws-s3`');
    expect(md).toContain('`epic-pipeline-module-aws-tags`');
    expect(md).not.toContain('epic-pipeline-module-azure');
  });

  it('emits the Azure module catalog when cloud is azure', () => {
    const md = renderEpicMd(
      baseAnswers({
        cloudProvider: 'azure',
        azureSubscriptionId: '00000000-0000-0000-0000-000000000000',
        includeInfra: true,
      }),
    );
    expect(md).toContain('`epic-pipeline-module-azure-app-service`');
    expect(md).toContain('`epic-pipeline-module-azure-key-vault`');
    // No AWS modules in the Azure catalog table — but the doc-wide format example references
    // epic-pipeline-module-aws-tags by design. Use a row-level anchor to assert the table itself.
    expect(md).not.toContain('| `epic-pipeline-module-aws-');
  });

  it('emits the AWS catalog for btp apps (BTP infra still uses AWS modules)', () => {
    const md = renderEpicMd(
      baseAnswers({ appType: 'btp', cloudProvider: 'aws', includeInfra: true }),
    );
    expect(md).toContain('`epic-pipeline-module-aws-secretmanager`');
  });

  it('omits the module catalog entirely when infra is not included', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: false }));
    expect(md).not.toContain('## EPIC pipeline modules');
    expect(md).not.toContain('epic-pipeline-module-aws-lambda');
  });

  it('declares the module catalog authoritative and forbids substitutes', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('This list is authoritative.');
    expect(md).toContain('Do not hand-roll resources');
    expect(md).toContain('do not invent module names');
    expect(md).toContain('do not substitute equivalents from the public Terraform registry');
  });

  it('tells the AI to read variables.tf/outputs.tf for the call signature', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain("`variables.tf` and `outputs.tf`");
  });

  it('tells the AI to source modules via Git, not local paths', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('git::https://github.com/pgetech/');
    expect(md).toContain('Do not** use a local `source = "../..."`');
  });

  it('does not reference any sibling-repo path on the developer machine', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).not.toContain('epic-pipeline/');
    expect(md).not.toContain('epic-pipeline-modules/');
    expect(md).not.toContain('epic-orchestrator');
    expect(md).not.toContain('epic-engine');
  });

  it('instructs the AI to request a new module when a needed resource has no module', () => {
    const md = renderEpicMd(baseAnswers({ includeInfra: true }));
    expect(md).toContain('request a new EPIC pipeline module');
    expect(md).toContain('Do **not** silently hand-roll the resource');
    expect(md).toContain('Awaiting modules');
  });

  describe('epic.json contract', () => {
    it('emits the canonical contract heading', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('## EPIC pipeline contract — `.pipeline/epic.json`');
    });

    it('embeds a JSON skeleton with the actual appName and appType', () => {
      const md = renderEpicMd(baseAnswers({ appName: 'fancy-thing', appType: 'react' }));
      expect(md).toContain('"appName": "fancy-thing"');
      expect(md).toContain('"appType": "react"');
    });

    it('forces codePath to code/ and infraPath to .infra in the skeleton', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('"codePath": "code/"');
      expect(md).toContain('"infraPath": ".infra"');
    });

    it('puts AWS fields in the cloud section for aws apps', () => {
      const md = renderEpicMd(
        baseAnswers({ cloudProvider: 'aws', awsAccountId: '111122223333', awsRegion: 'us-east-1' }),
      );
      expect(md).toContain('"awsAccountId": "111122223333"');
      expect(md).toContain('"awsRegion": "us-east-1"');
      // The skeleton block must not contain an Azure subscription field.
      expect(md).not.toContain('"azureSubscriptionId"');
    });

    it('puts Azure fields in the cloud section for azure apps', () => {
      const md = renderEpicMd(
        baseAnswers({
          cloudProvider: 'azure',
          azureSubscriptionId: '00000000-0000-0000-0000-000000000000',
        }),
      );
      expect(md).toContain('"azureSubscriptionId": "00000000-0000-0000-0000-000000000000"');
      expect(md).not.toContain('"awsAccountId"');
    });

    it('emits secretsManager block with BTP keys for btp apps', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'btp', cloudProvider: 'aws' }));
      expect(md).toContain('"secretsManager"');
      expect(md).toContain('"BTP_USERNAME"');
      expect(md).toContain('"BTP_PASSWORD"');
      expect(md).toContain('"CF_USER"');
    });

    it('warns the AI not to invent fields outside the contract', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('do not invent fields');
      expect(md).toContain('Do not add custom fields');
    });
  });

  describe('precedence over the AI-DLC steering', () => {
    it('declares the three-tier precedence (steering section > rest of this file > AI-DLC steering) in prerequisites', () => {
      const md = renderEpicMd(baseAnswers());
      expect(md).toContain('**The EPIC infrastructure steering section of this file** wins on *how* to invoke EPIC modules');
      expect(md).toContain('**The earlier sections of this file**');
      expect(md).toContain('**The AI-DLC steering** governs naming, security, review, and code-style conventions.');
      expect(md).toContain('Nothing in the AI-DLC steering may override an EPIC contract');
    });

    it('reinforces the override directly inside the .infra contract section', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('This document overrides the AI-DLC steering');
    });
  });

  describe('.infra contract', () => {
    it('omits the infra contract section when infra is not included', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: false }));
      expect(md).not.toContain('## EPIC pipeline contract — `.infra/`');
    });

    it('emits the AWS backend block and required vars for aws apps', () => {
      const md = renderEpicMd(baseAnswers({ cloudProvider: 'aws', includeInfra: true }));
      expect(md).toContain('backend "s3" {}');
      expect(md).toContain('variable "aws_account_id"');
      expect(md).toContain('variable "aws_region"');
      expect(md).toContain('variable "environment"');
      expect(md).not.toContain('backend "azurerm"');
    });

    it('emits the Azure backend block and required vars for azure apps', () => {
      const md = renderEpicMd(
        baseAnswers({
          cloudProvider: 'azure',
          azureSubscriptionId: '00000000-0000-0000-0000-000000000000',
          includeInfra: true,
        }),
      );
      expect(md).toContain('backend "azurerm" {}');
      expect(md).toContain('variable "subscription_id"');
      expect(md).toContain('variable "tenant_id"');
      expect(md).toContain('variable "azure_region"');
      expect(md).not.toContain('backend "s3"');
    });

    it('uses the AWS backend for btp apps (state still lives in S3 per epic-pipeline)', () => {
      const md = renderEpicMd(
        baseAnswers({ appType: 'btp', cloudProvider: 'aws', includeInfra: true }),
      );
      expect(md).toContain('backend "s3" {}');
      expect(md).toContain('variable "aws_account_id"');
    });

    it('forbids assume_role and hardcoded backend values', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('do **not** add `assume_role` blocks');
      expect(md).toContain('Leave the block empty');
    });
  });

  describe('research-first / follow-the-sample rules', () => {
    it('emits a Research first section with stack-specific authoritative references', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'angular' }));
      expect(md).toContain('## Research first — read the authoritative docs before writing code');
      expect(md).toContain('**DO NOT GUESS!**');
      expect(md).toContain('References for this app (`appType: angular`)');
      expect(md).toContain('https://angular.dev');
    });

    it('emits the Follow the sample rule for every appType', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'dotnet' }));
      expect(md).toContain('### Follow the sample — do not invent glue (applies to every appType and every library)');
      expect(md).toContain('not just auth and not just Angular');
    });

    it('lists concrete failure modes that the rule prevents', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'react' }));
      expect(md).toContain('Race conditions');
      expect(md).toContain('Wrong DI lifetime');
      expect(md).toContain('Custom guards / middlewares / interceptors');
      expect(md).toContain('Wrong lifecycle method');
    });

    it('emits the MSAL+Angular worked example only when appType=angular AND msal is selected', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'angular',
          hasFrontend: true,
          frontend: { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('### Worked example — MSAL + Angular wiring');
      expect(md).toContain('await msal.initialize()');
      expect(md).toContain('useValue: getMsalInstance()');
      expect(md).toContain('library\'s `MsalGuard`');
    });

    it('omits the MSAL+Angular worked example for non-Angular apps with MSAL', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'react',
          hasFrontend: true,
          frontend: { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).not.toContain('### Worked example — MSAL + Angular wiring');
    });

    it('omits the MSAL+Angular worked example for Angular apps without MSAL', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'angular',
          hasFrontend: true,
          frontend: { authMode: 'none', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).not.toContain('### Worked example — MSAL + Angular wiring');
    });

    it('emits MSAL auth references when MSAL+Angular is selected', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'angular',
          hasFrontend: true,
          frontend: { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false },
        }),
      );
      expect(md).toContain('MSAL for Angular — official sample');
      expect(md).toContain('Microsoft Entra ID app registration docs');
    });

    it('emits backend JWT references when authStyle is jwt-validator', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'node',
          hasBackend: true,
          backend: { style: 'rest-api', runtime: '', authStyle: 'jwt-validator', authClientId: '' },
        }),
      );
      expect(md).toContain('Microsoft identity platform — protected web API');
    });
  });

  it('emits a stable trailing newline', () => {
    const md = renderEpicMd(baseAnswers());
    expect(md.endsWith('\n')).toBe(true);
    expect(md.endsWith('\n\n')).toBe(false);
  });

  describe('deploy target (when .infra/ is absent)', () => {
    it('does not render the Deploy target subsection when .infra/ is generated', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).not.toContain('### Deploy target');
    });

    it('does not emit deploy-target keys in epic.json when .infra/ is generated', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      // JSON.stringify with 2-space indent produces `"key": value` (key + colon + space); the
      // bare-`"s3"` substring also appears in the Terraform backend block (`backend "s3" {}`),
      // so anchor on the `"key":` shape instead.
      expect(md).not.toContain('"s3":');
      expect(md).not.toContain('"cloudfront":');
      expect(md).not.toContain('"appUrl":');
    });

    it('renders the Deploy target subsection for SPA AWS apps when .infra/ is absent', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'html', includeInfra: false }));
      expect(md).toContain('### Deploy target — where this app will land');
      expect(md).toContain('`cloud.s3`');
      expect(md).toContain('`cloud.cloudfront`');
      expect(md).toContain('`cloud.appUrl`');
    });

    it('emits flat cloud.* deploy-target keys with TODO placeholders for blank user inputs', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'html',
          includeInfra: false,
          deployTarget: {
            s3: 'my-existing-bucket',
            cloudfront: '',
            ec2InstanceId: '',
            appExecutable: '',
            appServiceName: '',
            resourceGroupName: '',
            configDocPrefix: '',
            testDocPrefix: '',
            imageRecipeName: '',
            appUrl: '',
          },
        }),
      );
      expect(md).toContain('"s3": "my-existing-bucket"');
      expect(md).toContain('"cloudfront": "TODO"');
      expect(md).toContain('"appUrl": "TODO"');
    });

    it('emits the AWS server-runtime deploy-target keys (ec2InstanceId / appExecutable / appUrl) for backend apps on AWS', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'node',
          includeInfra: false,
          hasBackend: true,
          backend: { style: 'rest-api', runtime: '', authStyle: 'none', authClientId: '' },
        }),
      );
      expect(md).toContain('`cloud.ec2InstanceId`');
      expect(md).toContain('`cloud.appExecutable`');
      expect(md).not.toContain('`cloud.s3`');
    });

    it('emits the Azure deploy-target keys (appServiceName / resourceGroupName / appUrl) for apps on Azure', () => {
      const md = renderEpicMd(
        baseAnswers({
          appType: 'dotnet',
          cloudProvider: 'azure',
          azureSubscriptionId: '00000000-0000-0000-0000-000000000000',
          includeInfra: false,
          hasBackend: true,
          backend: { style: 'rest-api', runtime: '', authStyle: 'none', authClientId: '' },
        }),
      );
      expect(md).toContain('`cloud.appServiceName`');
      expect(md).toContain('`cloud.resourceGroupName`');
      expect(md).not.toContain('`cloud.ec2InstanceId`');
    });

    it('emits the AMI-specific deploy-target keys for ami appType', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'ami', includeInfra: false }));
      expect(md).toContain('`cloud.configDocPrefix`');
      expect(md).toContain('`cloud.testDocPrefix`');
      expect(md).toContain('`cloud.imageRecipeName`');
    });

    it('omits region from Cloud target when includeInfra is false (no .infra/ generated)', () => {
      const md = renderEpicMd(baseAnswers({ appType: 'html', includeInfra: false }));
      expect(md).not.toMatch(/^- AWS region:/m);
    });

    it('tells the AI that .infra-using apps read the deploy target from Terraform outputs, not cloud.*', () => {
      const md = renderEpicMd(baseAnswers({ includeInfra: true }));
      expect(md).toContain('reads the deploy target from Terraform outputs');
    });
  });
});
