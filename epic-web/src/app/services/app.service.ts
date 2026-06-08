import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';

import { AppDetail, AppLookup, ManagedApp, PipelineRun, PipelineRunPage, RepoCheckResult, StageDetail } from '../models/app.model';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AppService {
  private readonly http = inject(HttpClient);
  private readonly api = environment.apiUrl;

  /** Get apps tracked by the current user. */
  getApps(): Observable<ManagedApp[]> {
    return this.http.get<ManagedApp[]>(`${this.api}/api/users/me/apps`);
  }

  /** Get full app detail (metadata only — runs are paged separately). */
  getApp(name: string): Observable<AppDetail> {
    return this.http.get<AppDetail>(`${this.api}/api/apps/${name}`);
  }

  /** Get a paged slice of pipeline runs for an app, plus the total count. */
  getRuns(name: string, page: number, pageSize: number): Observable<PipelineRunPage> {
    return this.http.get<PipelineRunPage>(`${this.api}/api/apps/${name}/runs`, {
      params: { page: page.toString(), pageSize: pageSize.toString() }
    });
  }

  /** Check if a repo can be onboarded (GitHub + EPIC DB check). */
  checkRepo(repo: string): Observable<RepoCheckResult> {
    return this.http.get<RepoCheckResult>(`${this.api}/api/apps/check`, {
      params: { repo: repo.trim() }
    });
  }

  /** Add an existing EPIC app to the current user's list. */
  addToMyApps(masterApp: AppLookup): Observable<ManagedApp> {
    return this.http.post<ManagedApp>(`${this.api}/api/users/me/apps`, {
      name: masterApp.name
    });
  }

  /** Onboard a new application into EPIC. */
  onboardApp(repo: string): Observable<ManagedApp> {
    return this.http.post<AppDetail>(`${this.api}/api/apps`, { repo }).pipe(
      map(detail => ({
        name: detail.name,
        appName: null,
        technology: detail.technology,
        cloud: detail.cloud,
        environment: detail.environment,
        lastPipelineRun: null,
        branch: null,
        runId: null,
        runStatus: null,
        triggeredBy: null,
        successRate: null,
        avgDuration: null
      }))
    );
  }

  /** Find all epic.json config files in a repo/branch. */
  getConfigs(repo: string, branch: string): Observable<{ configs: string[] }> {
    return this.http.get<{ configs: string[] }>(`${this.api}/api/apps/configs`, {
      params: { repo: repo.trim(), branch: branch.trim() }
    });
  }

  /** Check if a specific config has infrastructure and get its appType. */
  checkConfigInfra(repo: string, branch: string, config: string): Observable<{ hasInfra: boolean; hasInfraParams: boolean; appType: string | null }> {
    return this.http.get<{ hasInfra: boolean; hasInfraParams: boolean; appType: string | null }>(`${this.api}/api/apps/configs/check`, {
      params: { repo: repo.trim(), branch: branch.trim(), config: config.trim() }
    });
  }

  /** Remove an app from the current user's tracked list. */
  removeFromMyApps(name: string): Observable<void> {
    return this.http.delete<void>(`${this.api}/api/users/me/apps/${name}`);
  }

  /** Trigger a new pipeline run. */
  triggerRun(appName: string, params: {
    branch: string;
    environment: string;
    config: string;
    build: boolean;
    tests: boolean;
    scan: boolean;
    deploy: boolean;
    integrations: boolean;
    deployInfra: string;
  }): Observable<{ runId: number; url: string }> {
    return this.http.post<{ runId: number; url: string }>(`${this.api}/api/apps/${appName}/runs`, params);
  }

  /** Cancel a running pipeline build. */
  cancelRun(appName: string, runId: number): Observable<void> {
    return this.http.post<void>(`${this.api}/api/apps/${appName}/runs/${runId}/cancel`, {});
  }

  /** Get job/step detail for a specific stage of a pipeline run. */
  getStageDetail(appName: string, runId: number, stageName: string): Observable<StageDetail> {
    return this.http.get<StageDetail>(`${this.api}/api/apps/${appName}/runs/${runId}/stages/${stageName}`);
  }

  /** Get the raw log text for a specific step of a pipeline run. */
  getStepLog(appName: string, runId: number, logId: number): Observable<{ log: string }> {
    return this.http.get<{ log: string }>(`${this.api}/api/apps/${appName}/runs/${runId}/logs/${logId}`);
  }
}
