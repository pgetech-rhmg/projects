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

  protected onAddApp(): void {
    console.log('Add new app');
  }

  protected onEdit(app: ManagedApp): void {
    console.log('Manage:', app.name);
  }
}
