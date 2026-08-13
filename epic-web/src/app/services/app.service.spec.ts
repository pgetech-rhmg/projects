import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';

import { AppService } from './app.service';
import { environment } from '../../environments/environment';
import {
  AppDetail,
  AppLookup,
  ComplianceReport,
  ComplianceSummary,
  GitHubSourceOption,
  ManagedApp,
  PipelineRunPage,
  RepoCheckResult,
  StageDetail,
} from '../models/app.model';

describe('AppService', () => {
  let service: AppService;
  let httpMock: HttpTestingController;
  const api = environment.apiUrl;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [AppService, provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(AppService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('is created', () => {
    expect(service).toBeTruthy();
  });

  describe('checkHealth', () => {
    it('emits true on a 2xx response', () => {
      let result: boolean | undefined;
      service.checkHealth().subscribe((r) => (result = r));

      const req = httpMock.expectOne(`${api}/api/health`);
      expect(req.request.method).toBe('GET');
      req.flush({}, { status: 200, statusText: 'OK' });

      expect(result).toBe(true);
    });

    it('emits false after retries are exhausted on an error response', fakeAsync(() => {
      let result: boolean | undefined;
      service.checkHealth().subscribe((r) => (result = r));

      // Initial attempt + 2 retries, each 503; backoff is 1s then 2s.
      httpMock
        .expectOne(`${api}/api/health`)
        .flush(null, { status: 503, statusText: 'Service Unavailable' });
      tick(1000);
      httpMock
        .expectOne(`${api}/api/health`)
        .flush(null, { status: 503, statusText: 'Service Unavailable' });
      tick(2000);
      httpMock
        .expectOne(`${api}/api/health`)
        .flush(null, { status: 503, statusText: 'Service Unavailable' });

      expect(result).toBe(false);
    }));

    it('emits false after retries are exhausted on a network error', fakeAsync(() => {
      let result: boolean | undefined;
      service.checkHealth().subscribe((r) => (result = r));

      httpMock.expectOne(`${api}/api/health`).error(new ProgressEvent('network'));
      tick(1000);
      httpMock.expectOne(`${api}/api/health`).error(new ProgressEvent('network'));
      tick(2000);
      httpMock.expectOne(`${api}/api/health`).error(new ProgressEvent('network'));

      expect(result).toBe(false);
    }));

    it('recovers and emits true when a retry succeeds after a transient failure', fakeAsync(() => {
      let result: boolean | undefined;
      service.checkHealth().subscribe((r) => (result = r));

      // First attempt fails (cold-start hiccup), retry succeeds.
      httpMock.expectOne(`${api}/api/health`).error(new ProgressEvent('network'));
      tick(1000);
      httpMock.expectOne(`${api}/api/health`).flush({}, { status: 200, statusText: 'OK' });

      expect(result).toBe(true);
    }));
  });

  it('getApps GETs the current user apps', () => {
    const apps: ManagedApp[] = [];
    let result: ManagedApp[] | undefined;
    service.getApps().subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/users/me/apps`);
    expect(req.request.method).toBe('GET');
    req.flush(apps);

    expect(result).toBe(apps);
  });

  it('getApp GETs a single app detail', () => {
    const detail = { name: 'foo' } as AppDetail;
    let result: AppDetail | undefined;
    service.getApp('foo').subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo`);
    expect(req.request.method).toBe('GET');
    req.flush(detail);

    expect(result).toBe(detail);
  });

  it('getRuns GETs a paged slice with page params', () => {
    const page = { total: 0, runs: [] } as unknown as PipelineRunPage;
    let result: PipelineRunPage | undefined;
    service.getRuns('foo', 2, 20).subscribe((r) => (result = r));

    const req = httpMock.expectOne(
      (r) => r.url === `${api}/api/apps/foo/runs`,
    );
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('page')).toBe('2');
    expect(req.request.params.get('pageSize')).toBe('20');
    req.flush(page);

    expect(result).toBe(page);
  });

  it('getGitHubSources GETs the configured sources', () => {
    const payload: { sources: GitHubSourceOption[]; defaultSource: string } = {
      sources: [
        { name: 'pgetech', org: 'pgetech', isDefault: true },
        { name: 'pgedc', org: 'PGEDigitalCatalyst', isDefault: false },
      ],
      defaultSource: 'pgetech',
    };
    let result: { sources: GitHubSourceOption[]; defaultSource: string } | undefined;
    service.getGitHubSources().subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/github-sources`);
    expect(req.request.method).toBe('GET');
    req.flush(payload);

    expect(result).toBe(payload);
  });

  it('checkRepo GETs the check endpoint with a trimmed repo', () => {
    const res = { status: 'available' } as RepoCheckResult;
    let result: RepoCheckResult | undefined;
    service.checkRepo('  org/repo  ').subscribe((r) => (result = r));

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/check`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.has('source')).toBe(false);
    req.flush(res);

    expect(result).toBe(res);
  });

  it('checkRepo includes the source query param when provided', () => {
    service.checkRepo('  org/repo  ', 'pgedc').subscribe();

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/check`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.get('source')).toBe('pgedc');
    req.flush({ status: 'available' } as RepoCheckResult);
  });

  it('addToMyApps POSTs the master app name', () => {
    const master = { name: 'foo' } as AppLookup;
    const managed = { name: 'foo' } as ManagedApp;
    let result: ManagedApp | undefined;
    service.addToMyApps(master).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/users/me/apps`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ name: 'foo' });
    req.flush(managed);

    expect(result).toBe(managed);
  });

  it('onboardApp POSTs the repo and maps the detail to a ManagedApp', () => {
    let result: ManagedApp | undefined;
    service.onboardApp('org/repo').subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ repo: 'org/repo', source: undefined });
    // No source arg → the body carries an undefined source (dropped on the wire).
    expect(req.request.body.source).toBeUndefined();
    req.flush({
      name: 'org/repo',
      technology: 'Angular',
      cloud: 'AWS',
      environment: 'dev',
    } as AppDetail);

    expect(result).toEqual({
      name: 'org/repo',
      appName: null,
      githubOrg: null,
      technology: 'Angular',
      cloud: 'AWS',
      environment: 'dev',
      lastPipelineRun: null,
      branch: null,
      runId: null,
      runStatus: null,
      triggeredBy: null,
      successRate: null,
      avgDuration: null,
    });
  });

  it('onboardApp includes the source in the POST body when provided', () => {
    service.onboardApp('org/repo', 'pgedc').subscribe();

    const req = httpMock.expectOne(`${api}/api/apps`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ repo: 'org/repo', source: 'pgedc' });
    req.flush({ name: 'org/repo', technology: 'Angular', cloud: 'AWS', environment: 'dev' } as AppDetail);
  });

  it('getConfigs GETs configs with trimmed repo and branch', () => {
    let result: { configs: string[] } | undefined;
    service.getConfigs('  org/repo ', ' main ').subscribe((r) => (result = r));

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/configs`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.get('branch')).toBe('main');
    expect(req.request.params.has('source')).toBe(false);
    req.flush({ configs: ['.pipeline/epic.json'] });

    expect(result).toEqual({ configs: ['.pipeline/epic.json'] });
  });

  it('getConfigs includes the source query param when provided', () => {
    service.getConfigs('  org/repo ', ' main ', 'pgedc').subscribe();

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/configs`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.get('branch')).toBe('main');
    expect(req.request.params.get('source')).toBe('pgedc');
    req.flush({ configs: [] });
  });

  it('checkConfigInfra GETs the config check with trimmed params', () => {
    let result: unknown;
    service
      .checkConfigInfra('  org/repo ', ' main ', ' .pipeline/epic.json ')
      .subscribe((r) => (result = r));

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/configs/check`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.get('branch')).toBe('main');
    expect(req.request.params.get('config')).toBe('.pipeline/epic.json');
    expect(req.request.params.has('source')).toBe(false);
    const payload = {
      hasInfra: true,
      hasInfraParams: false,
      appType: 'angular',
      buildTestTool: null,
      scanTool: 'sonarqube',
      integrationTestTool: null,
      hasRemoteBackend: true,
      expectedBackend: 's3',
      hasTfState: false,
      configuredEnvironments: ['dev', 'qa', 'uat', 'prod'],
    };
    req.flush(payload);

    expect(result).toEqual(payload);
  });

  it('checkConfigInfra includes the source query param when provided', () => {
    service
      .checkConfigInfra('  org/repo ', ' main ', ' .pipeline/epic.json ', 'pgedc')
      .subscribe();

    const req = httpMock.expectOne((r) => r.url === `${api}/api/apps/configs/check`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('repo')).toBe('org/repo');
    expect(req.request.params.get('branch')).toBe('main');
    expect(req.request.params.get('config')).toBe('.pipeline/epic.json');
    expect(req.request.params.get('source')).toBe('pgedc');
    req.flush({
      hasInfra: false,
      hasInfraParams: false,
      appType: null,
      buildTestTool: null,
      scanTool: null,
      integrationTestTool: null,
      hasRemoteBackend: false,
      expectedBackend: 'azurerm',
      hasTfState: false,
      configuredEnvironments: [],
    });
  });

  it('removeFromMyApps DELETEs the app', () => {
    let done = false;
    service.removeFromMyApps('foo').subscribe(() => (done = true));

    const req = httpMock.expectOne(`${api}/api/users/me/apps/foo`);
    expect(req.request.method).toBe('DELETE');
    req.flush(null);

    expect(done).toBe(true);
  });

  it('triggerRun POSTs the run params', () => {
    const params = {
      branch: 'main',
      environment: 'dev',
      config: '.pipeline/epic.json',
      review: true,
      build: true,
      tests: false,
      scan: false,
      deploy: false,
      integrations: false,
      deployInfra: 'none',
      forceStateCopy: true,
    };
    let result: { runId: number; url: string } | undefined;
    service.triggerRun('foo', params).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual(params);
    req.flush({ runId: 42, url: 'https://ado/42' });

    expect(result).toEqual({ runId: 42, url: 'https://ado/42' });
  });

  it('cancelRun POSTs to the cancel endpoint', () => {
    let done = false;
    service.cancelRun('foo', 42).subscribe(() => (done = true));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/cancel`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({});
    req.flush(null);

    expect(done).toBe(true);
  });

  it('getStageDetail GETs the stage detail', () => {
    const detail = { stageName: 'build' } as StageDetail;
    let result: StageDetail | undefined;
    service.getStageDetail('foo', 42, 'build').subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/stages/build`);
    expect(req.request.method).toBe('GET');
    req.flush(detail);

    expect(result).toBe(detail);
  });

  it('getStepLog GETs the raw log', () => {
    let result: { log: string } | undefined;
    service.getStepLog('foo', 42, 7).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/logs/7`);
    expect(req.request.method).toBe('GET');
    req.flush({ log: 'hello' });

    expect(result).toEqual({ log: 'hello' });
  });

  it('getScanResultUrl GETs the SonarQube dashboard URL', () => {
    let result: { url: string } | undefined;
    service.getScanResultUrl('foo', 42).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/scan-result-url`);
    expect(req.request.method).toBe('GET');
    req.flush({ url: 'https://sonarqube/dashboard?id=foo' });

    expect(result).toEqual({ url: 'https://sonarqube/dashboard?id=foo' });
  });

  it('getComplianceReport GETs the markdown report', () => {
    let result: { report: string } | undefined;
    service.getComplianceReport('foo', 42).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/compliance-report`);
    expect(req.request.method).toBe('GET');
    req.flush({ report: '# report' });

    expect(result).toEqual({ report: '# report' });
  });

  it('getComplianceSummary GETs the summary', () => {
    const summary = { total: 0, byVerdict: {} } as unknown as ComplianceSummary;
    let result: ComplianceSummary | undefined;
    service.getComplianceSummary('foo', 42).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/compliance-summary`);
    expect(req.request.method).toBe('GET');
    req.flush(summary);

    expect(result).toBe(summary);
  });

  it('getComplianceReportJson GETs the structured report', () => {
    const report = { findings: [] } as unknown as ComplianceReport;
    let result: ComplianceReport | undefined;
    service.getComplianceReportJson('foo', 42).subscribe((r) => (result = r));

    const req = httpMock.expectOne(`${api}/api/apps/foo/runs/42/compliance-report-json`);
    expect(req.request.method).toBe('GET');
    req.flush(report);

    expect(result).toBe(report);
  });
});
