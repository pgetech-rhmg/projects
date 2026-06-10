import { Component, HostListener, OnInit, OnDestroy, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { InteractionStatus } from '@azure/msal-browser';
import { filter, takeUntil } from 'rxjs/operators';
import { Subject } from 'rxjs';

import { AppDetail, AppLookup, ManagedApp, PipelineRun, PipelineRunPage, RunStatus, StageDetail, StageStep } from './models/app.model';
import { AppService } from './services/app.service';
import {
  APP_TYPE_LABELS,
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
  emptyAnswers,
  emptyDeployTarget,
  relevantDeployTargetKeys,
} from './wizard/wizard.model';
import { renderEpicMd } from './wizard/wizard.template';

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

  // Track apps with locally-set pending state until ADO picks up the new run
  private pendingApps = new Map<string, ManagedApp>();

  // Track cancelled run IDs until ADO confirms the cancellation
  private cancelledRuns = new Set<number>();

  // Track pending runs until API returns them (keyed by runId, value includes app name for filtering)
  private pendingRuns = new Map<number, { run: PipelineRun; appName: string }>();

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

        if (!this.refreshTimer) {
          this.appService.getApps().subscribe({
            next: (data) => {
              this.apps.set(data);
              this.dataLoading.set(false);
            },
            error: () => this.dataLoading.set(false),
          });
          this.startAutoRefresh();
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
    if (this.showBuilderModal()) this.closeBuilder();
    else if (this.showHowToModal()) this.closeHowTo();
    else if (this.showNewRunModal()) this.closeNewRunModal();
    else if (this.showAddModal()) this.closeAddModal();
    else if (this.showManageModal()) this.closeManageModal();
    else if (this.showCreateAppWizard()) this.closeCreateAppWizard();
  }

  private startAutoRefresh(): void {
    this.refreshTimer = setInterval(() => {
      // Refresh main table — preserve pending state until ADO catches up
      this.appService.getApps().subscribe({
        next: data => {
          const applyOverrides = (apps: ManagedApp[]) => apps.map(app => {
            if (app.runId && this.cancelledRuns.has(app.runId)) {
              if (app.runStatus === 'Canceled') {
                this.cancelledRuns.delete(app.runId);
                return app;
              }
              return { ...app, runStatus: 'Canceling' as const };
            }
            return app;
          });

          if (this.pendingApps.size === 0) {
            this.apps.set(applyOverrides(data));
          } else {
            this.apps.set(applyOverrides(data.map(app => {
              const pending = this.pendingApps.get(app.name);
              if (!pending) return app;
              // ADO has caught up if the API's last run is newer than when we triggered
              if (app.lastPipelineRun && new Date(app.lastPipelineRun) > new Date(pending.lastPipelineRun!)) {
                this.pendingApps.delete(app.name);
                return app;
              }
              // Still stale — keep our pending overlay
              return { ...app, runStatus: 'Pending' as const, branch: pending.branch, environment: pending.environment, triggeredBy: pending.triggeredBy, lastPipelineRun: pending.lastPipelineRun };
            })));
          }
        },
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
              this.pendingRuns.delete(r.id);
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
      (!triggeredBy || app.triggeredBy === triggeredBy)
    ).sort((a, b) => a.name.localeCompare(b.name));
  });

  // ── Filter options ────────────────────────────────────────────────────────

  protected readonly techOptions = computed(() =>
    [...new Set(this.apps().map(a => a.technology))].sort()
  );
  protected readonly cloudOptions = computed(() =>
    [...new Set(this.apps().map(a => a.cloud))].sort()
  );
  protected readonly envOptions = computed(() =>
    [...new Set(this.apps().map(a => a.environment))].sort()
  );
  protected readonly statusOptions = computed(() =>
    [...new Set(this.apps().map(a => a.runStatus))].sort()
  );
  protected readonly triggeredByOptions = computed(() =>
    [...new Set(this.apps().map(a => a.triggeredBy))].sort()
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
    if (isNaN(d.getTime())) return iso;
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${pad(d.getMonth() + 1)}/${pad(d.getDate())}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
  }

  // ── User ──────────────────────────────────────────────────────────────────

  protected initialsFor(name: string | null): string {
    if (!name) return '—';
    if (name === 'System') return '⚙';

    // Normalize: strip commas, split into parts, filter empties
    const parts = name.replace(/,/g, '').split(/\s+/).filter(Boolean);
    if (parts.length === 0) return '?';

    // Detect "Last, First [Middle]" format (original had a comma)
    if (name.includes(',') && parts.length >= 2) {
      const first = parts[1]; // first name is after the comma
      const last = parts[0];  // last name is before the comma
      return (first[0] + last[0]).toUpperCase();
    }

    // "First Last" or "First Middle Last" — use first and last
    const first = parts[0];
    const last = parts[parts.length - 1];
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
          .then((res) => (res.ok ? res.blob() : Promise.reject()))
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
    "buildTestTool": "jest"
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

  protected onStageClick(event: Event, run: PipelineRun, stageName: string): void {
    event.stopPropagation();

    const stageStatus = (run.stages as Record<string, RunStatus>)[stageName];
    if (stageStatus === 'Skipped' || stageStatus === 'Pending') return;

    const current = this.expandedStage();
    if (current && current.runId === run.id && current.stageName === stageName) {
      this.expandedStage.set(null);
      this.stageDetail.set(null);
      this.collapseStepLog();
      return;
    }

    this.expandedStage.set({ runId: run.id, stageName });
    this.stageDetail.set(null);
    this.stageDetailLoading.set(true);
    this.collapseStepLog();

    const appName = this.selectedApp()?.name;
    if (!appName) return;

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

  private collapseStepLog(): void {
    this.expandedLogId.set(null);
    this.stepLog.set(null);
  }

  protected collapseStageDetail(): void {
    this.expandedStage.set(null);
    this.stageDetail.set(null);
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
  protected newRunBuild = true;
  protected newRunTests = false;
  protected newRunScan = false;
  protected newRunDeploy = false;
  protected newRunIntegrations = false;
  protected newRunDeployInfra = 'none';
  protected configSearchStatus = signal<'idle' | 'searching' | 'found' | 'not-found' | 'error'>('idle');
  protected availableConfigs = signal<string[]>([]);
  protected newRunHasInfra = signal(false);
  protected newRunHasInfraParams = signal(false);
  protected newRunConfigAppType = signal<string | null>(null);
  protected newRunValidating = signal(false);
  private lastValidatedBranch = '';

  protected newAppRepo = '';
  protected repoCheckStatus = signal<'idle' | 'checking' | 'available' | 'in-epic-not-mine' | 'already-mine' | 'not-found'>('idle');
  protected foundMasterApp = signal<AppLookup | null>(null);

  protected onAddApp(): void {
    this.newAppRepo = '';
    this.repoCheckStatus.set('idle');
    this.foundMasterApp.set(null);
    this.showAddModal.set(true);
  }

  protected closeAddModal(): void {
    this.showAddModal.set(false);
  }

  protected onRepoChange(): void {
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
    this.appService.checkRepo(repo).subscribe({
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
    this.appService.onboardApp(repo).subscribe({
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
    this.newRunConfigAppType.set(null);
    this.newRunValidating.set(false);
    this.lastValidatedBranch = '';
    this.newRunBuild = true;
    this.newRunTests = false;
    this.newRunScan = false;
    this.newRunDeploy = false;
    this.newRunIntegrations = false;
    this.newRunDeployInfra = 'none';
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
    this.newRunConfigAppType.set(null);
  }

  protected onNewRunBranchBlur(): void {
    const branch = this.newRunBranch.trim();
    const repo = this.newRunApp()?.github?.repo;
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
    this.appService.getConfigs(repo, branch).subscribe({
      next: result => {
        if (result.configs.length === 0) {
          this.configSearchStatus.set('not-found');
          this.newRunValidating.set(false);
        } else {
          this.availableConfigs.set(result.configs);
          this.configSearchStatus.set('found');
          if (result.configs.length === 1) {
            this.newRunConfig = result.configs[0];
            this.appService.checkConfigInfra(repo, branch, result.configs[0]).subscribe({
              next: r => {
                this.newRunHasInfra.set(r.hasInfra);
                this.newRunHasInfraParams.set(r.hasInfraParams);
                this.newRunConfigAppType.set(r.appType);
                this.applyAppTypeDefaults(r.appType);
              },
              error: () => {
                this.newRunHasInfra.set(false);
                this.newRunHasInfraParams.set(false);
              },
              complete: () => this.newRunValidating.set(false)
            });
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
    this.newRunDeployInfra = 'none';
    this.checkInfraForConfig(repo, branch, this.newRunConfig);
  }

  private checkInfraForConfig(repo: string, branch: string, config: string): void {
    this.appService.checkConfigInfra(repo, branch, config).subscribe({
      next: result => {
        this.newRunHasInfra.set(result.hasInfra);
        this.newRunHasInfraParams.set(result.hasInfraParams);
        this.newRunConfigAppType.set(result.appType);
        this.applyAppTypeDefaults(result.appType);
      },
      error: () => {
        this.newRunHasInfra.set(false);
        this.newRunHasInfraParams.set(false);
      }
    });
  }

  private applyAppTypeDefaults(appType: string | null): void {
    if (appType === 'btp' || appType === 'infra') {
      this.newRunBuild = false;
      this.newRunDeploy = false;
      this.newRunIntegrations = false;
      this.newRunTests = false;
      this.newRunScan = false;
      this.newRunDeployInfra = 'apply';
    }
  }

  protected get infraDisabled(): boolean {
    return !this.newRunHasInfra();
  }

  protected get deployDisabled(): boolean {
    return !this.newRunConfig || !this.newRunBuild || this.newRunConfigAppType() === 'btp' || this.newRunConfigAppType() === 'infra' || this.infraDisabled;
  }

  protected get integrationTestsDisabled(): boolean {
    return !this.newRunConfig || this.infraDisabled;
  }

  protected onBuildToggle(checked: boolean): void {
    if (!checked) this.newRunDeploy = false;
  }

  protected get canRunNewPipeline(): boolean {
    return (
      !!this.newRunBranch.trim() &&
      !this.newRunBranchError() &&
      !!this.newRunEnvironment &&
      this.configSearchStatus() === 'found' &&
      !!this.newRunConfig.trim()
    );
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
      build: this.newRunBuild,
      tests: this.newRunTests,
      scan: this.newRunScan,
      deploy: this.newRunDeploy,
      integrations: this.newRunIntegrations,
      deployInfra: this.newRunDeployInfra
    }).subscribe({
      next: (result) => {
        this.loading.set(false);
        this.closeNewRunModal();
        // Record the trigger time so refresh can detect when ADO catches up
        const triggeredAt = new Date().toISOString();
        const currentApp = this.apps().find(a => a.name === appName);
        this.pendingApps.set(appName, {
          ...(currentApp ?? { name: appName, appName: null, technology: '', cloud: '', environment: env, runId: null, successRate: null, avgDuration: null }),
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
    this.selectedApp.set(null);
    this.appDetail.set(null);
    this.collapseStageDetail();
  }

  // ── Builder modal ─────────────────────────────────────────────────────────

  protected showBuilderModal = signal(false);
  private builderOpenedFromNewRun = false;
  protected builderStep = signal<1 | 2 | 3>(1);

  protected builderAppName = '';
  protected builderAppType = 'angular';
  protected builderCodePath = '';
  protected builderRuntimeVersion = '';
  protected builderInfraPath = '';
  protected builderConfigPath = '';
  protected builderScanTool = '';
  protected builderUnitTestTool = '';

  protected builderAwsAccountId = '';
  protected builderAwsRegion = 'us-west-2';
  protected builderSecretsManagerName = '';
  protected builderSecretsManagerKeys = signal<string[]>(['']);

  protected readonly builderRuntimePlaceholders: Record<string, string> = {
    angular: '20 (default)', react: '20 (default)', dotnet: '10.x (default)', python: '3.11 (default)', java: '17 (default)', html: '18 (default)', php: '8.3 (default)', ami: '', btp: '', infra: ''
  };

  protected readonly builderUnitTestOptions: Record<string, string[]> = {
    angular: ['jest'], react: ['jest', 'vitest'], dotnet: ['xunit', 'nunit'], python: ['pytest'], java: ['junit'], php: ['phpunit'], html: [], ami: [], btp: [], infra: []
  };

  protected onBuilderAppTypeChange(): void {
    this.builderAppName = '';
    this.builderCodePath = '';
    this.builderRuntimeVersion = '';
    this.builderInfraPath = '';
    this.builderConfigPath = '';
    this.builderScanTool = '';
    this.builderUnitTestTool = '';
    this.builderAwsAccountId = '';
    this.builderAwsRegion = 'us-west-2';
    this.builderSecretsManagerName = '';
    this.builderSecretsManagerKeys.set(['']);
  }

  protected openBuilderFromNewRun(): void {
    this.builderOpenedFromNewRun = true;
    this.showNewRunModal.set(false);
    this.openBuilder();
  }

  protected openBuilder(): void {
    this.builderStep.set(1);
    this.builderAppName = '';
    this.builderAppType = this.howToAppType || 'angular';
    this.builderCodePath = '';
    this.builderRuntimeVersion = '';
    this.builderInfraPath = '';
    this.builderConfigPath = '';
    this.builderScanTool = '';
    this.builderUnitTestTool = '';
    this.builderAwsAccountId = '';
    this.builderAwsRegion = 'us-west-2';
    this.builderSecretsManagerName = '';
    this.builderSecretsManagerKeys.set(['']);
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
      setTimeout(() => {
        document.querySelector('.howto-sample-controls')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    }
  }

  protected builderNext(): void {
    const step = this.builderStep();
    if (step < 3) this.builderStep.set((step + 1) as 1 | 2 | 3);
  }

  protected builderBack(): void {
    const step = this.builderStep();
    if (step > 1) this.builderStep.set((step - 1) as 1 | 2 | 3);
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

  protected get builderJson(): string {
    const app: Record<string, any> = { appName: this.builderAppName, appType: this.builderAppType };
    if (this.builderCodePath) app['codePath'] = this.builderCodePath;
    if (this.builderRuntimeVersion) app['runtimeVersion'] = this.builderRuntimeVersion;
    if (this.builderInfraPath) app['infraPath'] = this.builderInfraPath;
    if (this.builderConfigPath) app['configPath'] = this.builderConfigPath;
    if (this.builderScanTool) app['scanTool'] = this.builderScanTool;
    if (this.builderUnitTestTool) app['buildTestTool'] = this.builderUnitTestTool;

    const cloud: Record<string, any> = { awsAccountId: this.builderAwsAccountId, awsRegion: this.builderAwsRegion };
    if (this.builderAppType === 'btp' || this.builderAppType === 'infra') {
      const keys = this.builderSecretsManagerKeys().filter(k => k.trim());
      if (this.builderSecretsManagerName || keys.length) {
        cloud['secretsManager'] = { name: this.builderSecretsManagerName, keys };
      }
    }

    return JSON.stringify({ app, cloud }, null, 2);
  }

  protected copyBuilderJson(): void {
    navigator.clipboard.writeText(this.builderJson).then(() => {
      this.showToast('epic.json copied to clipboard.');
    });
  }

  protected get canBuilderNext(): boolean {
    if (this.builderStep() === 1) return !!this.builderAppName.trim() && !!this.builderAppType;
    if (this.builderStep() === 2) return !!this.builderAwsAccountId.trim() && !!this.builderAwsRegion;
    return true;
  }

  // ── Create New App Wizard ─────────────────────────────────────────────────

  protected readonly APP_TYPE_LABELS = APP_TYPE_LABELS;
  protected readonly NO_ARCHITECTURE_APP_TYPES = NO_ARCHITECTURE_APP_TYPES;
  protected readonly SCAN_TOOL_OPTIONS = SCAN_TOOL_OPTIONS;

  protected wizardBuildTestOptions(): string[] {
    const t = this.wizardAnswers().appType;
    return t ? BUILD_TEST_TOOL_OPTIONS[t] : [];
  }

  protected wizardIntegrationTestOptions(): string[] {
    const t = this.wizardAnswers().appType;
    return t ? INTEGRATION_TEST_TOOL_OPTIONS[t] : [];
  }

  protected showCreateAppWizard = signal(false);
  protected wizardStep = signal<1 | 2 | 3 | 4 | 5>(1);
  protected wizardAnswers = signal<WizardAnswers>(emptyAnswers(''));
  protected wizardAppNameError = signal<string | null>(null);
  protected wizardPreview = signal<string>('');
  protected epicInfraContent = signal<string>('');
  protected epicInfraLoadError = signal<boolean>(false);

  protected readonly wizardAppTypeOptions = computed<AppType[]>(() =>
    appTypesForCloud(this.wizardAnswers().cloudProvider),
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
    this.wizardAppNameError.set(null);
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
    if (step < 5) this.wizardStep.set((step + 1) as 1 | 2 | 3 | 4 | 5);
  }

  protected wizardBack(): void {
    const step = this.wizardStep();
    if (step > 1) this.wizardStep.set((step - 1) as 1 | 2 | 3 | 4 | 5);
  }

  protected wizardUpdate<K extends keyof WizardAnswers>(key: K, value: WizardAnswers[K]): void {
    this.wizardAnswers.update((a) => ({ ...a, [key]: value }));
  }

  protected wizardOnAppTypeChange(value: string): void {
    const appType = value as AppType;
    this.wizardAnswers.update((a) => {
      const next: WizardAnswers = { ...a, appType };
      // Reset every appType-dependent field. Tools — buildTestTool/integrationTestTool have
      // different option sets per appType; scanTool's options are universal but the rendered
      // tooling-allowlist section only fires for code-bearing appTypes, so a stale scanTool
      // would emit into epic.json without a matching allowlist when switching to btp/infra/ami.
      next.scanTool = '';
      next.buildTestTool = '';
      next.integrationTestTool = '';
      // Deploy-target keys are per-(appType, cloudProvider); leftover values from the old
      // appType are filtered by the renderer/form but pollute state — clear them.
      next.deployTarget = emptyDeployTarget();
      // BTP forces aws cloud (BTP secrets live in AWS Secrets Manager).
      if (appType === 'btp') next.cloudProvider = 'aws';
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
      } else {
        // Sensible defaults: SPAs get frontend, server runtimes get backend.
        if (['angular', 'react', 'html'].includes(appType)) {
          next.hasFrontend = true;
          next.frontend = next.frontend ?? { authMode: 'msal', authClientId: '', apiBaseUrlNeeded: false };
          next.hasBackend = false;
          next.backend = null;
        } else if (['dotnet', 'node', 'python', 'java', 'php'].includes(appType)) {
          next.hasBackend = true;
          next.backend = next.backend ?? { style: 'rest-api', runtime: '', authStyle: 'none', authClientId: '' };
          next.hasFrontend = false;
          next.frontend = null;
        }
      }
      // Default infra=true for cloud-using apps; off for plain html sites with no backend.
      next.includeInfra = !(appType === 'html' && !next.hasBackend);
      if (appType === 'infra') next.includeInfra = true;
      return next;
    });
    this.wizardAppNameError.set(null);
  }


  protected wizardOnCloudChange(value: string): void {
    const provider = value as CloudProvider;
    this.wizardAnswers.update((a) => {
      const next: WizardAnswers = { ...a, cloudProvider: provider };
      // If the current appType is invalid under this cloud, reset (let user re-pick).
      const allowed = appTypesForCloud(provider);
      if (next.appType && !allowed.includes(next.appType as AppType)) next.appType = '';
      return next;
    });
  }

  protected wizardUpdateDeployTarget<K extends keyof DeployTarget>(key: K, value: DeployTarget[K]): void {
    this.wizardAnswers.update((a) => ({
      ...a,
      deployTarget: { ...a.deployTarget, [key]: value },
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
    const a = this.wizardAnswers();
    if (!/^[a-z][a-z0-9-]{2,40}$/.test(a.appName.trim())) {
      this.wizardAppNameError.set('App name must be kebab-case, 3–41 chars, starting with a letter.');
      return false;
    }
    const collision = this.apps().some((m) => m.name.toLowerCase() === a.appName.trim().toLowerCase());
    if (collision) {
      this.wizardAppNameError.set('An app with this name is already onboarded into EPIC.');
      return false;
    }
    if (!a.appType) {
      this.wizardAppNameError.set('App type is required.');
      return false;
    }
    this.wizardAppNameError.set(null);
    return true;
  }

  private validateWizardStep3(): boolean {
    const a = this.wizardAnswers();
    if (!a.includeInfra) return true;
    if (a.cloudProvider === 'aws' || a.appType === 'btp') {
      if (!/^\d{12}$/.test(a.awsAccountId.trim())) return false;
      if (!a.awsRegion.trim()) return false;
    }
    if (a.cloudProvider === 'azure') {
      if (!a.azureSubscriptionId.trim()) return false;
    }
    return true;
  }

  protected get canWizardNext(): boolean {
    const a = this.wizardAnswers();
    const step = this.wizardStep();
    if (step === 1) {
      return /^[a-z][a-z0-9-]{2,40}$/.test(a.appName.trim()) && !!a.appType;
    }
    if (step === 3) {
      if (!a.includeInfra) return true;
      if (a.cloudProvider === 'aws' || a.appType === 'btp') return /^\d{12}$/.test(a.awsAccountId.trim()) && !!a.awsRegion.trim();
      if (a.cloudProvider === 'azure') return !!a.azureSubscriptionId.trim();
      return true;
    }
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
    document.body.removeChild(a);
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
