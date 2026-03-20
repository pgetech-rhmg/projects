import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';

import { AppDetail, ManagedApp } from './models/app.model';
import { AppService } from './services/app.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, LowerCasePipe, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit {
  private readonly appService = inject(AppService);

  protected readonly title = signal('epic-web');
  protected readonly currentUser = 'Robb Morgan';

  // ── Data ──────────────────────────────────────────────────────────────────

  protected readonly apps = signal<ManagedApp[]>([]);

  ngOnInit(): void {
    this.appService.getApps().subscribe(data => this.apps.set(data));
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
    );
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

  protected initialsFor(name: string): string {
    return name === 'System'
      ? '⚙'
      : name.split(' ').map(n => n[0]).join('').toUpperCase();
  }

  // ── Modals ────────────────────────────────────────────────────────────────

  protected showAddModal = signal(false);
  protected showManageModal = signal(false);
  protected selectedApp = signal<ManagedApp | null>(null);
  protected appDetail = signal<AppDetail | null>(null);

  protected onAddApp(): void {
    this.showAddModal.set(true);
  }

  protected closeAddModal(): void {
    this.showAddModal.set(false);
  }

  protected onManageApp(app: ManagedApp): void {
    this.selectedApp.set(app);
    this.appDetail.set(null);
    this.showManageModal.set(true);
    this.appService.getApp(app.name).subscribe(detail => this.appDetail.set(detail));
  }

  protected closeManageModal(): void {
    this.showManageModal.set(false);
    this.selectedApp.set(null);
    this.appDetail.set(null);
  }

  // ── Toast ─────────────────────────────────────────────────────────────────

  protected toastMessage = signal<string | null>(null);
  private toastTimer: ReturnType<typeof setTimeout> | null = null;

  protected onRunClick(runId: number): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastMessage.set(`Run #${runId} — this will navigate to the ADO pipeline run once the integration is wired up.`);
    this.toastTimer = setTimeout(() => this.toastMessage.set(null), 4000);
  }

  protected dismissToast(): void {
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastMessage.set(null);
  }
}
