import { Component, HostListener, OnInit, OnDestroy, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';

import { AppDetail, AppLookup, ManagedApp, PipelineRun } from './models/app.model';
import { AppService } from './services/app.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, LowerCasePipe, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit, OnDestroy {
  private readonly appService = inject(AppService);

  protected readonly title = signal('epic-web');
  protected readonly currentUser = 'Morgan, Robb';

  // ── Data ──────────────────────────────────────────────────────────────────

  protected readonly apps = signal<ManagedApp[]>([]);
  protected readonly loading = signal(false);

  // Track apps with locally-set pending state until ADO picks up the new run
  private pendingApps = new Map<string, ManagedApp>();

  private readonly refreshInterval = 5000;
  private refreshTimer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    this.appService.getApps().subscribe(data => this.apps.set(data));
    this.startAutoRefresh();
  }

  ngOnDestroy(): void {
    this.stopAutoRefresh();
    if (this.toastTimer) clearTimeout(this.toastTimer);
  }

  @HostListener('document:keydown.escape')
  protected onEscapeKey(): void {
    if (this.showHowToModal()) this.closeHowTo();
    else if (this.showNewRunModal()) this.closeNewRunModal();
    else if (this.showAddModal()) this.closeAddModal();
    else if (this.showManageModal()) this.closeManageModal();
  }

  private startAutoRefresh(): void {
    this.refreshTimer = setInterval(() => {
      // Refresh main table — preserve pending state until ADO catches up
      this.appService.getApps().subscribe({
        next: data => {
          if (this.pendingApps.size === 0) {
            this.apps.set(data);
          } else {
            this.apps.set(data.map(app => {
              const pending = this.pendingApps.get(app.name);
              if (!pending) return app;
              // ADO has caught up if the API's last run is newer than when we triggered
              if (app.lastPipelineRun && new Date(app.lastPipelineRun) > new Date(pending.lastPipelineRun!)) {
                this.pendingApps.delete(app.name);
                return app;
              }
              // Still stale — keep our pending overlay
              return { ...app, runStatus: 'Pending' as const, branch: pending.branch, environment: pending.environment, triggeredBy: pending.triggeredBy, lastPipelineRun: pending.lastPipelineRun };
            }));
          }
        },
        error: () => { /* API unavailable — keep showing last known data */ }
      });

      // Refresh modal detail if open
      if (this.showManageModal() && this.selectedApp()) {
        this.appService.getApp(this.selectedApp()!.name).subscribe({
          next: detail => this.appDetail.set(detail),
          error: () => { /* API unavailable — keep showing last known data */ }
        });
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
      (!query || app.name.toLowerCase().includes(query)) &&
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

  protected calcSuccessRate(runs: PipelineRun[]): string {
    if (runs.length === 0) return '—';
    const successful = runs.filter(r => r.status === 'Success').length;
    return (successful / runs.length * 100).toFixed(2) + '%';
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

  // ── How To modal ─────────────────────────────────────────────────────────

  protected showHowToModal = signal(false);
  protected howToAppType = 'angular';

  protected readonly epicJsonSamples: Record<string, string> = {
    angular: `{
  "app": {
    "appName": "my-angular-app",
    "appType": "angular",
    "codePath": "/",
    "nodeVersion": "20",
    "scanTool": "sonarqube",
    "unitTestTool": "jest"
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
    "codePath": "/src/MyApp",
    "dotnetVersion": "10.x",
    "scanTool": "sonarqube",
    "unitTestTool": "xunit"
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
    "pythonVersion": "3.11",
    "scanTool": "sonarqube",
    "unitTestTool": "pytest"
  },
  "cloud": {
    "awsAccountId": "123456789012",
    "awsRegion": "us-west-2"
  }
}`,
    java: `{
  "app": {
    "appName": "my-java-app",
    "appType": "java",
    "codePath": "/",
    "javaVersion": "17",
    "scanTool": "sonarqube",
    "unitTestTool": "junit"
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

  protected copySample(): void {
    navigator.clipboard.writeText(this.currentSample).then(() => {
      this.showToast('Sample epic.json copied to clipboard.');
    });
  }

  // ── Modals ────────────────────────────────────────────────────────────────

  protected showAddModal = signal(false);
  protected showManageModal = signal(false);
  protected selectedApp = signal<ManagedApp | null>(null);
  protected appDetail = signal<AppDetail | null>(null);

  // Runs pagination
  protected readonly runsPageSize = 26;
  protected runsCurrentPage = signal(1);

  protected readonly runsTotalPages = computed(() => {
    const runs = this.appDetail()?.runs ?? [];
    return Math.max(1, Math.ceil(runs.length / this.runsPageSize));
  });

  protected readonly pagedRuns = computed(() => {
    const runs = this.appDetail()?.runs ?? [];
    const page = this.runsCurrentPage();
    const start = (page - 1) * this.runsPageSize;
    return runs.slice(start, start + this.runsPageSize);
  });

  protected readonly runsPageNumbers = computed(() =>
    Array.from({ length: this.runsTotalPages() }, (_, i) => i + 1)
  );

  protected readonly runsPageRangeEnd = computed(() => {
    const runs = this.appDetail()?.runs ?? [];
    return Math.min(this.runsCurrentPage() * this.runsPageSize, runs.length);
  });

  protected goToRunsPage(page: number): void {
    this.runsCurrentPage.set(page);
  }

  // New Run modal
  protected showNewRunModal = signal(false);
  protected newRunApp = signal<AppDetail | null>(null);
  protected newRunBranch = '';
  protected newRunEnvironment = '';
  protected newRunBranchError = signal<string | null>(null);
  protected newRunEnvLocked = signal(false);
  protected newRunBuild = true;
  protected newRunTests = false;
  protected newRunScan = false;
  protected newRunDeploy = false;
  protected newRunIntegrations = false;
  protected newRunDeployInfra = 'none';

  protected newAppRepo = '';
  protected newAppBranch = '';
  protected repoCheckStatus = signal<'idle' | 'checking' | 'available' | 'in-epic-not-mine' | 'already-mine' | 'not-found'>('idle');
  protected foundMasterApp = signal<AppLookup | null>(null);

  protected onAddApp(): void {
    this.newAppRepo = '';
    this.newAppBranch = '';
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
    return (
      !!this.newAppRepo.trim() &&
      !!this.newAppBranch.trim() &&
      this.repoCheckStatus() === 'available'
    );
  }

  protected onOnboardApp(): void {
    if (!this.canOnboard) return;
    const repo = this.newAppRepo.trim();
    const branch = this.newAppBranch.trim();
    this.loading.set(true);
    this.appService.onboardApp(repo, branch).subscribe({
      next: app => {
        this.loading.set(false);
        this.apps.update(list => [app, ...list]);
        this.closeAddModal();
        this.showToast(`"${repo}" on branch "${branch}" has been onboarded into EPIC.`);
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
    this.showManageModal.set(true);
    this.appService.getApp(app.name).subscribe({
      next: detail => this.appDetail.set(detail),
      error: () => {
        this.showToast(`Failed to load details for "${app.name}".`);
        this.closeManageModal();
      }
    });
  }

  protected onNewRun(): void {
    const detail = this.appDetail();
    if (!detail) return;
    this.newRunApp.set(detail);
    this.newRunBranch = '';
    this.newRunEnvironment = 'dev';
    this.newRunBranchError.set(null);
    this.newRunEnvLocked.set(false);
    this.newRunBuild = true;
    this.newRunTests = false;
    this.newRunScan = false;
    this.newRunDeploy = false;
    this.newRunIntegrations = false;
    this.newRunDeployInfra = 'none';
    this.closeManageModal();
    this.showNewRunModal.set(true);
  }

  protected onNewRunBranchChange(): void {
    const branch = this.newRunBranch.trim().toLowerCase();
    if (branch === 'main' || branch === 'master') {
      this.newRunBranchError.set(null);
      // this.newRunBranchError.set(`"${this.newRunBranch.trim()}" is not allowed — use a feature or release branch.`);
    } else {
      this.newRunBranchError.set(null);
    }

    if (/^release\d*$/i.test(this.newRunBranch.trim())) {
      this.newRunEnvironment = 'prod';
      this.newRunEnvLocked.set(true);
    } else {
      this.newRunEnvLocked.set(false);
    }
  }

  protected get canRunNewPipeline(): boolean {
    return (
      !!this.newRunBranch.trim() &&
      !this.newRunBranchError() &&
      !!this.newRunEnvironment
    );
  }

  protected closeNewRunModal(): void {
    this.showNewRunModal.set(false);
    this.newRunApp.set(null);
  }

  protected onConfirmNewRun(): void {
    if (!this.canRunNewPipeline) return;
    const appName = this.newRunApp()?.name;
    const branch = this.newRunBranch.trim();
    const env = this.newRunEnvironment;
    if (!appName) return;
    this.loading.set(true);
    this.appService.triggerRun(appName, {
      branch,
      environment: env,
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
          ...(currentApp ?? { name: appName, technology: '', cloud: '', environment: env, successRate: null }),
          lastPipelineRun: triggeredAt,
          branch,
          environment: env,
          triggeredBy: this.currentUser,
          runStatus: 'Pending'
        });
        // Update the app row immediately with pending state
        this.apps.update(list => list.map(a =>
          a.name === appName
            ? { ...a, runStatus: 'Pending' as const, branch, environment: env, triggeredBy: this.currentUser, lastPipelineRun: triggeredAt }
            : a
        ));
        this.showToast(`Pipeline run #${result.runId} has been queued for "${appName}" on branch "${branch}" (${env}).`);
      },
      error: () => {
        this.loading.set(false);
        this.showToast(`Failed to trigger pipeline run for "${appName}".`);
      }
    });
  }

  protected onRemoveApp(): void {
    const app = this.selectedApp();
    if (!app) return;

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
