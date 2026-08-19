import { Component, HostListener, OnInit, OnDestroy, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { InteractionStatus } from '@azure/msal-browser';
import { filter, takeUntil } from 'rxjs/operators';
import { Subject } from 'rxjs';

import { AppDetail, AppLookup, ComplianceFinding, ComplianceReport, ComplianceSummary, GitHubSourceOption, ManagedApp, PipelineRun, RunStatus, StageDetail, StageStep } from './models/app.model';
import { AppService } from './services/app.service';
import {
  APP_NAME_PATTERN,
  APP_NAME_RULE,
  APP_TYPE_LABELS,
  AWS_ACCOUNT_ID_PATTERN,
  AZURE_SUBSCRIPTION_ID_PATTERN,
  AppType,
  BUILD_TEST_TOOL_OPTIONS,
  CloudProvider,
  DeployTarget,
  INTEGRATION_TEST_TOOL_OPTIONS,
  NO_ARCHITECTURE_APP_TYPES,
  QueueKind,
  SCAN_TOOL_OPTIONS,
  StorageKind,
  WizardAnswers,
  appTypesForCloud,
  defaultBuildTestTool,
  defaultScanTool,
  emptyAnswers,
  emptyDeployTarget,
  normalizeAppName,
  normalizeAwsAccountId,
  normalizeAzureSubscriptionId,
  relevantDeployTargetKeys,
} from './wizard/wizard.model';
import { renderEpicMd } from './wizard/wizard.template';

/** Step index for the 3-step config builder modal. */
type BuilderStep = 1 | 2 | 3;
/** Step index for the 5-step create-app wizard. */
type WizardStep = 1 | 2 | 3 | 4 | 5;

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, LowerCasePipe, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit, OnDestroy {
  private readonly appService = inject(AppService);
  private readonly msalService = inject(MsalService);
  private readonly msalBroadcastService = inject(MsalBroadcastService);
  private readonly destroying$ = new Subject<void>();

  protected readonly title = signal('epic-web');
  protected readonly currentUser = signal('');
  protected readonly currentUserPhoto = signal<string | null>(null);
  protected readonly authState = signal<'authenticating' | 'authenticated' | 'denied'>('authenticating');

  // ── Data ──────────────────────────────────────────────────────────────────

  protected readonly apps = signal<ManagedApp[]>([]);
  protected readonly loading = signal(false);
  protected readonly dataLoading = signal(true);
  // Backend availability — probed once at startup. When offline we show a message in the
  // table area and make no further API calls until the user refreshes the page (which
  // re-runs ngOnInit and re-checks). null = check not yet completed.
  protected readonly backendOnline = signal<boolean | null>(null);

  // Track apps with locally-set pending state until ADO picks up the new run
  private readonly pendingApps = new Map<string, ManagedApp>();

  // Track cancelled run IDs until ADO confirms the cancellation
  private readonly cancelledRuns = new Set<number>();

  // Track pending runs until API returns them (keyed by runId, value includes app name for filtering)
  private readonly pendingRuns = new Map<number, { run: PipelineRun; appName: string }>();

  private readonly refreshInterval = 5000;
  private refreshTimer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    this.msalService.handleRedirectObservable().subscribe({
      error: () => this.authState.set('denied'),
    });

    this.msalBroadcastService.inProgress$
      .pipe(
        filter((status) => status === InteractionStatus.None),
        takeUntil(this.destroying$),
      )
      .subscribe(() => {
        const account =
          this.msalService.instance.getActiveAccount() ??
          this.msalService.instance.getAllAccounts()[0];

        if (!account) {
          this.msalService.loginRedirect({ scopes: [], domainHint: 'pge.com' });
          return;
        }

        this.msalService.instance.setActiveAccount(account);
        this.currentUser.set(account.name ?? 'Unknown');
        this.authState.set('authenticated');
        this.loadUserPhoto();

        if (!this.refreshTimer && this.backendOnline() !== true) {
          // Probe the API before loading anything. If it's down, surface the offline
          // message and make no further calls until a page refresh re-checks.
          this.appService.checkHealth().subscribe((online) => {
            this.backendOnline.set(online);
            if (!online) {
              this.dataLoading.set(false);
              return;
            }
            this.appService.getApps().subscribe({
              next: (data) => {
                this.apps.set(data);
                this.dataLoading.set(false);
              },
              error: () => this.dataLoading.set(false),
            });
            this.startAutoRefresh();
          });
        }
      });
  }

  ngOnDestroy(): void {
    this.destroying$.next();
    this.destroying$.complete();
    this.stopAutoRefresh();
    if (this.toastTimer) clearTimeout(this.toastTimer);
  }

  @HostListener('document:keydown.escape')
  protected onEscapeKey(): void {
    if (this.showReportModal()) this.closeReportModal();
    else if (this.showBuilderModal()) this.closeBuilder();
    else if (this.showHowToModal()) this.closeHowTo();
    else if (this.showNewRunModal()) this.closeNewRunModal();
    else if (this.showAddModal()) this.closeAddModal();
    else if (this.showManageModal()) this.closeManageModal();
    else if (this.showCreateAppWizard()) this.closeCreateAppWizard();
  }

  /** Overlay a cancelling-run marker on an app while ADO catches up. */
  private applyCancelOverride(app: ManagedApp): ManagedApp {
    if (app.runId && this.cancelledRuns.has(app.runId)) {
      if (app.runStatus === 'Canceled') {
        this.cancelledRuns.delete(app.runId);
        return app;
      }
      return { ...app, runStatus: 'Canceling' as const };
    }
    return app;
  }

  /** Keep the optimistic pending overlay until the API reports a newer run. */
  private applyPendingOverride(app: ManagedApp): ManagedApp {
    const pending = this.pendingApps.get(app.name);
    if (!pending) return app;
    // ADO has caught up if the API's last run is newer than when we triggered
    if (app.lastPipelineRun && new Date(app.lastPipelineRun) > new Date(pending.lastPipelineRun!)) {
      this.pendingApps.delete(app.name);
      return app;
    }
    // Still stale — keep our pending overlay
    return { ...app, runStatus: 'Pending' as const, branch: pending.branch, environment: pending.environment, triggeredBy: pending.triggeredBy, lastPipelineRun: pending.lastPipelineRun };
  }

  /** Merge freshly fetched apps with local optimistic (pending/cancelling) state. */
  private reconcileApps(data: ManagedApp[]): void {
    const withPending =
      this.pendingApps.size === 0 ? data : data.map(app => this.applyPendingOverride(app));
    this.apps.set(withPending.map(app => this.applyCancelOverride(app)));
  }

  private startAutoRefresh(): void {
    this.refreshTimer = setInterval(() => {
      // Refresh main table — preserve pending state until ADO catches up
      this.appService.getApps().subscribe({
        next: data => this.reconcileApps(data),
        error: () => { /* API unavailable — keep showing last known data */ }
      });

      // Refresh modal detail + current runs page if open
      if (this.showManageModal() && this.selectedApp()) {
        const name = this.selectedApp()!.name;
        this.appService.getApp(name).subscribe({
          next: detail => this.appDetail.set(detail),
          error: () => { /* API unavailable — keep showing last known data */ }
        });
        this.appService.getRuns(name, this.runsCurrentPage(), this.runsPageSize).subscribe({
          next: result => {
            this.runsTotal.set(result.total);
            const runs = result.runs.map(r => {
              // Reconcile the optimistic pending row against the real run. triggerRun
              // returns the ORCHESTRATOR build id, which is what pendingRuns is keyed
              // by; the real run arrives as the ENGINE build (r.id) that references its
              // orchestrator via r.orchestratorId. Clearing on both ids means the
              // pending row drops whether ADO is still in prepare (API emits the
              // orchestrator as r.id) or the engine has started (r.orchestratorId
              // carries the link) — so it can't linger once the run is known.
              this.pendingRuns.delete(r.id);
              if (r.orchestratorId != null) this.pendingRuns.delete(r.orchestratorId);
              if (this.cancelledRuns.has(r.id)) {
                if (r.status === 'Canceled') {
                  this.cancelledRuns.delete(r.id);
                  return r;
                }
                return { ...r, status: 'Canceling' as const };
              }
              return r;
            });
            const stillPending = [...this.pendingRuns.values()]
              .filter(p => p.appName === name)
              .map(p => p.run);
            this.pagedRuns.set([...stillPending, ...runs]);
          },
          error: () => { /* API unavailable — keep showing last known data */ }
        });

        // Refresh expanded stage detail and step log so they stay in sync
        const expanded = this.expandedStage();
        if (expanded && !this.stageDetailLoading()) {
          this.appService.getStageDetail(name, expanded.runId, expanded.stageName).subscribe({
            next: detail => this.stageDetail.set(detail),
            error: () => { /* keep showing last known data */ }
          });

          const logId = this.expandedLogId();
          if (logId && !this.stepLogLoading()) {
            this.appService.getStepLog(name, expanded.runId, logId).subscribe({
              next: result => this.stepLog.set(result.log),
              error: () => { /* keep showing last known data */ }
            });
          }
        }
      }
    }, this.refreshInterval);
  }

  private stopAutoRefresh(): void {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = null;
    }
  }

  // ── Search & filters ──────────────────────────────────────────────────────

  protected searchQuery = signal('');
  protected filterTechnology = signal('');
  protected filterCloud = signal('');
  protected filterEnvironment = signal('');
  protected filterRunStatus = signal('');
  protected filterTriggeredBy = signal('');

  protected readonly filteredApps = computed(() => {
    const query = this.searchQuery().toLowerCase();
    const tech = this.filterTechnology();
    const cloud = this.filterCloud();
    const env = this.filterEnvironment();
    const status = this.filterRunStatus();
    const triggeredBy = this.filterTriggeredBy();

    return this.apps().filter(app =>
      (!query || app.name.toLowerCase().includes(query) || (app.appName?.toLowerCase().includes(query) ?? false)) &&
      (!tech || app.technology === tech) &&
      (!cloud || app.cloud === cloud) &&
      (!env || app.environment === env) &&
      (!status || app.runStatus === status) &&
      (!triggeredBy || this.triggeredByLabel(app.triggeredBy) === triggeredBy)
    ).sort((a, b) => a.name.localeCompare(b.name));
  });

  // ── Filter options ────────────────────────────────────────────────────────

  protected readonly techOptions = computed(() =>
    [...new Set(this.apps().map(a => a.technology))].sort((a, b) => a.localeCompare(b))
  );
  protected readonly cloudOptions = computed(() =>
    [...new Set(this.apps().map(a => a.cloud))].sort((a, b) => a.localeCompare(b))
  );
  protected readonly envOptions = computed(() =>
    [...new Set(this.apps().map(a => a.environment))].sort((a, b) => a.localeCompare(b))
  );
  protected readonly statusOptions = computed(() =>
    [...new Set(this.apps().map(a => a.runStatus))].sort((a, b) =>
      (a ?? '').localeCompare(b ?? '')
    )
  );
  protected readonly triggeredByOptions = computed(() =>
    [...new Set(this.apps().map(a => this.triggeredByLabel(a.triggeredBy)))].sort((a, b) =>
      a.localeCompare(b)
    )
  );

  protected get hasActiveFilters(): boolean {
    return !!(
      this.searchQuery() ||
      this.filterTechnology() ||
      this.filterCloud() ||
      this.filterEnvironment() ||
      this.filterRunStatus() ||
      this.filterTriggeredBy()
    );
  }

  protected clearFilters(): void {
    this.searchQuery.set('');
    this.filterTechnology.set('');
    this.filterCloud.set('');
    this.filterEnvironment.set('');
    this.filterRunStatus.set('');
    this.filterTriggeredBy.set('');
    this.currentPage.set(1);
  }

  protected onFilterChange(): void {
    this.currentPage.set(1);
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  protected readonly pageSize = 25;
  protected currentPage = signal(1);

  protected readonly totalPages = computed(() =>
    Math.max(1, Math.ceil(this.filteredApps().length / this.pageSize))
  );

  protected readonly pagedApps = computed(() => {
    const page = this.currentPage();
    const start = (page - 1) * this.pageSize;
    return this.filteredApps().slice(start, start + this.pageSize);
  });

  protected readonly pageNumbers = computed(() =>
    Array.from({ length: this.totalPages() }, (_, i) => i + 1)
  );

  protected readonly pageRangeEnd = computed(() =>
    Math.min(this.currentPage() * this.pageSize, this.filteredApps().length)
  );

  protected goToPage(page: number): void {
    this.currentPage.set(page);
  }

  // ── Formatting ──────────────────────────────────────────────────────────

  protected formatDate(iso: string | null): string {
    if (!iso) return '—';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return iso;
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${pad(d.getMonth() + 1)}/${pad(d.getDate())}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
  }

  // ── User ──────────────────────────────────────────────────────────────────

  // Runs triggered before the triggeredBy parameter existed (or triggered directly
  // in ADO) carry no user — surface them as "System" rather than a blank chip.
  protected triggeredByLabel(name: string | null): string {
    return name?.trim() ? name : 'System';
  }

  protected initialsFor(name: string | null): string {
    if (!name) return '—';
    if (name === 'System') return '⚙';

    // Normalize: strip commas, split into parts, filter empties
    const parts = name.replaceAll(',', '').split(/\s+/).filter(Boolean);
    if (parts.length === 0) return '?';

    // Detect "Last, First [Middle]" format (original had a comma)
    if (name.includes(',') && parts.length >= 2) {
      const first = parts[1]; // first name is after the comma
      const last = parts[0];  // last name is before the comma
      return (first[0] + last[0]).toUpperCase();
    }

    // "First Last" or "First Middle Last" — use first and last
    const first = parts[0];
    const last = parts.at(-1)!;
    return parts.length === 1
      ? first[0].toUpperCase()
      : (first[0] + last[0]).toUpperCase();
  }

  private loadUserPhoto(): void {
    if (this.currentUserPhoto()) return;
    this.msalService.acquireTokenSilent({ scopes: ['User.Read'] }).subscribe({
      next: (result: any) => {
        fetch('https://graph.microsoft.com/v1.0/me/photo/$value', {
          headers: { Authorization: `Bearer ${result.accessToken}` },
        })
          .then((res) => (res.ok ? res.blob() : Promise.reject(new Error('photo fetch failed'))))
          .then((blob) => this.currentUserPhoto.set(URL.createObjectURL(blob)))
          .catch(() => {});
      },
    });
  }

  // ── How To modal ─────────────────────────────────────────────────────────

  protected showHowToModal = signal(false);
  protected howToAppType = 'angular';

  protected readonly epicJsonSamples: Record<string, string> = {
    angular: `{
  "app": {
    "appName": "my-angular-app",
    "appType": "angular",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "sonarqube",
    "buildTestTool": "karma"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    react: `{
  "app": {
    "appName": "my-react-app",
    "appType": "react",
    "codePath": "/",
    "runtimeVersion": "20",
    "scanTool": "sonarqube",
    "buildTestTool": "vitest"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    dotnet: `{
  "app": {
    "appName": "my-dotnet-app",
    "appType": "dotnet",
    "codePath": "/src/myapp",
    "runtimeVersion": "10.x",
    "scanTool": "sonarqube",
    "buildTestTool": "xunit"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "appExecutable": "MyApp"
  }
}`,
    python: `{
  "app": {
    "appName": "my-python-app",
    "appType": "python",
    "codePath": "/",
    "runtimeVersion": "3.11",
    "scanTool": "sonarqube",
    "buildTestTool": "pytest"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "appExecutable": "my_app"
  }
}`,
    java: `{
  "app": {
    "appName": "my-java-app",
    "appType": "java",
    "codePath": "/",
    "runtimeVersion": "17",
    "scanTool": "sonarqube",
    "buildTestTool": "junit"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    go: `{
  "app": {
    "appName": "my-go-app",
    "appType": "go",
    "codePath": "/",
    "runtimeVersion": "1.23",
    "scanTool": "sonarqube",
    "buildTestTool": "gotestsum"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "appExecutable": "my-go-app"
  }
}`,
    html: `{
  "app": {
    "appName": "my-static-site",
    "appType": "html",
    "codePath": "/"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    php: `{
  "app": {
    "appName": "my-php-app",
    "appType": "php",
    "codePath": "/",
    "runtimeVersion": "8.3",
    "scanTool": "sonarqube",
    "buildTestTool": "phpunit"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    ami: `{
  "app": {
    "appName": "my-ami-project",
    "appType": "ami"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "components": ["server", "portal"],
    "imageBuilderPipelinePrefix": "ami-factory",
    "ssmParameterPrefix": "/ami_factory"
  }
}`,
    btp: `{
  "app": {
    "appName": "my-btp-environment",
    "appType": "btp",
    "infraPath": "/my-btp-infra",
    "configPath": "/my-btp-config/.pipeline"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "secretsManager": {
      "name": "my-secrets-manager-name",
      "keys": [
        "BTP_USERNAME",
        "BTP_PASSWORD",
        "CF_USER",
        "CF_PASSWORD"
      ]
    }
  }
}`,
    infra: `{
  "app": {
    "appName": "my-infra-project",
    "appType": "infra",
    "infraPath": "/.infra",
    "configPath": "/.pipeline"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    cap: `{
  "app": {
    "appName": "my-cap-app",
    "appType": "cap",
    "codePath": "/",
    "scanTool": "sonarqube"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2",
    "cfApi": "https://api.cf.us10.hana.ondemand.com",
    "cfOrg": "my-cf-org",
    "cfSpace": "my-cf-space",
    "cfOrigin": "my-idp-origin",
    "secretsManager": {
      "name": "my-secrets-manager-name",
      "keys": [
        "CF_USER",
        "CF_PASSWORD"
      ]
    }
  }
}`
  };

  protected get currentSample(): string {
    return this.epicJsonSamples[this.howToAppType] ?? this.epicJsonSamples['angular'];
  }

  protected openHowTo(): void {
    this.howToAppType = 'angular';
    this.showHowToModal.set(true);
  }

  protected closeHowTo(): void {
    this.showHowToModal.set(false);
  }


  // ── Modals ────────────────────────────────────────────────────────────────

  protected showAddModal = signal(false);
  protected showManageModal = signal(false);
  protected manageModalFullscreen = signal(false);
  protected selectedApp = signal<ManagedApp | null>(null);
  protected appDetail = signal<AppDetail | null>(null);

  // Server-side paged runs (one ADO page at a time)
  protected readonly runsPageSize = 20;
  protected runsCurrentPage = signal(1);
  protected runsTotal = signal(0);
  protected pagedRuns = signal<PipelineRun[]>([]);
  protected runsLoading = signal(false);

  // Stage detail expansion
  protected expandedStage = signal<{ runId: number; stageName: string } | null>(null);
  protected stageDetail = signal<StageDetail | null>(null);
  protected stageDetailLoading = signal(false);

  protected readonly stageSteps = computed<StageStep[]>(() => {
    const detail = this.stageDetail();
    if (!detail) return [];
    return detail.jobs.flatMap(j => j.steps);
  });

  // Step log expansion
  protected expandedLogId = signal<number | null>(null);
  protected stepLog = signal<string | null>(null);
  protected stepLogLoading = signal(false);

  protected readonly runsTotalPages = computed(() =>
    Math.max(1, Math.ceil(this.runsTotal() / this.runsPageSize))
  );

  protected readonly runsPageNumbers = computed(() =>
    Array.from({ length: this.runsTotalPages() }, (_, i) => i + 1)
  );

  protected readonly runsPageRangeEnd = computed(() =>
    Math.min(this.runsCurrentPage() * this.runsPageSize, this.runsTotal())
  );

  protected goToRunsPage(page: number): void {
    if (page < 1 || page > this.runsTotalPages()) return;
    this.runsCurrentPage.set(page);
    this.collapseStageDetail();
    this.loadRunsPage();
  }

  private loadRunsPage(): void {
    const app = this.selectedApp();
    if (!app) return;
    this.runsLoading.set(true);
    this.appService.getRuns(app.name, this.runsCurrentPage(), this.runsPageSize).subscribe({
      next: result => {
        this.runsLoading.set(false);
        this.runsTotal.set(result.total);
        this.pagedRuns.set(result.runs);
      },
      error: () => {
        this.runsLoading.set(false);
        this.showToast(`Failed to load pipeline runs for "${app.name}".`);
      }
    });
  }

  // The clickable pipeline-stage dots, in column order. `prepare` (a link) and
  // `download` (static) are rendered separately; these are the expandable stages.
  // Template renders one <button> per entry via @for to avoid 7 near-identical blocks.
  protected readonly clickableStages: { key: keyof PipelineRun['stages']; label: string }[] = [
    { key: 'review', label: 'Review' },
    { key: 'build', label: 'Build' },
    { key: 'test', label: 'Test' },
    { key: 'scan', label: 'Scan' },
    { key: 'infraDeploy', label: 'Infrastructure deploy' },
    { key: 'appDeploy', label: 'App deploy' },
    { key: 'integrationTest', label: 'Integration test' },
  ];

  // Status of a named stage on a run (typed accessor for the template @for).
  protected stageStatusOf(run: PipelineRun, key: keyof PipelineRun['stages']): RunStatus {
    return run.stages[key];
  }

  protected onStageClick(event: Event, run: PipelineRun, stageName: string): void {
    event.stopPropagation();

    const stageStatus = (run.stages as Record<string, RunStatus>)[stageName];
    if (stageStatus === 'Skipped' || stageStatus === 'Pending') return;

    const current = this.expandedStage();
    if (current?.runId === run.id && current?.stageName === stageName) {
      this.expandedStage.set(null);
      this.stageDetail.set(null);
      this.complianceSummary.set(null);
      this.scanResultUrl.set(null);
      this.collapseStepLog();
      return;
    }

    this.expandedStage.set({ runId: run.id, stageName });
    this.stageDetail.set(null);
    this.stageDetailLoading.set(true);
    this.collapseStepLog();

    const appName = this.selectedApp()?.name;
    if (!appName) return;

    // On the Review stage, also pull the compliance summary (version + verdict
    // counts) for inline display, but only once the report can exist.
    this.complianceSummary.set(null);
    if (stageName === 'review' && this.reviewReportAvailable(run.stages.review)) {
      this.loadComplianceSummary(appName, run.id);
    }

    // On the Scan stage, pull the SonarQube dashboard URL (parsed server-side
    // from the "Analyze code" log). Only present for a terminal SonarQube scan;
    // the button stays hidden otherwise.
    this.scanResultUrl.set(null);
    if (stageName === 'scan' && this.scanResultAvailable(run.stages.scan)) {
      this.loadScanResultUrl(appName, run.id);
    }

    this.appService.getStageDetail(appName, run.id, stageName).subscribe({
      next: detail => {
        this.stageDetailLoading.set(false);
        this.stageDetail.set(detail);
      },
      error: () => {
        this.stageDetailLoading.set(false);
        this.expandedStage.set(null);
        this.showToast('Failed to load stage detail.');
      }
    });
  }

  protected isStageExpanded(runId: number, stageName: string): boolean {
    const current = this.expandedStage();
    return current !== null && current.runId === runId && current.stageName === stageName;
  }

  protected onStepClick(event: Event, step: { logId: number | null }): void {
    event.stopPropagation();
    if (!step.logId) return;

    if (this.expandedLogId() === step.logId) {
      this.expandedLogId.set(null);
      this.stepLog.set(null);
      return;
    }

    this.expandedLogId.set(step.logId);
    this.stepLog.set(null);
    this.stepLogLoading.set(true);

    const appName = this.selectedApp()?.name;
    const runId = this.expandedStage()?.runId;
    if (!appName || !runId) return;

    this.appService.getStepLog(appName, runId, step.logId).subscribe({
      next: result => {
        this.stepLogLoading.set(false);
        this.stepLog.set(result.log);
      },
      error: () => {
        this.stepLogLoading.set(false);
        this.expandedLogId.set(null);
        this.showToast('Failed to load step log.');
      }
    });
  }

  protected copyLog(event: Event): void {
    event.stopPropagation();
    const log = this.stepLog();
    if (!log) return;
    navigator.clipboard.writeText(log).then(() => this.showToast('Log copied to clipboard.'));
  }

  protected complianceReportDownloading = signal(false);

  // Compliance summary (tool version + verdict counts) parsed from the Review
  // stage's compliance-report.json. Loaded when the Review stage is expanded;
  // null when unavailable (run predates the JSON output, or still running).
  protected complianceSummary = signal<ComplianceSummary | null>(null);
  protected complianceSummaryLoading = signal(false);

  // Verdicts in display order, so the summary table reads worst-first and
  // matches the report's own ordering.
  private readonly verdictOrder = ['FAIL', 'PARTIAL', 'PASS', 'MANUAL', 'N/A'];

  // Returns the verdict counts as ordered {verdict, count} rows for the table,
  // skipping verdicts with a zero count.
  protected complianceVerdictRows(): { verdict: string; count: number }[] {
    const summary = this.complianceSummary();
    if (!summary) return [];
    const by = summary.byVerdict ?? {};
    const known = this.verdictOrder.filter(v => by[v] !== undefined);
    // Include any verdicts the API returns that aren't in the known order.
    const extra = Object.keys(by).filter(v => !this.verdictOrder.includes(v));
    return [...known, ...extra].map(verdict => ({ verdict, count: by[verdict] }));
  }

  // Loads the compliance summary for an expanded Review stage. Silent on
  // failure — the summary table simply doesn't render (the Download Report
  // button and its own error handling remain).
  private loadComplianceSummary(appName: string, runId: number): void {
    this.complianceSummary.set(null);
    this.complianceSummaryLoading.set(true);
    this.appService.getComplianceSummary(appName, runId).subscribe({
      next: summary => {
        this.complianceSummaryLoading.set(false);
        this.complianceSummary.set(summary);
      },
      error: () => {
        this.complianceSummaryLoading.set(false);
        this.complianceSummary.set(null);
      },
    });
  }

  // The Review stage publishes its report on succeededOrFailed(), so the file
  // only exists once the stage reaches a terminal state. A Running/Pending stage
  // has no report yet, and a Canceled/Skipped run never produced one — so the
  // Download Report button must stay hidden outside these two statuses.
  protected reviewReportAvailable(status: RunStatus): boolean {
    return status === 'Success' || status === 'Failed';
  }

  // SonarQube dashboard URL for an expanded Scan stage, parsed server-side from
  // the "Analyze code" step log. Null when the scan wasn't SonarQube, hasn't
  // finished, or emitted no URL — the "View in SonarQube" button hides then.
  protected scanResultUrl = signal<string | null>(null);
  protected scanResultUrlLoading = signal(false);

  // SonarQubeAnalyze prints the dashboard URL only on a terminal scan, so only
  // attempt the lookup once the Scan stage has succeeded or failed.
  protected scanResultAvailable(status: RunStatus): boolean {
    return status === 'Success' || status === 'Failed';
  }

  // Loads the SonarQube dashboard URL for an expanded Scan stage. Silent on
  // failure / absence (non-SonarQube scan, Wiz, or no URL line) — the button
  // simply doesn't render.
  private loadScanResultUrl(appName: string, runId: number): void {
    this.scanResultUrl.set(null);
    this.scanResultUrlLoading.set(true);
    this.appService.getScanResultUrl(appName, runId).subscribe({
      next: result => {
        this.scanResultUrlLoading.set(false);
        this.scanResultUrl.set(result.url);
      },
      error: () => {
        this.scanResultUrlLoading.set(false);
        this.scanResultUrl.set(null);
      },
    });
  }

  // Opens the SonarQube dashboard for the expanded Scan stage in a new tab.
  protected openScanResult(event: Event): void {
    event.stopPropagation();
    const url = this.scanResultUrl();
    if (url) window.open(url, '_blank', 'noopener');
  }

  // Fetches the Markdown compliance report published by the Review stage and
  // triggers a client-side download. Only shown on the Review stage detail.
  protected downloadComplianceReport(event: Event): void {
    event.stopPropagation();
    const appName = this.selectedApp()?.name;
    const runId = this.expandedStage()?.runId;
    if (!appName || !runId) return;

    this.complianceReportDownloading.set(true);
    this.appService.getComplianceReport(appName, runId).subscribe({
      next: result => {
        this.complianceReportDownloading.set(false);
        const blob = new Blob([result.report], { type: 'text/markdown' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `compliance-report-${appName}-${runId}.md`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      },
      error: () => {
        this.complianceReportDownloading.set(false);
        this.showToast('No compliance report available for this run.');
      }
    });
  }

  // ── View compliance report modal ────────────────────────────────────────────

  protected showReportModal = signal(false);
  protected reportModalLoading = signal(false);
  protected reportModalReport = signal<ComplianceReport | null>(null);
  protected reportModalTitle = signal('');
  protected reportModalFullscreen = signal(false);

  protected toggleReportModalFullscreen(): void {
    this.reportModalFullscreen.update(v => !v);
  }

  // Fetches the structured JSON report and opens it, rendered natively, in a
  // modal. Rendering from JSON (not the .md) keeps the view in the app's design
  // system — grouped findings, verdict pills, profile — with no Markdown parsing.
  protected viewComplianceReport(event: Event): void {
    event.stopPropagation();
    const appName = this.selectedApp()?.name;
    const runId = this.expandedStage()?.runId;
    if (!appName || !runId) return;

    this.reportModalTitle.set(`Compliance Report — ${appName} #${runId}`);
    this.reportModalReport.set(null);
    this.reportModalLoading.set(true);
    this.showReportModal.set(true);

    this.appService.getComplianceReportJson(appName, runId).subscribe({
      next: report => {
        this.reportModalLoading.set(false);
        this.reportModalReport.set(report);
      },
      error: () => {
        this.reportModalLoading.set(false);
        this.showReportModal.set(false);
        this.showToast('No compliance report available for this run.');
      }
    });
  }

  protected closeReportModal(): void {
    this.showReportModal.set(false);
    this.reportModalReport.set(null);
    this.reportModalFullscreen.set(false);
  }

  // Findings grouped by verdict in display order (worst-first), for the modal.
  // Verdicts with no findings are omitted.
  protected reportFindingGroups(): { verdict: string; findings: ComplianceFinding[] }[] {
    const report = this.reportModalReport();
    if (!report) return [];
    return this.verdictOrder
      .map(verdict => ({
        verdict,
        findings: report.findings.filter(f => f.verdict === verdict),
      }))
      .filter(g => g.findings.length > 0);
  }

  private collapseStepLog(): void {
    this.expandedLogId.set(null);
    this.stepLog.set(null);
  }

  protected collapseStageDetail(): void {
    this.expandedStage.set(null);
    this.stageDetail.set(null);
    this.complianceSummary.set(null);
    this.scanResultUrl.set(null);
    this.collapseStepLog();
  }

  // New Run modal
  protected showNewRunModal = signal(false);
  protected newRunApp = signal<AppDetail | null>(null);
  protected newRunBranch = '';
  protected newRunEnvironment = '';
  protected newRunConfig = '';
  protected newRunBranchError = signal<string | null>(null);
  protected newRunEnvLocked = signal(false);
  protected newRunReview = true;
  protected newRunBuild = true;
  protected newRunTests = false;
  protected newRunScan = false;
  protected newRunDeploy = false;
  protected newRunIntegrations = false;
  protected newRunDeployInfra = 'none';
  // Default checked: when a committed tfstate is found, the user almost always
  // wants EPIC to take over managing it.
  protected newRunForceStateCopy = true;
  protected configSearchStatus = signal<'idle' | 'searching' | 'found' | 'not-found' | 'error'>('idle');
  protected availableConfigs = signal<string[]>([]);
  protected newRunHasInfra = signal(false);
  protected newRunHasInfraParams = signal(false);
  // Whether the app's Terraform declares the EPIC-managed remote backend for
  // its cloud (s3 for AWS/SAP, azurerm for Azure). When the user requests an
  // infra deploy without one, we confirm they don't want EPIC to manage their
  // state before triggering the run.
  protected newRunHasRemoteBackend = signal(false);
  // The Terraform backend EPIC expects for the selected config's cloud
  // ("s3" for AWS/SAP, "azurerm" for Azure). Names the backend in the UI hint.
  protected newRunExpectedBackend = signal('s3');
  // Whether a committed *.tfstate exists in the repo. If so we offer a
  // "Force State Copy" checkbox so EPIC migrates it into the remote backend.
  protected newRunHasTfState = signal(false);
  protected newRunConfigAppType = signal<string | null>(null);
  protected newRunBuildTestTool = signal<string | null>(null);
  protected newRunScanTool = signal<string | null>(null);
  protected newRunIntegrationTestTool = signal<string | null>(null);
  // Environment keys the selected config declares under cloud.environments. When
  // non-empty, the env dropdown is restricted to these so a user can't pick an
  // environment the config doesn't define (which the pipeline would reject).
  protected newRunConfiguredEnvironments = signal<string[]>([]);
  protected newRunValidating = signal(false);

  // The env <option>s to offer: the config's configured environments when it
  // declares a per-env map, else the full default set. Drives the dropdown.
  protected readonly allEnvironments = ['dev', 'test', 'qa', 'uat', 'stage', 'prod'];
  protected newRunEnvironmentOptions = computed(() => {
    const configured = this.newRunConfiguredEnvironments();
    return configured.length > 0 ? configured : this.allEnvironments;
  });
  private lastValidatedBranch = '';

  protected newAppRepo = '';
  protected repoCheckStatus = signal<'idle' | 'checking' | 'available' | 'in-epic-not-mine' | 'already-mine' | 'not-found'>('idle');
  protected foundMasterApp = signal<AppLookup | null>(null);

  // GitHub org/source the new app is pulled from. Populated from the API; the
  // dropdown is only shown when more than one source is configured.
  protected githubSources = signal<GitHubSourceOption[]>([]);
  protected selectedSource = signal<string>('');

  protected onAddApp(): void {
    this.newAppRepo = '';
    this.repoCheckStatus.set('idle');
    this.foundMasterApp.set(null);
    this.showAddModal.set(true);
    // Load the configured sources (once) and default the selection.
    if (this.githubSources().length === 0) {
      this.appService.getGitHubSources().subscribe({
        next: res => {
          this.githubSources.set(res.sources);
          this.selectedSource.set(res.defaultSource);
        },
        // Non-fatal: with no source list the selection stays '' and the API
        // falls back to its default source (single-org behavior).
        error: () => { /* leave sources empty; onboarding still works */ }
      });
    } else if (!this.selectedSource()) {
      this.selectedSource.set(this.githubSources().find(s => s.isDefault)?.name ?? this.githubSources()[0]?.name ?? '');
    }
  }

  protected closeAddModal(): void {
    this.showAddModal.set(false);
  }

  protected onRepoChange(): void {
    this.repoCheckStatus.set('idle');
    this.foundMasterApp.set(null);
  }

  // Changing the org invalidates any prior repo check (same name can differ per org).
  protected onSourceChange(): void {
    this.repoCheckStatus.set('idle');
    this.foundMasterApp.set(null);
  }

  protected onRepoBlur(): void {
    const repo = this.newAppRepo.trim();
    if (!repo) {
      this.repoCheckStatus.set('idle');
      return;
    }
    this.repoCheckStatus.set('checking');
    this.appService.checkRepo(repo, this.selectedSource() || undefined).subscribe({
      next: result => {
        this.repoCheckStatus.set(result.status);
        this.foundMasterApp.set(result.masterApp ?? null);
      },
      error: () => this.repoCheckStatus.set('not-found')
    });
  }

  protected get canOnboard(): boolean {
    return !!this.newAppRepo.trim() && this.repoCheckStatus() === 'available';
  }

  protected onOnboardApp(): void {
    if (!this.canOnboard) return;
    const repo = this.newAppRepo.trim();
    this.loading.set(true);
    this.appService.onboardApp(repo, this.selectedSource() || undefined).subscribe({
      next: app => {
        this.loading.set(false);
        this.apps.update(list => [app, ...list]);
        this.closeAddModal();
        this.showToast(`"${repo}" has been added to EPIC.`);
      },
      error: (err) => {
        this.loading.set(false);
        const msg = err?.error?.error ?? `Failed to onboard "${repo}" — please try again.`;
        this.showToast(msg);
      }
    });
  }

  protected onAddToMyList(): void {
    const masterApp = this.foundMasterApp();
    if (!masterApp) return;
    this.appService.addToMyApps(masterApp).subscribe({
      next: app => {
        this.apps.update(list => [app, ...list]);
        this.closeAddModal();
        this.showToast(`"${masterApp.name}" has been added to your list.`);
      },
      error: () => this.showToast(`Failed to add "${masterApp.name}" — please try again.`)
    });
  }

  protected onManageApp(app: ManagedApp): void {
    this.selectedApp.set(app);
    this.appDetail.set(null);
    this.runsCurrentPage.set(1);
    this.runsTotal.set(0);
    this.pagedRuns.set([]);
    this.runsLoading.set(true);
    this.showManageModal.set(true);
    this.appService.getApp(app.name).subscribe({
      next: detail => this.appDetail.set(detail),
      error: () => {
        this.showToast(`Failed to load details for "${app.name}".`);
        this.closeManageModal();
      }
    });
    this.loadRunsPage();
  }

  protected onNewRun(): void {
    const detail = this.appDetail();
    if (!detail) return;
    this.newRunApp.set(detail);
    this.newRunBranch = '';
    this.newRunEnvironment = 'dev';
    this.newRunConfig = '';
    this.newRunBranchError.set(null);
    this.newRunEnvLocked.set(false);
    this.configSearchStatus.set('idle');
    this.availableConfigs.set([]);
    this.newRunHasInfra.set(false);
    this.newRunHasInfraParams.set(false);
    this.newRunHasRemoteBackend.set(false);
    this.newRunHasTfState.set(false);
    this.newRunConfigAppType.set(null);
    this.newRunBuildTestTool.set(null);
    this.newRunScanTool.set(null);
    this.newRunIntegrationTestTool.set(null);
    this.newRunConfiguredEnvironments.set([]);
    this.newRunValidating.set(false);
    this.lastValidatedBranch = '';
    this.newRunReview = true;
    this.newRunBuild = true;
    this.newRunTests = false;
    this.newRunScan = false;
    this.newRunDeploy = false;
    this.newRunIntegrations = false;
    this.newRunDeployInfra = 'none';
    this.newRunForceStateCopy = true;
    this.showManageModal.set(false);
    this.showNewRunModal.set(true);
  }

  protected onNewRunBranchChange(): void {
    this.newRunBranchError.set(null);

    if (/^release\d*$/i.test(this.newRunBranch.trim())) {
      this.newRunEnvironment = 'prod';
      this.newRunEnvLocked.set(true);
    } else {
      this.newRunEnvLocked.set(false);
    }

    this.lastValidatedBranch = '';
    this.configSearchStatus.set('idle');
    this.availableConfigs.set([]);
    this.newRunConfig = '';
    this.newRunHasInfra.set(false);
    this.newRunHasInfraParams.set(false);
    this.newRunHasRemoteBackend.set(false);
    this.newRunHasTfState.set(false);
    this.newRunConfigAppType.set(null);
    this.newRunBuildTestTool.set(null);
    this.newRunScanTool.set(null);
    this.newRunIntegrationTestTool.set(null);
  }

  protected onNewRunBranchBlur(): void {
    const branch = this.newRunBranch.trim();
    const repo = this.newRunApp()?.github?.repo;
    const source = this.newRunApp()?.github?.source ?? undefined;
    if (!branch || !repo) {
      this.configSearchStatus.set('idle');
      return;
    }
    if (branch === this.lastValidatedBranch) return;
    this.lastValidatedBranch = branch;
    this.newRunValidating.set(true);
    this.configSearchStatus.set('searching');
    this.availableConfigs.set([]);
    this.newRunConfig = '';
    this.newRunHasInfra.set(false);
    this.newRunHasInfraParams.set(false);
    this.newRunHasRemoteBackend.set(false);
    this.newRunHasTfState.set(false);
    this.appService.getConfigs(repo, branch, source).subscribe({
      next: result => {
        if (result.configs.length === 0) {
          this.configSearchStatus.set('not-found');
          this.newRunValidating.set(false);
          // No epic.json → contract-less Review-only run. Force the toggles so a
          // stale/default selection (Build defaults on) isn't submitted; only
          // Review stays available and checked.
          this.newRunReview = true;
          this.newRunBuild = false;
          this.newRunTests = false;
          this.newRunScan = false;
          this.newRunDeploy = false;
          this.newRunIntegrations = false;
          this.newRunDeployInfra = 'none';
        } else {
          this.availableConfigs.set(result.configs);
          this.configSearchStatus.set('found');
          if (result.configs.length === 1) {
            this.newRunConfig = result.configs[0];
            // Single config auto-resolves its infra/tooling — same handling as an
            // explicit config pick (onConfigSelect → checkInfraForConfig).
            this.checkInfraForConfig(repo, branch, result.configs[0]);
          } else {
            this.newRunValidating.set(false);
          }
        }
      },
      error: () => {
        this.configSearchStatus.set('error');
        this.newRunValidating.set(false);
      }
    });
  }

  protected onConfigSelect(): void {
    const repo = this.newRunApp()?.github?.repo;
    const branch = this.newRunBranch.trim();
    if (!repo || !branch || !this.newRunConfig) return;
    this.newRunHasInfra.set(false);
    this.newRunHasInfraParams.set(false);
    this.newRunHasRemoteBackend.set(false);
    this.newRunHasTfState.set(false);
    this.newRunBuildTestTool.set(null);
    this.newRunScanTool.set(null);
    this.newRunIntegrationTestTool.set(null);
    this.newRunDeployInfra = 'none';
    // Mark validation in-flight so the "no infra found" hint (and other
    // result-derived messages) stay hidden until checkConfigInfra resolves,
    // instead of flashing the misleading default while the request is pending.
    this.newRunValidating.set(true);
    this.checkInfraForConfig(repo, branch, this.newRunConfig);
  }

  private checkInfraForConfig(repo: string, branch: string, config: string): void {
    const source = this.newRunApp()?.github?.source ?? undefined;
    this.appService.checkConfigInfra(repo, branch, config, source).subscribe({
      next: result => {
        this.newRunHasInfra.set(result.hasInfra);
        this.newRunHasInfraParams.set(result.hasInfraParams);
        this.newRunHasRemoteBackend.set(result.hasRemoteBackend);
        this.newRunExpectedBackend.set(result.expectedBackend ?? 's3');
        this.newRunHasTfState.set(result.hasTfState);
        this.newRunConfigAppType.set(result.appType);
        this.newRunBuildTestTool.set(result.buildTestTool);
        this.newRunScanTool.set(result.scanTool);
        this.newRunIntegrationTestTool.set(result.integrationTestTool);
        this.newRunConfiguredEnvironments.set(result.configuredEnvironments ?? []);
        // If the config declares a per-env map and the currently-selected env
        // isn't in it, snap to the first configured env so the dropdown never
        // shows an environment the config (and pipeline) would reject.
        const envs = result.configuredEnvironments ?? [];
        if (envs.length > 0 && !envs.includes(this.newRunEnvironment) && !this.newRunEnvLocked()) {
          this.newRunEnvironment = envs[0];
        }
        this.applyAppTypeDefaults(result.appType);
        // Default to Apply only when infra can ACTUALLY deploy — i.e. the infra
        // folder exists AND has an EPIC-manageable remote backend. Without a
        // usable backend the deploy radios are disabled, so defaulting to Apply
        // would strand deployInfra on a value the user can't change and block the
        // Run button even for a Review-only run. Leaving it at 'none' keeps the
        // run valid; the informational "no backend" hint still explains why infra
        // won't deploy. BTP keeps its "Plan ONLY" default from applyAppTypeDefaults.
        if (result.hasInfra && result.appType !== 'btp' && result.hasRemoteBackend) {
          this.newRunDeployInfra = 'apply';
        }
      },
      error: () => {
        this.newRunHasInfra.set(false);
        this.newRunHasInfraParams.set(false);
        this.newRunHasRemoteBackend.set(false);
        this.newRunHasTfState.set(false);
        this.newRunBuildTestTool.set(null);
        this.newRunScanTool.set(null);
        this.newRunIntegrationTestTool.set(null);
        this.newRunConfiguredEnvironments.set([]);
        this.newRunValidating.set(false);
      },
      complete: () => this.newRunValidating.set(false)
    });
  }

  private applyAppTypeDefaults(appType: string | null): void {
    if (appType === 'btp' || appType === 'infra') {
      // Infrastructure appTypes: default Review OFF (but still selectable — see
      // reviewDisabled). Many infra repos also carry app source (e.g. a Container
      // Apps backend whose codePath holds the Express app), and IA-05 secret
      // scanning is valuable on .tfvars/.tfstate too, so the compliance gate is
      // available on opt-in; it just isn't forced on the way it is for app types.
      this.newRunReview = false;
      this.newRunBuild = false;
      this.newRunDeploy = false;
      this.newRunIntegrations = false;
      this.newRunTests = false;
      this.newRunScan = false;
      // Default to Apply only when infra can actually deploy (has the
      // EPIC-managed remote backend for its cloud — s3 for AWS/SAP, azurerm for
      // Azure). Without one the deploy radios are disabled, so defaulting to
      // Apply would strand deployInfra on an unchangeable value and block the
      // Run button — even for a Review-only run. 'none' keeps the run valid.
      this.newRunDeployInfra = this.newRunHasRemoteBackend() ? 'apply' : 'none';
    }
    // BTP defaults: environment "other" and infrastructure "Plan ONLY" (plan),
    // unless a release branch has locked the environment to prod.
    if (appType === 'btp') {
      if (!this.newRunEnvLocked()) {
        this.newRunEnvironment = 'other';
      }
      this.newRunDeployInfra = 'plan';
    }
    // Uncheck any stage the resolved config can't actually run so a stale
    // selection (e.g. after switching configs) isn't submitted.
    if (this.reviewDisabled) this.newRunReview = false;
    if (this.buildTestsDisabled) this.newRunTests = false;
    if (this.scanDisabled) this.newRunScan = false;
    if (this.integrationTestsDisabled) this.newRunIntegrations = false;
    if (this.deployDisabled) this.newRunDeploy = false;
  }

  protected get infraDisabled(): boolean {
    return !this.newRunHasInfra();
  }

  // No epic.json in the repo/branch. The orchestrator still runs a Review-only
  // pipeline in this case (contract-less fallback), so we keep Review available
  // and lock every other stage — there's no contract to build/test/scan/deploy.
  protected get noConfig(): boolean {
    return this.configSearchStatus() === 'not-found';
  }

  // Review (PG&E compliance gate) is available for ANY appType once a config is
  // selected — or when the repo has NO config at all (contract-less Review-only
  // run). Infrastructure appTypes (btp/infra) are no longer excluded: their
  // codePath often contains app source, and IA-05 secret scanning covers
  // .tfvars/.tfstate. It defaults OFF for infra/btp (applyAppTypeDefaults) but
  // stays selectable. Only truly disabled when no config is resolved yet.
  protected get reviewDisabled(): boolean {
    return !this.newRunConfig && !this.noConfig;
  }

  // Environment is locked until an EPIC Config is resolved: either a single
  // epic.json was auto-selected, the user picked one from the multi-config list
  // (both set newRunConfig), or the repo is contract-less (noConfig → Review-only,
  // env still applies). Also stays disabled when a release branch forces prod.
  protected get newRunEnvDisabled(): boolean {
    return this.newRunEnvLocked() || (!this.newRunConfig && !this.noConfig);
  }

  // Build Tests / Scan / Integration Tests each require the corresponding tool
  // to be declared in epic.json's `app` section — without it the stage is a no-op.
  protected get buildTestsDisabled(): boolean {
    return !this.newRunConfig || !this.newRunBuildTestTool();
  }

  protected get scanDisabled(): boolean {
    // SonarQube analyzes .NET in MSBuild mode — analysis is a byproduct of the
    // compile, so a .NET scan cannot run without a build. Require Build to be
    // selected before Scan is available for dotnet apps.
    if (this.newRunConfigAppType() === 'dotnet' && !this.newRunBuild) return true;
    return !this.newRunConfig || !this.newRunScanTool();
  }

  protected get deployDisabled(): boolean {
    // CAP apps deploy to a pre-existing BTP/CF space, so they have no `.infra`
    // folder and must not be gated on it.
    if (this.newRunConfigAppType() === 'cap') {
      return !this.newRunConfig || !this.newRunBuild;
    }
    // App deploy needs somewhere to deploy to: either an infra folder to provision
    // or cloud deploy targets in epic.json. No `.infra` and no cloud params → nothing to deploy against.
    if (!this.newRunHasInfra() && !this.newRunHasInfraParams()) return true;
    return !this.newRunConfig || !this.newRunBuild || this.newRunConfigAppType() === 'btp' || this.newRunConfigAppType() === 'infra';
  }

  protected get integrationTestsDisabled(): boolean {
    if (!this.newRunIntegrationTestTool()) return true;
    if (this.newRunConfigAppType() === 'cap') {
      return !this.newRunConfig;
    }
    return !this.newRunConfig || this.infraDisabled;
  }

  protected onBuildToggle(checked: boolean): void {
    if (!checked) {
      this.newRunDeploy = false;
      // A .NET scan is compile-instrumented, so it can't run without a build.
      // Clear the selection when Build is unchecked (scanDisabled re-disables it).
      if (this.newRunConfigAppType() === 'dotnet') this.newRunScan = false;
    }
  }

  /**
   * Plan ONLY publishes no Terraform outputs, so a Deploy in the same run can't
   * use freshly-provisioned infra — it falls back to existing infra (epic.json),
   * exactly like the "None" path. Surface that so the pairing isn't mistaken for
   * "provision then deploy". Informational only — the combination is valid.
   */
  protected get planOnlyWithDeploy(): boolean {
    return this.newRunDeployInfra === 'plan' && this.newRunDeploy;
  }

  // At least one stage or an infra action must be selected — otherwise the run
  // is a no-op. Guards against submitting an empty run (nothing ticked + infra
  // "None"), which the pipeline would start and then skip every stage.
  protected get hasRunnableSelection(): boolean {
    return (
      this.newRunReview ||
      this.newRunBuild ||
      this.newRunTests ||
      this.newRunScan ||
      this.newRunDeploy ||
      this.newRunIntegrations ||
      this.newRunDeployInfra !== 'none'
    );
  }

  protected get canRunNewPipeline(): boolean {
    const branchOk = !!this.newRunBranch.trim() && !this.newRunBranchError() && !!this.newRunEnvironment;
    if (!branchOk) return false;
    // Contract-less Review-only run: no epic.json, but Review is selected.
    if (this.noConfig) return this.newRunReview;
    return (
      this.configSearchStatus() === 'found' &&
      !!this.newRunConfig.trim() &&
      // An infra deploy needs an EPIC-managed remote backend for the state.
      !this.infraDeployBlockedNoBackend &&
      // Don't allow an empty run — at least one stage or infra action selected.
      this.hasRunnableSelection
    );
  }

  /**
   * Infra folder exists but its Terraform has no EPIC-managed remote backend
   * for its cloud (s3 for AWS/SAP, azurerm for Azure), so EPIC can't manage the
   * state. Apply/Destroy are unavailable in this case.
   */
  protected get missingRemoteBackend(): boolean {
    return this.newRunHasInfra() && !this.newRunHasRemoteBackend();
  }

  /** Infra deploy was requested but the Terraform has no EPIC-managed remote backend. */
  protected get infraDeployBlockedNoBackend(): boolean {
    return this.newRunDeployInfra !== 'none' && this.missingRemoteBackend;
  }

  /**
   * Show the "Force State Copy" option only when a committed tfstate was found
   * AND the run can actually deploy infra (remote backend present, Apply/Destroy
   * selected) — otherwise there's no init to migrate state into.
   */
  protected get showForceStateCopy(): boolean {
    return this.newRunHasTfState() && this.newRunHasRemoteBackend() && this.newRunDeployInfra !== 'none';
  }

  protected closeNewRunModal(): void {
    this.showNewRunModal.set(false);
    this.newRunApp.set(null);
    this.showManageModal.set(true);
  }

  protected onConfirmNewRun(): void {
    if (!this.canRunNewPipeline) return;
    if (this.newRunDeployInfra === 'destroy' && !confirm('You selected "Destroy" for infrastructure deployment. This will permanently remove infrastructure resources. Are you sure you want to proceed?')) {
      return;
    }
    const appName = this.newRunApp()?.name;
    const branch = this.newRunBranch.trim();
    const env = this.newRunEnvironment;
    if (!appName) return;
    this.loading.set(true);
    this.appService.triggerRun(appName, {
      branch,
      environment: env,
      config: this.newRunConfig.trim() || '.pipeline/epic.json',
      review: this.newRunReview,
      build: this.newRunBuild,
      tests: this.newRunTests,
      scan: this.newRunScan,
      deploy: this.newRunDeploy,
      integrations: this.newRunIntegrations,
      deployInfra: this.newRunDeployInfra,
      // Only meaningful when the option is actually offered for this run.
      forceStateCopy: this.showForceStateCopy && this.newRunForceStateCopy
    }).subscribe({
      next: (result) => {
        this.loading.set(false);
        this.closeNewRunModal();
        // Record the trigger time so refresh can detect when ADO catches up
        const triggeredAt = new Date().toISOString();
        const currentApp = this.apps().find(a => a.name === appName);
        this.pendingApps.set(appName, {
          ...(currentApp ?? { name: appName, appName: null, githubOrg: null, technology: '', cloud: '', environment: env, runId: null, successRate: null, avgDuration: null }),
          lastPipelineRun: triggeredAt,
          branch,
          environment: env,
          triggeredBy: this.currentUser(),
          runStatus: 'Pending'
        });
        // Update the app row immediately with pending state
        this.apps.update(list => list.map(a =>
          a.name === appName
            ? { ...a, runStatus: 'Pending' as const, branch, environment: env, triggeredBy: this.currentUser(), lastPipelineRun: triggeredAt }
            : a
        ));
        // Add pending run to the runs table in the app pipeline modal
        const pendingRun: PipelineRun = {
          id: result.runId,
          orchestratorId: null,
          status: 'Pending',
          triggeredBy: this.currentUser(),
          branch,
          cloud: '-',
          environment: env,
          appName: '-',
          startedAt: triggeredAt,
          duration: null,
          stages: {
            prepare: 'Pending',
            download: 'Pending',
            review: this.newRunReview ? 'Pending' : 'Skipped',
            build: 'Pending',
            test: 'Pending',
            scan: 'Pending',
            infraDeploy: 'Pending',
            appDeploy: 'Pending',
            integrationTest: 'Pending'
          }
        };
        this.pendingRuns.set(result.runId, { run: pendingRun, appName: appName! });
        this.pagedRuns.update(runs => [pendingRun, ...runs]);
        this.showToast(`Pipeline run #${result.runId} has been queued for "${appName}" on branch "${branch}" (${env}).`);
      },
      error: () => {
        this.loading.set(false);
        this.showToast(`Failed to trigger pipeline run for "${appName}".`);
      }
    });
  }

  protected onCancelRunById(runId: number): void {
    const appName = this.appDetail()?.name;
    if (!appName) return;
    this.cancelledRuns.add(runId);
    // Immediately show "Cancelling" state
    this.pagedRuns.update(runs =>
      runs.map(r => r.id === runId ? { ...r, status: 'Canceling' as const } : r)
    );
    this.apps.update(list => list.map(a =>
      a.name === appName && a.runId === runId ? { ...a, runStatus: 'Canceling' as const } : a
    ));
    this.appService.cancelRun(appName, runId).subscribe({
      next: () => {
        this.showToast(`Pipeline run #${runId} for "${appName}" has been cancelled.`);
      },
      error: () => {
        this.cancelledRuns.delete(runId);
        // Revert optimistic update
        this.pagedRuns.update(runs =>
          runs.map(r => r.id === runId ? { ...r, status: 'Running' as const } : r)
        );
        this.apps.update(list => list.map(a =>
          a.name === appName && a.runId === runId ? { ...a, runStatus: 'Running' as const } : a
        ));
        this.showToast(`Failed to cancel pipeline run for "${appName}".`);
      }
    });
  }

  protected onRemoveApp(): void {
    const app = this.selectedApp();
    if (!app) return;
    if (!confirm(`Are you sure you want to remove "${app.name}" from your list?`)) return;

    this.appService.removeFromMyApps(app.name).subscribe({
      next: () => {
        this.apps.update(list => list.filter(a => a.name !== app.name));
        this.closeManageModal();
        this.showToast(`"${app.name}" has been removed from your list.`);
      },
      error: () => this.showToast('Failed to remove app. Please try again.')
    });
  }

  protected closeManageModal(): void {
    this.showManageModal.set(false);
    this.manageModalFullscreen.set(false);
    this.selectedApp.set(null);
    this.appDetail.set(null);
    this.collapseStageDetail();
  }

  protected toggleManageModalFullscreen(): void {
    this.manageModalFullscreen.update(v => !v);
  }

  // ── Builder modal ─────────────────────────────────────────────────────────

  protected showBuilderModal = signal(false);
  private builderOpenedFromNewRun = false;
  protected builderStep = signal<BuilderStep>(1);

  protected builderAppName = '';
  protected builderAppType = '';
  protected builderCodePath = '';
  protected builderRuntimeVersion = '';
  protected builderInfraPath = '';
  protected builderConfigPath = '';
  protected builderScanTool = '';
  protected builderUnitTestTool = '';
  protected builderIntegrationTestTool = '';

  protected builderAwsAccountId = '';
  protected builderAwsRegion = 'us-west-2';
  protected builderSecretsManagerName = '';
  protected builderSecretsManagerKeys = signal<string[]>(['']);
  // Cloud Foundry deploy target — CAP apps only.
  protected builderCfApi = '';
  protected builderCfOrg = '';
  protected builderCfSpace = '';
  protected builderCfOrigin = '';
  // EC2 Image Builder component names — AMI apps only (required: cloud.components).
  protected builderComponents = signal<string[]>(['']);

  protected readonly builderRuntimePlaceholders: Record<string, string> = {
    angular: '20 (default)', react: '20 (default)', dotnet: '9.x (default)', python: '3.11 (default)', java: '17 (default)', go: '1.23 (default)', html: '20 (default)', php: '8.3 (default)', cap: '20 (default)', ami: '', btp: '', infra: ''
  };

  protected readonly builderUnitTestOptions: Record<string, string[]> = {
    angular: ['karma', 'jest'], react: ['jest', 'vitest'], dotnet: ['xunit', 'nunit'], python: ['pytest'], java: ['junit'], go: ['gotestsum'], php: ['phpunit'], cap: ['jest'], html: [], ami: [], btp: [], infra: []
  };

  protected readonly builderIntegrationTestOptions: Record<string, string[]> = {
    angular: ['playwright'], react: ['playwright'], dotnet: ['playwright'], node: ['playwright'], python: ['playwright'], java: ['playwright'], go: ['playwright'], php: ['playwright'], html: ['playwright'], cap: ['playwright'], ami: [], btp: [], infra: []
  };

  protected onBuilderAppTypeChange(): void {
    // App Name is entered before App Type (and is type-independent), so preserve it.
    this.builderCodePath = '';
    this.builderRuntimeVersion = '';
    this.builderInfraPath = '';
    this.builderConfigPath = '';
    // Prefill preferred tools (first option) for the new appType. The scan/test fields only
    // render for code-bearing appTypes (not btp/ami/infra); defaultScanTool returns '' for
    // those, and builderUnitTestOptions is empty for them, so both stay on "None".
    this.builderScanTool = defaultScanTool(this.builderAppType as AppType);
    this.builderUnitTestTool = this.builderUnitTestOptions[this.builderAppType]?.[0] ?? '';
    // Integration test tool intentionally left unset — defaults to "None" (matches the wizard).
    this.builderIntegrationTestTool = '';
    this.builderAwsAccountId = '';
    this.builderAwsRegion = 'us-west-2';
    this.builderSecretsManagerName = '';
    this.builderSecretsManagerKeys.set(['']);
    this.builderCfApi = '';
    this.builderCfOrg = '';
    this.builderCfSpace = '';
    this.builderCfOrigin = '';
    this.builderComponents.set(['']);
  }

  protected openBuilderFromNewRun(): void {
    this.builderOpenedFromNewRun = true;
    this.showNewRunModal.set(false);
    this.openBuilder();
  }

  protected openBuilder(): void {
    this.builderStep.set(1);
    this.builderAppName = '';
    this.builderAppType = '';
    this.builderCodePath = '';
    this.builderRuntimeVersion = '';
    this.builderInfraPath = '';
    this.builderConfigPath = '';
    this.builderScanTool = '';
    this.builderUnitTestTool = '';
    this.builderIntegrationTestTool = '';
    this.builderAwsAccountId = '';
    this.builderAwsRegion = 'us-west-2';
    this.builderSecretsManagerName = '';
    this.builderSecretsManagerKeys.set(['']);
    this.builderCfApi = '';
    this.builderCfOrg = '';
    this.builderCfSpace = '';
    this.builderCfOrigin = '';
    this.builderComponents.set(['']);
    this.closeHowTo();
    this.showBuilderModal.set(true);
  }

  protected closeBuilder(): void {
    this.showBuilderModal.set(false);
    if (this.builderOpenedFromNewRun) {
      this.builderOpenedFromNewRun = false;
      this.showManageModal.set(true);
    } else {
      this.showHowToModal.set(true);
    }
  }

  protected builderNext(): void {
    const step = this.builderStep();
    if (step === 1) this.builderStep.set(2);
    else if (step === 2) this.builderStep.set(3);
  }

  protected builderBack(): void {
    const step = this.builderStep();
    if (step === 3) this.builderStep.set(2);
    else if (step === 2) this.builderStep.set(1);
  }

  protected addSecretKey(): void {
    this.builderSecretsManagerKeys.update(keys => [...keys, '']);
    setTimeout(() => {
      const rows = document.querySelectorAll('.builder-keys__row input');
      (rows[rows.length - 1] as HTMLElement)?.focus();
    });
  }

  protected removeSecretKey(index: number): void {
    this.builderSecretsManagerKeys.update(keys => keys.filter((_, i) => i !== index));
  }

  protected updateSecretKey(index: number, value: string): void {
    this.builderSecretsManagerKeys.update(keys => keys.map((k, i) => i === index ? value : k));
  }

  protected addComponent(): void {
    this.builderComponents.update(c => [...c, '']);
    setTimeout(() => {
      const rows = document.querySelectorAll('.builder-components__row input');
      (rows[rows.length - 1] as HTMLElement)?.focus();
    });
  }

  protected removeComponent(index: number): void {
    this.builderComponents.update(c => c.filter((_, i) => i !== index));
  }

  protected updateComponent(index: number, value: string): void {
    this.builderComponents.update(c => c.map((v, i) => i === index ? value : v));
  }

  protected get builderJson(): string {
    const app: Record<string, any> = { appName: this.builderAppName, appType: this.builderAppType };
    if (this.builderCodePath) app['codePath'] = this.builderCodePath;
    if (this.builderRuntimeVersion) app['runtimeVersion'] = this.builderRuntimeVersion;
    if (this.builderInfraPath) app['infraPath'] = this.builderInfraPath;
    if (this.builderConfigPath) app['configPath'] = this.builderConfigPath;
    if (this.builderScanTool) app['scanTool'] = this.builderScanTool;
    if (this.builderUnitTestTool) app['buildTestTool'] = this.builderUnitTestTool;
    if (this.builderIntegrationTestTool) app['integrationTestTool'] = this.builderIntegrationTestTool;

    const cloud: Record<string, any> = { awsAccountId: this.builderAwsAccountId, awsRegion: this.builderAwsRegion };
    if (this.builderAppType === 'cap') {
      // CAP deploys to a pre-existing Cloud Foundry space — all four CF fields are
      // required by the deploy stage (deploy/sap/cap.yml), plus the Secrets Manager
      // entry holding the CF credentials.
      cloud['cfApi'] = this.builderCfApi;
      cloud['cfOrg'] = this.builderCfOrg;
      cloud['cfSpace'] = this.builderCfSpace;
      cloud['cfOrigin'] = this.builderCfOrigin;
      const keys = this.builderSecretsManagerKeys().filter(k => k.trim());
      cloud['secretsManager'] = { name: this.builderSecretsManagerName, keys };
    } else if (this.builderAppType === 'btp' || this.builderAppType === 'infra') {
      const keys = this.builderSecretsManagerKeys().filter(k => k.trim());
      if (this.builderSecretsManagerName || keys.length) {
        cloud['secretsManager'] = { name: this.builderSecretsManagerName, keys };
      }
    } else if (this.builderAppType === 'ami') {
      // AMI triggers one EC2 Image Builder pipeline per component — cloud.components
      // is required by the build stage (build/ami/main.yml).
      cloud['components'] = this.builderComponents().map(c => c.trim()).filter(Boolean);
    }

    return JSON.stringify({ app, cloud }, null, 2);
  }

  protected copyBuilderJson(): void {
    navigator.clipboard.writeText(this.builderJson).then(() => {
      this.showToast('epic.json copied to clipboard.');
    });
  }

  // Normalize-as-typed handlers, mirroring the wizard. The builder binds plain properties
  // (not signals), so these run on every (ngModelChange).
  protected onBuilderAppNameChange(value: string): void {
    this.builderAppName = normalizeAppName(value);
  }

  protected onBuilderAwsAccountIdChange(value: string): void {
    this.builderAwsAccountId = normalizeAwsAccountId(value);
  }

  // Inline format errors — null while empty or valid, message once present-but-malformed.
  protected get builderAppNameError(): string | null {
    const name = this.builderAppName.trim();
    if (!name) return null;
    return APP_NAME_PATTERN.test(name) ? null : APP_NAME_RULE;
  }

  protected get builderAwsAccountIdError(): string | null {
    const id = this.builderAwsAccountId.trim();
    if (!id) return null;
    return AWS_ACCOUNT_ID_PATTERN.test(id) ? null : 'AWS account ID must be exactly 12 digits.';
  }

  protected get canBuilderNext(): boolean {
    if (this.builderStep() === 1) return APP_NAME_PATTERN.test(this.builderAppName.trim()) && !!this.builderAppType;
    if (this.builderStep() === 2) {
      if (!AWS_ACCOUNT_ID_PATTERN.test(this.builderAwsAccountId.trim()) || !this.builderAwsRegion) return false;
      // CAP deploy fails without all four Cloud Foundry fields, so require them here.
      if (this.builderAppType === 'cap') {
        return !!this.builderCfApi.trim() && !!this.builderCfOrg.trim()
          && !!this.builderCfSpace.trim() && !!this.builderCfOrigin.trim();
      }
      // AMI build requires at least one Image Builder component.
      if (this.builderAppType === 'ami') {
        return this.builderComponents().some(c => c.trim());
      }
      return true;
    }
    return true;
  }

  // ── Create New App Wizard ─────────────────────────────────────────────────

  protected readonly APP_TYPE_LABELS = APP_TYPE_LABELS;
  protected readonly NO_ARCHITECTURE_APP_TYPES = NO_ARCHITECTURE_APP_TYPES;
  protected readonly SCAN_TOOL_OPTIONS = SCAN_TOOL_OPTIONS;
  // Live input normalizers, exposed for template (ngModelChange) wiring. See wizard.model.ts.
  protected readonly normalizeAppName = normalizeAppName;
  protected readonly normalizeAwsAccountId = normalizeAwsAccountId;
  protected readonly normalizeAzureSubscriptionId = normalizeAzureSubscriptionId;

  protected wizardBuildTestOptions(): string[] {
    const t = this.wizardAnswers().appType;
    return t ? BUILD_TEST_TOOL_OPTIONS[t] : [];
  }

  protected wizardIntegrationTestOptions(): string[] {
    const t = this.wizardAnswers().appType;
    return t ? INTEGRATION_TEST_TOOL_OPTIONS[t] : [];
  }

  protected showCreateAppWizard = signal(false);
  protected wizardStep = signal<WizardStep>(1);
  protected wizardAnswers = signal<WizardAnswers>(emptyAnswers(''));
  // Derived live from the typed app name so the requirement is surfaced as the user types,
  // rather than only on a Next click that can never fire while the button is disabled.
  // Stays null while the field is empty so we don't yell before the user has typed anything.
  protected readonly wizardAppNameError = computed<string | null>(() => {
    const name = this.wizardAnswers().appName.trim();
    if (!name) return null;
    if (!APP_NAME_PATTERN.test(name)) {
      return APP_NAME_RULE;
    }
    if (this.apps().some((m) => m.name.toLowerCase() === name.toLowerCase())) {
      return 'An app with this name is already onboarded into EPIC.';
    }
    return null;
  });

  // Inline format feedback for the cloud-target IDs. Null while empty (don't nag before the
  // user types) or well-formed; a message once the value is present but malformed. Mirrors the
  // pattern checks in validateWizardStep3 / canWizardNext so the button and the hint agree.
  protected readonly wizardAwsAccountIdError = computed<string | null>(() => {
    const id = this.wizardAnswers().awsAccountId.trim();
    if (!id) return null;
    return AWS_ACCOUNT_ID_PATTERN.test(id) ? null : 'AWS account ID must be exactly 12 digits.';
  });

  protected readonly wizardAzureSubscriptionIdError = computed<string | null>(() => {
    const id = this.wizardAnswers().azureSubscriptionId.trim();
    if (!id) return null;
    return AZURE_SUBSCRIPTION_ID_PATTERN.test(id) ? null : 'Azure subscription ID must be a UUID.';
  });
  protected wizardPreview = signal<string>('');
  protected epicInfraContent = signal<string>('');
  protected epicInfraLoadError = signal<boolean>(false);

  protected readonly wizardAppTypeOptions = computed<AppType[]>(() =>
    [...appTypesForCloud(this.wizardAnswers().cloudProvider)].sort((a, b) =>
      APP_TYPE_LABELS[a].localeCompare(APP_TYPE_LABELS[b]),
    ),
  );

  protected readonly wizardArchitectureSkipped = computed<boolean>(() => {
    const t = this.wizardAnswers().appType;
    return !!t && NO_ARCHITECTURE_APP_TYPES.includes(t);
  });

  protected wizardAppTypeLabel(): string {
    const t = this.wizardAnswers().appType;
    return t ? APP_TYPE_LABELS[t] : '';
  }

  protected onCreateNewApp(): void {
    const fresh = emptyAnswers(this.currentUser() || '');
    this.wizardAnswers.set(fresh);
    this.wizardStep.set(1);
    this.wizardPreview.set('');
    this.showCreateAppWizard.set(true);
    this.loadEpicInfraSteering();
  }

  private loadEpicInfraSteering(): void {
    if (this.epicInfraContent() && !this.epicInfraLoadError()) return;
    this.epicInfraLoadError.set(false);
    fetch('/steering/epic-infra.md')
      .then((res) => {
        if (!res.ok) throw new Error(`status ${res.status}`);
        return res.text();
      })
      .then((text) => {
        this.epicInfraContent.set(text);
        this.epicInfraLoadError.set(false);
      })
      .catch(() => {
        this.epicInfraContent.set('');
        this.epicInfraLoadError.set(true);
      });
  }

  protected closeCreateAppWizard(): void {
    this.showCreateAppWizard.set(false);
  }

  protected wizardNext(): void {
    const step = this.wizardStep();
    if (step === 1 && !this.validateWizardStep1()) return;
    if (step === 3 && !this.validateWizardStep3()) return;
    if (step === 4) {
      this.wizardPreview.set(renderEpicMd(this.stampedAnswers(), this.epicInfraContent()));
    }
    const forward: Record<WizardStep, WizardStep> = { 1: 2, 2: 3, 3: 4, 4: 5, 5: 5 };
    this.wizardStep.set(forward[step]);
  }

  protected wizardBack(): void {
    const back: Record<WizardStep, WizardStep> = { 1: 1, 2: 1, 3: 2, 4: 3, 5: 4 };
    this.wizardStep.set(back[this.wizardStep()]);
  }

  protected wizardUpdate<K extends keyof WizardAnswers>(key: K, value: WizardAnswers[K]): void {
    this.wizardAnswers.update((a) => ({ ...a, [key]: value }));
  }

  protected wizardOnAppTypeChange(value: string): void {
    const appType = value as AppType;
    this.wizardAnswers.update((a) => {
      const next: WizardAnswers = { ...a, appType };
      // Reset every appType-dependent field, then prefill the preferred tool for the new
      // appType (first option in each list). buildTestTool/integrationTestTool have different
      // option sets per appType; scanTool's options are universal but the rendered tooling-
      // allowlist section only fires for code-bearing appTypes, so defaultScanTool returns ''
      // for btp/infra/ami to avoid emitting a scanTool into epic.json without a matching allowlist.
      next.scanTool = defaultScanTool(appType);
      next.buildTestTool = defaultBuildTestTool(appType);
      // Integration test tool intentionally left unset — defaults to "None".
      next.integrationTestTool = '';
      // Deploy-target keys are per-(appType, cloudProvider); leftover values from the old
      // appType are filtered by the renderer/form but pollute state — clear them.
      next.deployTarget = emptyDeployTarget();
      // BTP and CAP force aws cloud (their secrets live in AWS Secrets Manager).
      if (appType === 'btp' || appType === 'cap') next.cloudProvider = 'aws';
      // Reset the Secrets Manager target and prefill the credential keys each appType
      // typically needs (still user-editable). Cleared for everything else.
      next.cfApi = '';
      next.cfOrg = '';
      next.cfSpace = '';
      next.cfOrigin = '';
      next.secretsManagerName = '';
      if (appType === 'btp') {
        next.secretsManagerKeys = ['BTP_USERNAME', 'BTP_PASSWORD', 'CF_USER', 'CF_PASSWORD'];
      } else if (appType === 'cap') {
        next.secretsManagerKeys = ['CF_USER', 'CF_PASSWORD'];
      } else {
        next.secretsManagerKeys = [];
      }
      // AMI requires at least one Image Builder component; seed one empty row.
      next.amiComponents = appType === 'ami' ? [''] : [];
      // Reset architecture toggles for app types that bypass them.
      if (NO_ARCHITECTURE_APP_TYPES.includes(appType)) {
        next.hasFrontend = false;
        next.frontend = null;
        next.hasBackend = false;
        next.backend = null;
        next.needsDatabase = false;
        next.database = null;
        next.needsQueue = false;
        next.queue = null;
        next.needsScheduler = false;
        next.schedulerCron = '';
        next.needsStorage = false;
        next.storage = null;
      } else if (['angular', 'react', 'html'].includes(appType)) {
        // Sensible defaults: SPAs get frontend.
        next.hasFrontend = true;
        next.frontend = next.frontend ?? { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false };
        next.hasBackend = false;
        next.backend = null;
      } else if (['dotnet', 'node', 'python', 'java', 'go', 'php'].includes(appType)) {
        // Server runtimes get backend.
        next.hasBackend = true;
        next.backend = next.backend ?? { style: 'rest-api', runtime: '', authStyle: 'none', authClientId: '' };
        next.hasFrontend = false;
        next.frontend = null;
      }
      // Default infra=true for cloud-using apps; off for plain html sites with no backend.
      next.includeInfra = !(appType === 'html' && !next.hasBackend);
      // infra and btp always provision Terraform (btp is exempt from the orchestrator's
      // missing-folder skip); cap deploys to a pre-existing CF space and never provisions.
      if (appType === 'infra' || appType === 'btp') next.includeInfra = true;
      if (appType === 'cap') next.includeInfra = false;
      return next;
    });
  }


  protected wizardOnCloudChange(value: string): void {
    const provider = value as CloudProvider;
    this.wizardAnswers.update((a) => {
      const next: WizardAnswers = { ...a, cloudProvider: provider };
      // If the current appType is invalid under this cloud, reset (let user re-pick).
      const allowed = appTypesForCloud(provider);
      if (next.appType && !allowed.includes(next.appType)) next.appType = '';
      return next;
    });
  }

  protected wizardUpdateDeployTarget<K extends keyof DeployTarget>(key: K, value: DeployTarget[K]): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      deployTarget: { ...a.deployTarget, [key]: value },
    }));
  }

  protected wizardAddSecretKey(): void {
    this.wizardAnswers.update((a) => ({ ...a, secretsManagerKeys: [...a.secretsManagerKeys, ''] }));
    setTimeout(() => {
      const rows = document.querySelectorAll('.wizard-keys__row input');
      (rows[rows.length - 1] as HTMLElement)?.focus();
    });
  }

  protected wizardRemoveSecretKey(index: number): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      secretsManagerKeys: a.secretsManagerKeys.filter((_, i) => i !== index),
    }));
  }

  protected wizardUpdateSecretKey(index: number, value: string): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      secretsManagerKeys: a.secretsManagerKeys.map((k, i) => (i === index ? value : k)),
    }));
  }

  protected wizardAddComponent(): void {
    this.wizardAnswers.update((a) => ({ ...a, amiComponents: [...a.amiComponents, ''] }));
    setTimeout(() => {
      const rows = document.querySelectorAll('.wizard-components__row input');
      (rows[rows.length - 1] as HTMLElement)?.focus();
    });
  }

  protected wizardRemoveComponent(index: number): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      amiComponents: a.amiComponents.filter((_, i) => i !== index),
    }));
  }

  protected wizardUpdateComponent(index: number, value: string): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      amiComponents: a.amiComponents.map((c, i) => (i === index ? value : c)),
    }));
  }

  protected wizardDeployTargetKeys(): (keyof DeployTarget)[] {
    const a = this.wizardAnswers();
    if (!a.appType) return [];
    return relevantDeployTargetKeys(a.appType as AppType, a.cloudProvider);
  }

  protected wizardShowDeployTargetKey(key: keyof DeployTarget): boolean {
    return this.wizardDeployTargetKeys().includes(key);
  }

  protected get wizardShowDeployTargetSection(): boolean {
    const a = this.wizardAnswers();
    return !a.includeInfra && this.wizardDeployTargetKeys().length > 0;
  }

  protected wizardToggleFrontend(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      hasFrontend: checked,
      frontend: checked
        ? a.frontend ?? { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false }
        : null,
    }));
  }

  protected wizardToggleBackend(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      hasBackend: checked,
      backend: checked
        ? a.backend ?? { style: 'rest-api', runtime: '', authStyle: 'none', authClientId: '' }
        : null,
    }));
  }

  protected wizardToggleDatabase(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      needsDatabase: checked,
      database: checked
        ? a.database ?? { engine: 'postgres', scale: 'single-instance' }
        : null,
    }));
  }

  protected wizardToggleQueue(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      needsQueue: checked,
      queue: checked ? a.queue ?? { kind: 'sqs' } : null,
    }));
  }

  protected wizardToggleScheduler(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      needsScheduler: checked,
      schedulerCron: checked ? a.schedulerCron : '',
    }));
  }

  protected wizardToggleStorage(checked: boolean): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      needsStorage: checked,
      storage: checked ? a.storage ?? { kind: 's3' } : null,
    }));
  }

  protected wizardUpdateFrontend<K extends 'framework' | 'authMode' | 'authClientId' | 'apiBaseUrlNeeded'>(key: K, value: any): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      frontend: a.frontend ? { ...a.frontend, [key]: value } : a.frontend,
    }));
  }

  protected wizardUpdateBackend<K extends 'style' | 'runtime' | 'authStyle' | 'authClientId'>(key: K, value: any): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      backend: a.backend ? { ...a.backend, [key]: value } : a.backend,
    }));
  }

  protected wizardUpdateDatabase<K extends 'engine' | 'scale'>(key: K, value: any): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      database: a.database ? { ...a.database, [key]: value } : a.database,
    }));
  }

  protected wizardUpdateQueue(value: QueueKind): void {
    this.wizardAnswers.update((a) => ({ ...a, queue: a.queue ? { kind: value } : a.queue }));
  }

  protected wizardUpdateStorage(value: StorageKind): void {
    this.wizardAnswers.update((a) => ({ ...a, storage: a.storage ? { kind: value } : a.storage }));
  }

  private validateWizardStep1(): boolean {
    // The name error is surfaced reactively via the wizardAppNameError computed; this is
    // just the click-time guard. appType has no inline message — it can't be invalid without
    // also disabling Next, so reaching here with it unset shouldn't happen.
    const a = this.wizardAnswers();
    return !this.wizardAppNameError() && APP_NAME_PATTERN.test(a.appName.trim()) && !!a.appType;
  }

  /** AWS account id + region are both present and well-formed. */
  private wizardAwsAccountAndRegionValid(): boolean {
    const a = this.wizardAnswers();
    return AWS_ACCOUNT_ID_PATTERN.test(a.awsAccountId.trim()) && !!a.awsRegion.trim();
  }

  private validateWizardStep3(): boolean {
    const a = this.wizardAnswers();
    // CAP never includes infra but still needs an AWS account (Secrets Manager),
    // all four Cloud Foundry fields, and a Secrets Manager name — validate before
    // the includeInfra short-circuit.
    if (a.appType === 'cap') {
      return this.wizardAwsAccountAndRegionValid() && this.wizardCapCloudComplete() && !!a.secretsManagerName.trim();
    }
    if (a.appType === 'btp') {
      return this.wizardAwsAccountAndRegionValid() && !!a.secretsManagerName.trim();
    }
    // AMI needs an AWS account/region and at least one Image Builder component,
    // regardless of whether it also includes a .infra/ project.
    if (a.appType === 'ami') {
      return this.wizardAwsAccountAndRegionValid() && a.amiComponents.some((c) => c.trim());
    }
    if (!a.includeInfra) return true;
    if (a.cloudProvider === 'aws') return this.wizardAwsAccountAndRegionValid();
    if (a.cloudProvider === 'azure') return AZURE_SUBSCRIPTION_ID_PATTERN.test(a.azureSubscriptionId.trim());
    return true;
  }

  private wizardCapCloudComplete(): boolean {
    const a = this.wizardAnswers();
    return !!a.cfApi.trim() && !!a.cfOrg.trim() && !!a.cfSpace.trim() && !!a.cfOrigin.trim();
  }

  protected get canWizardNext(): boolean {
    const a = this.wizardAnswers();
    const step = this.wizardStep();
    if (step === 1) {
      // wizardAppNameError covers both the kebab-case pattern and the collision check,
      // so a non-null error (or an empty name) keeps Next disabled.
      return !this.wizardAppNameError() && APP_NAME_PATTERN.test(a.appName.trim()) && !!a.appType;
    }
    // Step 3 gating is exactly the step-3 validation; every other step is always enabled.
    if (step === 3) return this.validateWizardStep3();
    return true;
  }

  private stampedAnswers(): WizardAnswers {
    return {
      ...this.wizardAnswers(),
      generatedAt: new Date().toISOString(),
      generatedBy: this.currentUser() || this.wizardAnswers().generatedBy || 'unknown',
    };
  }

  protected wizardDownload(): void {
    if (this.epicInfraLoadError()) {
      this.showToast('EPIC infrastructure steering content failed to load. Refresh and try again.');
      return;
    }
    const md = this.wizardPreview() || renderEpicMd(this.stampedAnswers(), this.epicInfraContent());
    const blob = new Blob([md], { type: 'text/markdown' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'epic.md';
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
    this.showToast('epic.md downloaded.');
  }

  protected wizardCopy(): void {
    if (this.epicInfraLoadError()) {
      this.showToast('EPIC infrastructure steering content failed to load. Refresh and try again.');
      return;
    }
    const md = this.wizardPreview() || renderEpicMd(this.stampedAnswers(), this.epicInfraContent());
    navigator.clipboard.writeText(md).then(() => this.showToast('epic.md copied to clipboard.'));
  }

  // ── Toast ─────────────────────────────────────────────────────────────────

  protected toastMessage = signal<string | null>(null);
  private toastTimer: ReturnType<typeof setTimeout> | null = null;
  private readonly toastDuration = 5000;

  protected getRunUrl(runId: number): string {
    return `https://dev.azure.com/pgetech/EPIC-Pipeline/_build/results?buildId=${runId}&view=results`;
  }

  protected dismissToast(): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastMessage.set(null);
  }

  protected pauseToast(): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
  }

  protected resumeToast(): void {
    this.toastTimer = setTimeout(() => this.toastMessage.set(null), this.toastDuration);
  }

  private showToast(message: string): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastMessage.set(message);
    this.toastTimer = setTimeout(() => this.toastMessage.set(null), this.toastDuration);
  }
}
