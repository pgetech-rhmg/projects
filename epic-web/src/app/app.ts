import { Component, signal } from '@angular/core';
import { LowerCasePipe } from '@angular/common';
import { RouterOutlet } from '@angular/router';

interface ManagedApp {
  name: string;
  technology: string;
  lastPipelineRun: string;
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
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'billing-api',
      technology: 'Python',
      lastPipelineRun: '2026-03-19 14:15',
      cloud: 'AWS',
      environment: 'prod',
    },
    {
      name: 'outage-tracker',
      technology: 'Java',
      lastPipelineRun: '2026-03-18 09:30',
      cloud: 'Azure',
      environment: 'test',
    },
    {
      name: 'grid-dashboard',
      technology: '.NET',
      lastPipelineRun: '2026-03-17 16:55',
      cloud: 'AWS',
      environment: 'dev',
    },
    {
      name: 'field-ops-ui',
      technology: 'Angular',
      lastPipelineRun: '2026-03-15 11:20',
      cloud: 'Azure',
      environment: 'qa',
    },
    {
      name: 'meter-data-service',
      technology: 'Java',
      lastPipelineRun: '2026-03-14 07:05',
      cloud: 'AWS',
      environment: 'prod',
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
