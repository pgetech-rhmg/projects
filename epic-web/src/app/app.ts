import { Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';

type RunStatus = 'Success' | 'Failed' | 'Running' | 'Cancelled';

interface ManagedApp {
  name: string;
  technology: string;
  lastPipelineRun: string;
  runStatus: RunStatus;
  triggeredBy: string;
  cloud: string;
  environment: string;
}

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, LowerCasePipe, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly title = signal('epic-web');
  protected readonly currentUser = 'Robb Morgan';

  protected initialsFor(name: string): string {
    return name === 'System'
      ? '⚙'
      : name.split(' ').map(n => n[0]).join('').toUpperCase();
  }

  protected readonly apps = signal<ManagedApp[]>([
    {
      name: 'customer-portal',
      technology: 'Angular',
      lastPipelineRun: '2026-03-20 08:42',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'billing-api',
      technology: 'Python',
      lastPipelineRun: '2026-03-20 09:15',
      runStatus: 'Running',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'outage-tracker',
      technology: 'Java',
      lastPipelineRun: '2026-03-19 14:30',
      runStatus: 'Failed',
      triggeredBy: 'Maxine Bailey',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'grid-dashboard',
      technology: '.NET',
      lastPipelineRun: '2026-03-18 16:55',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'field-ops-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-03-17 11:20',
      runStatus: 'Cancelled',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'qa',
    },
    {
      name: 'meter-data-service',
      technology: 'Java',
      lastPipelineRun: '2026-03-17 07:05',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'notifications-api',
      technology: 'Python',
      lastPipelineRun: '2026-03-16 13:40',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'asset-tracker',
      technology: '.NET',
      lastPipelineRun: '2026-03-16 10:22',
      runStatus: 'Failed',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'qa',
    },
    {
      name: 'work-order-service',
      technology: 'Java',
      lastPipelineRun: '2026-03-15 15:10',
      runStatus: 'Cancelled',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'ops-reporting-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-03-15 09:55',
      runStatus: 'Running',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'inspection-api',
      technology: 'Python',
      lastPipelineRun: '2026-03-14 16:30',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'compliance-tracker',
      technology: '.NET',
      lastPipelineRun: '2026-03-14 11:45',
      runStatus: 'Failed',
      triggeredBy: 'System',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'crew-scheduler',
      technology: 'Java',
      lastPipelineRun: '2026-03-13 14:20',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'safety-incident-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-03-13 09:10',
      runStatus: 'Cancelled',
      triggeredBy: 'Maxine Bailey',
      cloud: 'Azure',
      environment: 'dev',
    },
    {
      name: 'voltage-monitor',
      technology: 'Python',
      lastPipelineRun: '2026-03-12 17:00',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'document-vault',
      technology: '.NET',
      lastPipelineRun: '2026-03-12 13:35',
      runStatus: 'Running',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'pipeline-monitor',
      technology: 'Java',
      lastPipelineRun: '2026-03-11 10:50',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'Azure',
      environment: 'prod',
    },
    {
      name: 'energy-forecast',
      technology: 'Python',
      lastPipelineRun: '2026-03-11 08:25',
      runStatus: 'Failed',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'contractor-portal',
      technology: 'Angular',
      lastPipelineRun: '2026-03-10 15:40',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'substation-api',
      technology: 'Java',
      lastPipelineRun: '2026-03-10 11:15',
      runStatus: 'Failed',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'load-balancer-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-03-09 14:00',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'Azure',
      environment: 'prod',
    },
    {
      name: 'permit-service',
      technology: 'Python',
      lastPipelineRun: '2026-03-09 09:30',
      runStatus: 'Cancelled',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'hr-portal',
      technology: '.NET',
      lastPipelineRun: '2026-03-08 16:45',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'Azure',
      environment: 'prod',
    },
    {
      name: 'incident-router',
      technology: 'Java',
      lastPipelineRun: '2026-03-08 13:20',
      runStatus: 'Running',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'rate-calculator',
      technology: 'Python',
      lastPipelineRun: '2026-03-07 10:55',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'fleet-tracker',
      technology: 'Angular',
      lastPipelineRun: '2026-03-07 08:10',
      runStatus: 'Failed',
      triggeredBy: 'Maxine Bailey',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'transmission-api',
      technology: '.NET',
      lastPipelineRun: '2026-03-06 15:30',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'dispatch-console',
      technology: 'Java',
      lastPipelineRun: '2026-03-06 11:00',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'carbon-tracker',
      technology: 'Python',
      lastPipelineRun: '2026-03-05 17:40',
      runStatus: 'Cancelled',
      triggeredBy: 'System',
      cloud: 'Azure',
      environment: 'dev',
    },
    {
      name: 'equipment-registry',
      technology: 'Angular',
      lastPipelineRun: '2026-03-05 14:25',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'solar-monitor',
      technology: '.NET',
      lastPipelineRun: '2026-03-04 12:00',
      runStatus: 'Failed',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'audit-log-service',
      technology: 'Java',
      lastPipelineRun: '2026-03-04 09:15',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'Azure',
      environment: 'prod',
    },
    {
      name: 'customer-alerts',
      technology: 'Python',
      lastPipelineRun: '2026-03-03 16:50',
      runStatus: 'Running',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'map-renderer',
      technology: 'Angular',
      lastPipelineRun: '2026-03-03 13:35',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'billing-reconciler',
      technology: '.NET',
      lastPipelineRun: '2026-03-02 10:20',
      runStatus: 'Failed',
      triggeredBy: 'System',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'smart-meter-api',
      technology: 'Java',
      lastPipelineRun: '2026-03-02 08:00',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'demand-response',
      technology: 'Python',
      lastPipelineRun: '2026-03-01 15:10',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'vegetation-mgmt',
      technology: 'Angular',
      lastPipelineRun: '2026-03-01 11:45',
      runStatus: 'Cancelled',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'qa',
    },
    {
      name: 'field-survey-app',
      technology: '.NET',
      lastPipelineRun: '2026-02-28 14:30',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'power-flow-engine',
      technology: 'Java',
      lastPipelineRun: '2026-02-28 09:55',
      runStatus: 'Running',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'invoice-generator',
      technology: 'Python',
      lastPipelineRun: '2026-02-27 16:00',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'prod',
    },
    {
      name: 'wildfire-risk-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-02-27 12:20',
      runStatus: 'Failed',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'line-clearance-api',
      technology: '.NET',
      lastPipelineRun: '2026-02-26 10:05',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'transformer-mgmt',
      technology: 'Java',
      lastPipelineRun: '2026-02-26 08:30',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'qa',
    },
    {
      name: 'outage-predictor',
      technology: 'Python',
      lastPipelineRun: '2026-02-25 17:15',
      runStatus: 'Cancelled',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'test',
    },
    {
      name: 'supply-chain-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-02-25 14:50',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'relay-config-api',
      technology: '.NET',
      lastPipelineRun: '2026-02-24 11:30',
      runStatus: 'Failed',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'dev',
    },
    {
      name: 'hazmat-registry',
      technology: 'Java',
      lastPipelineRun: '2026-02-24 09:00',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'switch-order-svc',
      technology: 'Python',
      lastPipelineRun: '2026-02-23 15:45',
      runStatus: 'Success',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'qa',
    },
    {
      name: 'tower-inspection-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-02-23 13:00',
      runStatus: 'Running',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'project-tracker',
      technology: '.NET',
      lastPipelineRun: '2026-02-22 10:35',
      runStatus: 'Success',
      triggeredBy: 'Maxine Bailey',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'load-forecast-api',
      technology: 'Java',
      lastPipelineRun: '2026-02-22 08:15',
      runStatus: 'Failed',
      triggeredBy: 'System',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'charge-station-mgmt',
      technology: 'Python',
      lastPipelineRun: '2026-02-21 16:20',
      runStatus: 'Success',
      triggeredBy: 'Robb Morgan',
      cloud: 'Azure',
      environment: 'prod',
    },
  ]);

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

  // Unique option lists derived from data
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

  // ── Modals ────────────────────────────────────────────────────────────────

  protected showAddModal = signal(false);
  protected showManageModal = signal(false);
  protected selectedApp = signal<ManagedApp | null>(null);

  protected onAddApp(): void {
    this.showAddModal.set(true);
  }

  protected closeAddModal(): void {
    this.showAddModal.set(false);
  }

  protected onManageApp(app: ManagedApp): void {
    this.selectedApp.set(app);
    this.showManageModal.set(true);
  }

  protected closeManageModal(): void {
    this.showManageModal.set(false);
    this.selectedApp.set(null);
  }
}
