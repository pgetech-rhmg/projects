import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map, catchError, of, retry, timer } from 'rxjs';

import { AppDetail, AppLookup, ComplianceReport, ComplianceSummary, GitHubSourceOption, ManagedApp, PipelineRunPage, RepoCheckResult, StageDetail } from '../models/app.model';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AppService {
  private readonly http = inject(HttpClient);
  private readonly api = environment.apiUrl;

  /** Probe the API health endpoint. Emits true only on a 2xx response; any error
   *  (network failure, CORS, 5xx, or the 503 the API returns when its DB is unreachable)
   *  resolves to false so callers can treat the backend as offline.
   *
   *  Retries transient failures twice with backoff (1s, 2s) before giving up. A
   *  first-time / cold-start client can hit a momentary transport hiccup (slow TLS
   *  handshake, DNS warmup) on the very first call to the separate API host; without
   *  a retry that surfaces a sticky "offline" banner that only clears on a manual
   *  page refresh. The retries are cheap and only run on failure. */
  checkHealth(): Observable<boolean> {
    return this.http.get(`${this.api}/api/health`, { observe: 'response' }).pipe(
      map(res => res.ok),
      retry({ count: 2, delay: (_err, attempt) => timer(attempt * 1000) }),
      catchError(() => of(false)),
    );
  }

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

  /** List the configured GitHub sources (org + name) for the New App picker. */
  getGitHubSources(): Observable<{ sources: GitHubSourceOption[]; defaultSource: string }> {
    return this.http.get<{ sources: GitHubSourceOption[]; defaultSource: string }>(
      `${this.api}/api/apps/github-sources`
    );
  }

  /** Check if a repo can be onboarded (GitHub + EPIC DB check). */
  checkRepo(repo: string, source?: string): Observable<RepoCheckResult> {
    const params: Record<string, string> = { repo: repo.trim() };
    if (source) params['source'] = source;
    return this.http.get<RepoCheckResult>(`${this.api}/api/apps/check`, { params });
  }

  /** Add an existing EPIC app to the current user's list. */
  addToMyApps(masterApp: AppLookup): Observable<ManagedApp> {
    return this.http.post<ManagedApp>(`${this.api}/api/users/me/apps`, {
      name: masterApp.name
    });
  }

  /** Onboard a new application into EPIC. */
  onboardApp(repo: string, source?: string): Observable<ManagedApp> {
    return this.http.post<AppDetail>(`${this.api}/api/apps`, { repo, source }).pipe(
      map(detail => ({
        name: detail.name,
        appName: null,
        // Resolved server-side on the next poll from getApps; the onboard
        // response (AppDetail) doesn't carry the org.
        githubOrg: null,
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
  getConfigs(repo: string, branch: string, source?: string): Observable<{ configs: string[] }> {
    const params: Record<string, string> = { repo: repo.trim(), branch: branch.trim() };
    if (source) params['source'] = source;
    return this.http.get<{ configs: string[] }>(`${this.api}/api/apps/configs`, { params });
  }

  /** Check if a specific config has infrastructure and get its appType. */
  checkConfigInfra(repo: string, branch: string, config: string, source?: string): Observable<{ hasInfra: boolean; hasInfraParams: boolean; appType: string | null; buildTestTool: string | null; scanTool: string | null; integrationTestTool: string | null; hasRemoteBackend: boolean; expectedBackend: string; hasTfState: boolean; configuredEnvironments: string[] }> {
    const params: Record<string, string> = { repo: repo.trim(), branch: branch.trim(), config: config.trim() };
    if (source) params['source'] = source;
    return this.http.get<{ hasInfra: boolean; hasInfraParams: boolean; appType: string | null; buildTestTool: string | null; scanTool: string | null; integrationTestTool: string | null; hasRemoteBackend: boolean; expectedBackend: string; hasTfState: boolean; configuredEnvironments: string[] }>(`${this.api}/api/apps/configs/check`, { params });
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
    review: boolean;
    build: boolean;
    tests: boolean;
    scan: boolean;
    deploy: boolean;
    integrations: boolean;
    deployInfra: string;
    forceStateCopy: boolean;
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

  /** Get the SonarQube dashboard URL for a run's Scan stage (SonarQube only). */
  getScanResultUrl(appName: string, runId: number): Observable<{ url: string }> {
    return this.http.get<{ url: string }>(`${this.api}/api/apps/${appName}/runs/${runId}/scan-result-url`);
  }

  getComplianceReport(appName: string, runId: number): Observable<{ report: string }> {
    return this.http.get<{ report: string }>(`${this.api}/api/apps/${appName}/runs/${runId}/compliance-report`);
  }

  /** Get the compliance summary (version + verdict counts) for a run's Review stage. */
  getComplianceSummary(appName: string, runId: number): Observable<ComplianceSummary> {
    return this.http.get<ComplianceSummary>(`${this.api}/api/apps/${appName}/runs/${runId}/compliance-summary`);
  }

  /** Get the full structured compliance report (summary + profile + findings). */
  getComplianceReportJson(appName: string, runId: number): Observable<ComplianceReport> {
    return this.http.get<ComplianceReport>(`${this.api}/api/apps/${appName}/runs/${runId}/compliance-report-json`);
  }
}
