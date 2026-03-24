import { Component, OnInit, OnDestroy, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';

import { AppDetail, AppLookup, ManagedApp } from './models/app.model';
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

  private readonly refreshInterval = 5000;
  private refreshTimer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    this.appService.getApps().subscribe(data => this.apps.set(data));
    this.startAutoRefresh();
  }

  ngOnDestroy(): void {
    this.stopAutoRefresh();
  }

  private startAutoRefresh(): void {
    this.refreshTimer = setInterval(() => {
      // Refresh main table
      this.appService.getApps().subscribe(data => this.apps.set(data));

      // Refresh modal detail if open
      if (this.showManageModal() && this.selectedApp()) {
        this.appService.getApp(this.selectedApp()!.name).subscribe({
          next: detail => this.appDetail.set(detail)
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

  // ── Modals ────────────────────────────────────────────────────────────────

  protected showAddModal = signal(false);
  protected showManageModal = signal(false);
  protected selectedApp = signal<ManagedApp | null>(null);
  protected appDetail = signal<AppDetail | null>(null);

  // New Run modal
  protected showNewRunModal = signal(false);
  protected newRunApp = signal<AppDetail | null>(null);
  protected newRunBranch = '';
  protected newRunEnvironment = '';
  protected newRunBranchError = signal<string | null>(null);
  protected newRunEnvLocked = signal(false);

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
    this.appService.onboardApp(repo, branch).subscribe({
      next: app => {
        this.apps.update(list => [app, ...list]);
        this.closeAddModal();
        this.showToast(`"${repo}" on branch "${branch}" has been onboarded into EPIC.`);
      },
      error: () => this.showToast(`Failed to onboard "${repo}" — please try again.`)
    });
  }

  protected onAddToMyList(): void {
    const masterApp = this.foundMasterApp();
    if (!masterApp) return;
    this.appService.addToMyApps(masterApp).subscribe({
      next: app => {
        this.apps.update(list => [app, ...list]);
        this.closeAddModal();
        this.showToast(`"${masterApp.displayName}" has been added to your list.`);
      },
      error: () => this.showToast(`Failed to add "${masterApp.displayName}" — please try again.`)
    });
  }

  protected onManageApp(app: ManagedApp): void {
    this.selectedApp.set(app);
    this.appDetail.set(null);
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
    this.closeManageModal();
    this.showNewRunModal.set(true);
  }

  protected onNewRunBranchChange(): void {
    const branch = this.newRunBranch.trim().toLowerCase();
    if (branch === 'main' || branch === 'master') {
      this.newRunBranchError.set(`"${this.newRunBranch.trim()}" is not allowed — use a feature or release branch.`);
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
    const displayName = this.newRunApp()?.displayName;
    const branch = this.newRunBranch.trim();
    const env = this.newRunEnvironment;
    if (!appName) return;
    this.appService.triggerRun(appName, branch, env).subscribe({
      next: () => {
        this.closeNewRunModal();
        this.showToast(`A new pipeline run for "${displayName}" on branch "${branch}" for the "${env}" environment has been queued.`);
      },
      error: () => {
        this.closeNewRunModal();
        this.showToast(`Failed to trigger pipeline run for "${displayName}" — the feature is not yet available.`);
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
