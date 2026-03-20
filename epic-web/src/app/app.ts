import { Component, signal } from '@angular/core';
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
  imports: [RouterOutlet, LowerCasePipe],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly title = signal('epic-web');

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
      triggeredBy: 'Sara Patel',
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
      triggeredBy: 'Sara Patel',
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
      triggeredBy: 'Sara Patel',
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
  ]);

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
