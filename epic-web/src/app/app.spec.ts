import { ComponentFixture, TestBed, fakeAsync, flushMicrotasks, tick } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { MSAL_INSTANCE, MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { InteractionStatus } from '@azure/msal-browser';
import { Subject, of, throwError } from 'rxjs';

import { App } from './app';
import { AppService } from './services/app.service';
import {
  AppDetail,
  AppLookup,
  ComplianceReport,
  ComplianceSummary,
  GitHubSourceOption,
  ManagedApp,
  PipelineRun,
  PipelineRunPage,
  RunStatus,
  StageDetail,
} from './models/app.model';

// ── Test data factories ──────────────────────────────────────────────────────

function makeApp(overrides: Partial<ManagedApp> = {}): ManagedApp {
  return {
    name: 'my-app',
    appName: 'My App',
    githubOrg: null,
    technology: 'Angular',
    cloud: 'AWS',
    environment: 'dev',
    lastPipelineRun: '2026-07-01T00:00:00Z',
    branch: 'main',
    runId: 100,
    runStatus: 'Success',
    triggeredBy: 'Morgan, Robb',
    successRate: 100,
    avgDuration: '5m',
    ...overrides,
  };
}

function makeDetail(overrides: Partial<AppDetail> = {}): AppDetail {
  return {
    name: 'my-app',
    displayName: 'My App',
    description: 'desc',
    appType: 'angular',
    technology: 'Angular',
    cloud: 'AWS',
    environment: 'dev',
    team: 'team',
    lastUpdatedBy: 'rhmg',
    domain: 'domain',
    github: { repo: 'org/my-app', branch: 'main' },
    hasInfra: true,
    successRate: 100,
    avgDuration: '5m',
    ...overrides,
  };
}

function makeRun(overrides: Partial<PipelineRun> = {}): PipelineRun {
  return {
    id: 200,
    orchestratorId: 199,
    status: 'Success',
    triggeredBy: 'Morgan, Robb',
    branch: 'main',
    cloud: 'AWS',
    environment: 'dev',
    appName: 'My App',
    startedAt: '2026-07-01T00:00:00Z',
    duration: '5m',
    stages: {
      prepare: 'Success',
      download: 'Success',
      review: 'Success',
      build: 'Success',
      test: 'Skipped',
      scan: 'Skipped',
      infraDeploy: 'Success',
      appDeploy: 'Success',
      integrationTest: 'Skipped',
    },
    ...overrides,
  };
}

function makePage(runs: PipelineRun[], total = runs.length): PipelineRunPage {
  return { total, page: 1, pageSize: 20, runs };
}

const INFRA_RESULT = {
  hasInfra: true,
  hasInfraParams: true,
  appType: 'angular',
  buildTestTool: 'jest',
  scanTool: 'sonarqube',
  integrationTestTool: 'playwright',
  hasS3Backend: true,
  hasTfState: false,
};

function makeComplianceSummary(overrides: Partial<ComplianceSummary> = {}): ComplianceSummary {
  return {
    tool: 'epic-compliance',
    version: 'v1.1.3',
    specSource: 'APP.md',
    scannedAt: '2026-07-13T00:00:00Z',
    total: 5,
    byVerdict: { FAIL: 0, PARTIAL: 2, PASS: 1, MANUAL: 1, 'N/A': 1 },
    ...overrides,
  };
}

const GITHUB_SOURCES: GitHubSourceOption[] = [
  { name: 'pgetech', org: 'pgetech', isDefault: true },
  { name: 'pgedc', org: 'PGEDigitalCatalyst', isDefault: false },
];

// ── MSAL stubs ────────────────────────────────────────────────────────────────

class StubMsalService {
  activeAccount: unknown = null;
  accounts: unknown[] = [];
  instance = {
    getActiveAccount: () => this.activeAccount,
    getAllAccounts: () => this.accounts,
    setActiveAccount: (a: unknown) => (this.activeAccount = a),
    initialize: () => Promise.resolve(),
  };
  redirect$ = new Subject<unknown>();
  handleRedirectObservable = jasmine.createSpy('handleRedirectObservable').and.callFake(() => this.redirect$);
  acquireTokenSilent = jasmine
    .createSpy('acquireTokenSilent')
    .and.returnValue(of({ accessToken: 'token' }));
  loginRedirect = jasmine.createSpy('loginRedirect').and.returnValue(Promise.resolve());
}

class StubMsalBroadcastService {
  inProgress$ = new Subject<InteractionStatus>();
}

// ── Suite ──────────────────────────────────────────────────────────────────────

describe('App', () => {
  let appService: jasmine.SpyObj<AppService>;
  let msal: StubMsalService;
  let broadcast: StubMsalBroadcastService;

  function configure() {
    appService = jasmine.createSpyObj<AppService>('AppService', {
      checkHealth: of(true),
      getApps: of([]),
      getApp: of(makeDetail()),
      getRuns: of(makePage([])),
      getGitHubSources: of({ sources: [], defaultSource: '' }),
      checkRepo: of({ status: 'available' }),
      addToMyApps: of(makeApp()),
      onboardApp: of(makeApp()),
      getConfigs: of({ configs: [] }),
      checkConfigInfra: of(INFRA_RESULT),
      removeFromMyApps: of(void 0),
      triggerRun: of({ runId: 555, url: 'https://ado/555' }),
      cancelRun: of(void 0),
      getStageDetail: of({ stageName: 'build', status: 'Success', duration: '1m', jobs: [] } as StageDetail),
      getStepLog: of({ log: 'log text' }),
      getScanResultUrl: of({ url: 'https://sonarqube.nonprod.pge.com/dashboard?id=epic-web&branch=main' }),
      getComplianceReport: of({ report: '# report' }),
      getComplianceSummary: of(makeComplianceSummary()),
      getComplianceReportJson: of({ summary: makeComplianceSummary(), profile: null, findings: [] } as ComplianceReport),
    });

    TestBed.configureTestingModule({
      imports: [App],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: AppService, useValue: appService },
        { provide: MSAL_INSTANCE, useValue: {} },
        { provide: MsalService, useClass: StubMsalService },
        { provide: MsalBroadcastService, useClass: StubMsalBroadcastService },
      ],
    });
    msal = TestBed.inject(MsalService) as unknown as StubMsalService;
    broadcast = TestBed.inject(MsalBroadcastService) as unknown as StubMsalBroadcastService;
  }

  /** Instantiate the component WITHOUT running the template or ngOnInit. */
  function make(): App {
    configure();
    return TestBed.createComponent(App).componentInstance;
  }

  // Access protected/private members in tests without fighting TS visibility.
  function asAny(c: App): any {
    return c as any;
  }

  beforeEach(() => {
    jasmine.clock().uninstall();
  });

  it('creates', () => {
    expect(make()).toBeTruthy();
  });

  it('renders the EPIC title', () => {
    configure();
    const fixture: ComponentFixture<App> = TestBed.createComponent(App);
    fixture.detectChanges();
    const el = fixture.nativeElement as HTMLElement;
    expect(el.querySelector('h1')?.textContent).toContain('EPIC');
  });

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  describe('ngOnInit / auth flow', () => {
    it('logs in when no account is present', () => {
      const c = make();
      c.ngOnInit();
      broadcast.inProgress$.next(InteractionStatus.None);
      expect(msal.loginRedirect).toHaveBeenCalled();
    });

    it('sets the denied state when the redirect errors', () => {
      const c = make();
      c.ngOnInit();
      msal.redirect$.error(new Error('redirect failed'));
      expect(asAny(c).authState()).toBe('denied');
    });

    it('authenticates, loads apps and starts refresh when an account exists', fakeAsync(() => {
      const c = make();
      msal.accounts = [{ name: 'Morgan, Robb' }];
      appService.getApps.and.returnValue(of([makeApp()]));
      c.ngOnInit();
      broadcast.inProgress$.next(InteractionStatus.None);
      flushMicrotasks();
      expect(asAny(c).authState()).toBe('authenticated');
      expect(asAny(c).currentUser()).toBe('Morgan, Robb');
      expect(asAny(c).apps().length).toBe(1);
      expect(asAny(c).backendOnline()).toBe(true);
      c.ngOnDestroy();
    }));

    it('marks the backend offline and stops loading when health check fails', () => {
      const c = make();
      msal.accounts = [{ name: 'Morgan, Robb' }];
      appService.checkHealth.and.returnValue(of(false));
      c.ngOnInit();
      broadcast.inProgress$.next(InteractionStatus.None);
      expect(asAny(c).backendOnline()).toBe(false);
      expect(asAny(c).dataLoading()).toBe(false);
    });

    it('handles a getApps error during startup without throwing', () => {
      const c = make();
      msal.accounts = [{ name: 'X' }];
      appService.getApps.and.returnValue(throwError(() => new Error('boom')));
      c.ngOnInit();
      broadcast.inProgress$.next(InteractionStatus.None);
      expect(asAny(c).dataLoading()).toBe(false);
    });

    it('uses "Unknown" when the account has no name', () => {
      const c = make();
      msal.accounts = [{}];
      c.ngOnInit();
      broadcast.inProgress$.next(InteractionStatus.None);
      expect(asAny(c).currentUser()).toBe('Unknown');
    });
  });

  describe('onEscapeKey', () => {
    it('closes whichever modal is open, honoring precedence', () => {
      const c = make();
      const a = asAny(c);
      a.showReportModal.set(true);
      c['onEscapeKey']();
      expect(a.showReportModal()).toBe(false);

      a.showManageModal.set(true);
      c['onEscapeKey']();
      expect(a.showManageModal()).toBe(false);
    });

    it('closes the builder modal (which returns to how-to)', () => {
      const c = make();
      const a = asAny(c);
      a.showBuilderModal.set(true);
      c['onEscapeKey']();
      expect(a.showBuilderModal()).toBe(false);
    });

    it('closes the how-to modal via escape', () => {
      const a = asAny(make());
      a.showHowToModal.set(true);
      a.onEscapeKey();
      expect(a.showHowToModal()).toBe(false);
    });

    it('closes the new-run modal via escape (returns to manage)', () => {
      const a = asAny(make());
      a.showNewRunModal.set(true);
      a.onEscapeKey();
      expect(a.showNewRunModal()).toBe(false);
    });

    it('closes the add modal via escape', () => {
      const a = asAny(make());
      a.showAddModal.set(true);
      a.onEscapeKey();
      expect(a.showAddModal()).toBe(false);
    });

    it('closes the create-app wizard via escape', () => {
      const a = asAny(make());
      a.showCreateAppWizard.set(true);
      a.onEscapeKey();
      expect(a.showCreateAppWizard()).toBe(false);
    });
  });

  describe('auto-refresh reconciliation', () => {
    it('reconcileApps overlays cancelling and pending state', () => {
      const c = make();
      const a = asAny(c);
      a.cancelledRuns.add(100);
      a.reconcileApps([makeApp({ runId: 100, runStatus: 'Running' })]);
      expect(a.apps()[0].runStatus).toBe('Canceling');
    });

    it('reconcileApps passes through an app not being cancelled', () => {
      const c = make();
      const a = asAny(c);
      // runId not in cancelledRuns → applyCancelOverride returns the app untouched.
      a.reconcileApps([makeApp({ runId: 100, runStatus: 'Success' })]);
      expect(a.apps()[0].runStatus).toBe('Success');
    });

    it('reconcileApps maps through the pending-overlay path when a pending app exists', () => {
      const c = make();
      const a = asAny(c);
      a.pendingApps.set('my-app', makeApp({ lastPipelineRun: '2026-07-20T00:00:00Z', runStatus: 'Pending' }));
      // size > 0 → data.map(applyPendingOverride) branch.
      a.reconcileApps([makeApp({ name: 'my-app', lastPipelineRun: '2026-07-01T00:00:00Z' })]);
      expect(a.apps()[0].runStatus).toBe('Pending');
    });

    it('reconcileApps clears a cancelled run once ADO reports Canceled', () => {
      const c = make();
      const a = asAny(c);
      a.cancelledRuns.add(100);
      a.reconcileApps([makeApp({ runId: 100, runStatus: 'Canceled' })]);
      expect(a.cancelledRuns.has(100)).toBe(false);
      expect(a.apps()[0].runStatus).toBe('Canceled');
    });

    it('applyPendingOverride keeps the pending overlay until a newer run arrives', () => {
      const c = make();
      const a = asAny(c);
      a.pendingApps.set('my-app', makeApp({ lastPipelineRun: '2026-07-05T00:00:00Z', runStatus: 'Pending' }));
      const merged = a.applyPendingOverride(makeApp({ lastPipelineRun: '2026-07-01T00:00:00Z' }));
      expect(merged.runStatus).toBe('Pending');
    });

    it('applyPendingOverride drops the overlay when the API run is newer', () => {
      const c = make();
      const a = asAny(c);
      a.pendingApps.set('my-app', makeApp({ lastPipelineRun: '2026-07-01T00:00:00Z' }));
      const merged = a.applyPendingOverride(makeApp({ lastPipelineRun: '2026-07-10T00:00:00Z' }));
      expect(a.pendingApps.has('my-app')).toBe(false);
      expect(merged.runStatus).toBe('Success');
    });

    it('applyPendingOverride passes through apps with no pending entry', () => {
      const c = make();
      const app = makeApp();
      expect(asAny(c).applyPendingOverride(app)).toBe(app);
    });

    it('startAutoRefresh polls getApps and refreshes an open manage modal', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.showManageModal.set(true);
      appService.getRuns.and.returnValue(of(makePage([makeRun()])));
      a.startAutoRefresh();
      tick(5000);
      expect(appService.getApps).toHaveBeenCalled();
      expect(appService.getApp).toHaveBeenCalled();
      a.stopAutoRefresh();
      flushMicrotasks();
    }));

    it('refresh reconciles pending runs and cancelling status in the runs table', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.showManageModal.set(true);
      a.cancelledRuns.add(200);
      a.pendingRuns.set(999, { run: makeRun({ id: 999 }), appName: 'my-app' });
      appService.getRuns.and.returnValue(of(makePage([makeRun({ id: 200, status: 'Running' })])));
      a.startAutoRefresh();
      tick(5000);
      expect(a.pagedRuns().some((r: PipelineRun) => r.status === 'Canceling')).toBe(true);
      a.stopAutoRefresh();
      flushMicrotasks();
    }));

    it('refresh clears a cancelled run from the table once ADO reports Canceled', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.showManageModal.set(true);
      a.cancelledRuns.add(200);
      appService.getRuns.and.returnValue(of(makePage([makeRun({ id: 200, status: 'Canceled' })])));
      a.startAutoRefresh();
      tick(5000);
      expect(a.cancelledRuns.has(200)).toBe(false);
      expect(a.pagedRuns()[0].status).toBe('Canceled');
      a.stopAutoRefresh();
      flushMicrotasks();
    }));

    it('refresh also re-fetches expanded stage detail and step log', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.showManageModal.set(true);
      a.expandedStage.set({ runId: 200, stageName: 'build' });
      a.expandedLogId.set(7);
      a.startAutoRefresh();
      tick(5000);
      expect(appService.getStageDetail).toHaveBeenCalled();
      expect(appService.getStepLog).toHaveBeenCalled();
      a.stopAutoRefresh();
      flushMicrotasks();
    }));

    it('refresh survives errors from every backend call', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.showManageModal.set(true);
      a.expandedStage.set({ runId: 200, stageName: 'build' });
      a.expandedLogId.set(7);
      appService.getApps.and.returnValue(throwError(() => new Error('x')));
      appService.getApp.and.returnValue(throwError(() => new Error('x')));
      appService.getRuns.and.returnValue(throwError(() => new Error('x')));
      appService.getStageDetail.and.returnValue(throwError(() => new Error('x')));
      appService.getStepLog.and.returnValue(throwError(() => new Error('x')));
      a.startAutoRefresh();
      expect(() => tick(5000)).not.toThrow();
      a.stopAutoRefresh();
      flushMicrotasks();
    }));
  });

  // ── Filters ──────────────────────────────────────────────────────────────────

  describe('filters', () => {
    function withApps(): App {
      const c = make();
      asAny(c).apps.set([
        makeApp({ name: 'alpha', technology: 'Angular', cloud: 'AWS', environment: 'dev', runStatus: 'Success', triggeredBy: 'A' }),
        makeApp({ name: 'beta', appName: 'Beta App', technology: 'React', cloud: 'Azure', environment: 'prod', runStatus: 'Failed', triggeredBy: null }),
      ]);
      return c;
    }

    it('filteredApps matches by repo name and app name, sorted', () => {
      const c = withApps();
      const a = asAny(c);
      a.searchQuery.set('beta');
      expect(a.filteredApps().map((x: ManagedApp) => x.name)).toEqual(['beta']);
      a.searchQuery.set('Beta App');
      expect(a.filteredApps().length).toBe(1);
    });

    it('filteredApps handles apps with a null appName under a query', () => {
      const c = make();
      asAny(c).apps.set([makeApp({ name: 'gamma', appName: null })]);
      asAny(c).searchQuery.set('zzz'); // no match → appName?.… ?? false false-branch
      expect(asAny(c).filteredApps().length).toBe(0);
      asAny(c).searchQuery.set('gamma');
      expect(asAny(c).filteredApps().length).toBe(1);
    });

    it('filteredApps applies each filter dimension', () => {
      const c = withApps();
      const a = asAny(c);
      a.filterTechnology.set('React');
      expect(a.filteredApps().length).toBe(1);
      a.filterTechnology.set('');
      a.filterCloud.set('AWS');
      expect(a.filteredApps()[0].name).toBe('alpha');
      a.filterCloud.set('');
      a.filterEnvironment.set('prod');
      expect(a.filteredApps()[0].name).toBe('beta');
      a.filterEnvironment.set('');
      a.filterRunStatus.set('Failed');
      expect(a.filteredApps()[0].name).toBe('beta');
      a.filterRunStatus.set('');
      a.filterTriggeredBy.set('System');
      expect(a.filteredApps()[0].name).toBe('beta');
    });

    it('computes filter option lists', () => {
      const c = withApps();
      const a = asAny(c);
      expect(a.techOptions()).toEqual(['Angular', 'React']);
      expect(a.cloudOptions()).toEqual(['AWS', 'Azure']);
      expect(a.envOptions()).toEqual(['dev', 'prod']);
      expect(a.statusOptions()).toContain('Failed');
      expect(a.triggeredByOptions()).toContain('System');
    });

    it('statusOptions sorts even when statuses are null', () => {
      const c = make();
      // Several distinct statuses plus null so the comparator is invoked with null
      // on both sides of (a ?? '') / (b ?? '').
      asAny(c).apps.set([
        makeApp({ name: 'a', runStatus: 'Success' }),
        makeApp({ name: 'b', runStatus: null }),
        makeApp({ name: 'c', runStatus: 'Failed' }),
        makeApp({ name: 'd', runStatus: 'Running' }),
      ]);
      expect(asAny(c).statusOptions().length).toBe(4);
    });

    it('hasActiveFilters reflects any set filter, clearFilters resets', () => {
      const c = withApps();
      const a = asAny(c);
      expect(c['hasActiveFilters']).toBe(false);
      a.searchQuery.set('x');
      expect(c['hasActiveFilters']).toBe(true);
      c['clearFilters']();
      expect(c['hasActiveFilters']).toBe(false);
      expect(a.currentPage()).toBe(1);
    });

    it('onFilterChange resets to page 1', () => {
      const c = make();
      asAny(c).currentPage.set(3);
      c['onFilterChange']();
      expect(asAny(c).currentPage()).toBe(1);
    });
  });

  // ── Apps table rendering ─────────────────────────────────────────────────────

  describe('apps table', () => {
    it('renders the Organization column: the org value when set, and "-" when null', () => {
      configure();
      const fixture: ComponentFixture<App> = TestBed.createComponent(App);
      const a = asAny(fixture.componentInstance);
      // The table only renders once authenticated and the backend is online.
      a.authState.set('authenticated');
      a.backendOnline.set(true);
      a.dataLoading.set(false);
      a.apps.set([
        makeApp({ name: 'alpha', githubOrg: 'pgetech' }),
        makeApp({ name: 'beta', githubOrg: null }),
      ]);
      fixture.detectChanges();

      const el = fixture.nativeElement as HTMLElement;

      // Header order: Organization is the 2nd column, right after GitHub Repo.
      const headers = Array.from(el.querySelectorAll('table thead th')).map((h) => h.textContent?.trim());
      expect(headers[0]).toBe('GitHub Repo');
      expect(headers[1]).toBe('Organization');

      // Each row's 2nd cell shows the org (or '-' when null).
      const rows = el.querySelectorAll('table tbody tr.app-row');
      expect(rows.length).toBe(2);
      expect(rows[0].querySelectorAll('td')[1].textContent?.trim()).toBe('pgetech');
      expect(rows[1].querySelectorAll('td')[1].textContent?.trim()).toBe('-');
    });
  });

  // ── Pagination ─────────────────────────────────────────────────────────────

  describe('pagination', () => {
    it('computes totalPages, pagedApps, pageNumbers, pageRangeEnd', () => {
      const c = make();
      const a = asAny(c);
      a.apps.set(Array.from({ length: 60 }, (_, i) => makeApp({ name: `app-${String(i).padStart(2, '0')}` })));
      expect(a.totalPages()).toBe(3);
      expect(a.pagedApps().length).toBe(25);
      expect(a.pageNumbers()).toEqual([1, 2, 3]);
      c['goToPage'](2);
      expect(a.currentPage()).toBe(2);
      expect(a.pageRangeEnd()).toBe(50);
    });

    it('runs pagination: goToRunsPage guards bounds and loads', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      appService.getRuns.and.returnValue(of(makePage([], 60)));
      a.runsTotal.set(60);
      expect(a.runsTotalPages()).toBe(3);
      expect(a.runsPageNumbers()).toEqual([1, 2, 3]);
      c['goToRunsPage'](0); // out of bounds — ignored
      expect(a.runsCurrentPage()).toBe(1);
      c['goToRunsPage'](2);
      expect(a.runsCurrentPage()).toBe(2);
      expect(a.runsPageRangeEnd()).toBe(40);
      expect(appService.getRuns).toHaveBeenCalled();
    });

    it('loadRunsPage shows a toast on error', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      appService.getRuns.and.returnValue(throwError(() => new Error('x')));
      c['goToRunsPage'](1);
      expect(a.toastMessage()).toContain('Failed to load pipeline runs');
    });

    it('loadRunsPage no-ops with no selected app', () => {
      const c = make();
      c['loadRunsPage']();
      expect(appService.getRuns).not.toHaveBeenCalled();
    });
  });

  // ── Formatting / user ──────────────────────────────────────────────────────

  describe('formatDate', () => {
    it('returns an em dash for null', () => {
      expect(make()['formatDate'](null)).toBe('—');
    });
    it('returns the raw string for an invalid date', () => {
      expect(make()['formatDate']('not-a-date')).toBe('not-a-date');
    });
    it('formats a valid ISO date', () => {
      expect(make()['formatDate']('2026-07-01T13:05:09Z')).toMatch(/\d{2}\/\d{2}\/\d{4}/);
    });
  });

  describe('triggeredByLabel / initialsFor', () => {
    it('labels blank/whitespace as System', () => {
      const c = make();
      expect(c['triggeredByLabel'](null)).toBe('System');
      expect(c['triggeredByLabel']('  ')).toBe('System');
      expect(c['triggeredByLabel']('Robb')).toBe('Robb');
    });

    it('derives initials for each name shape', () => {
      const c = make();
      expect(c['initialsFor'](null)).toBe('—');
      expect(c['initialsFor']('System')).toBe('⚙');
      expect(c['initialsFor']('Morgan, Robb')).toBe('RM');
      expect(c['initialsFor']('Robb Morgan')).toBe('RM');
      expect(c['initialsFor']('Cher')).toBe('C');
      expect(c['initialsFor'](',')).toBe('?');
    });
  });

  describe('loadUserPhoto', () => {
    let fetchSpy: jasmine.Spy;
    afterEach(() => {
      if (fetchSpy) fetchSpy.and.callThrough();
    });

    it('sets the photo from a successful graph fetch', fakeAsync(() => {
      const c = make();
      const blob = new Blob(['x']);
      fetchSpy = spyOn(window, 'fetch').and.resolveTo({ ok: true, blob: () => Promise.resolve(blob) } as unknown as Response);
      spyOn(URL, 'createObjectURL').and.returnValue('blob:url');
      c['loadUserPhoto']();
      flushMicrotasks();
      flushMicrotasks();
      expect(asAny(c).currentUserPhoto()).toBe('blob:url');
    }));

    it('swallows a failed graph fetch', fakeAsync(() => {
      const c = make();
      fetchSpy = spyOn(window, 'fetch').and.resolveTo({ ok: false, blob: () => Promise.resolve(new Blob()) } as unknown as Response);
      c['loadUserPhoto']();
      flushMicrotasks();
      flushMicrotasks();
      expect(asAny(c).currentUserPhoto()).toBeNull();
    }));

    it('is a no-op when a photo is already loaded', () => {
      const c = make();
      asAny(c).currentUserPhoto.set('blob:existing');
      c['loadUserPhoto']();
      expect(msal.acquireTokenSilent).not.toHaveBeenCalled();
    });
  });

  // ── How-To modal ─────────────────────────────────────────────────────────────

  describe('how-to modal', () => {
    it('currentSample returns the sample for the selected type and falls back to angular', () => {
      const c = make();
      c['howToAppType'] = 'react';
      expect(c['currentSample']).toContain('my-react-app');
      c['howToAppType'] = 'nonsense';
      expect(c['currentSample']).toContain('my-angular-app');
    });

    it('open/close toggle the modal', () => {
      const c = make();
      c['openHowTo']();
      expect(asAny(c).showHowToModal()).toBe(true);
      expect(c['howToAppType']).toBe('angular');
      c['closeHowTo']();
      expect(asAny(c).showHowToModal()).toBe(false);
    });
  });

  // ── Manage modal ──────────────────────────────────────────────────────────────

  describe('manage modal', () => {
    it('onManageApp opens the modal and loads detail + runs', () => {
      const c = make();
      c['onManageApp'](makeApp());
      expect(asAny(c).showManageModal()).toBe(true);
      expect(asAny(c).appDetail()).toBeTruthy();
      expect(appService.getRuns).toHaveBeenCalled();
    });

    it('onManageApp shows a toast and closes when detail load fails', () => {
      const c = make();
      appService.getApp.and.returnValue(throwError(() => new Error('x')));
      c['onManageApp'](makeApp());
      expect(asAny(c).toastMessage()).toContain('Failed to load details');
      expect(asAny(c).showManageModal()).toBe(false);
    });

    it('closeManageModal resets state', () => {
      const c = make();
      const a = asAny(c);
      a.showManageModal.set(true);
      a.selectedApp.set(makeApp());
      c['closeManageModal']();
      expect(a.showManageModal()).toBe(false);
      expect(a.selectedApp()).toBeNull();
    });

    it('toggleManageModalFullscreen flips the flag', () => {
      const c = make();
      c['toggleManageModalFullscreen']();
      expect(asAny(c).manageModalFullscreen()).toBe(true);
    });
  });

  // ── Stage detail ──────────────────────────────────────────────────────────────

  describe('stage detail', () => {
    function evt(): Event {
      return { stopPropagation: jasmine.createSpy('stopPropagation') } as unknown as Event;
    }

    it('onStageClick ignores skipped/pending stages', () => {
      const c = make();
      c['onStageClick'](evt(), makeRun({ stages: { ...makeRun().stages, build: 'Skipped' } }), 'build');
      expect(asAny(c).expandedStage()).toBeNull();
    });

    it('onStageClick expands then collapses the same stage', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      c['onStageClick'](evt(), makeRun(), 'build');
      expect(a.expandedStage()).toEqual({ runId: 200, stageName: 'build' });
      c['onStageClick'](evt(), makeRun(), 'build');
      expect(a.expandedStage()).toBeNull();
    });

    it('onStageClick loads compliance summary for the review stage', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      c['onStageClick'](evt(), makeRun(), 'review');
      expect(appService.getComplianceSummary).toHaveBeenCalled();
      expect(a.complianceSummary()).toBeTruthy();
    });

    it('onStageClick loads the SonarQube URL for a terminal scan stage', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      const run = makeRun({ stages: { ...makeRun().stages, scan: 'Success' } });
      c['onStageClick'](evt(), run, 'scan');
      expect(appService.getScanResultUrl).toHaveBeenCalled();
      expect(a.scanResultUrl()).toContain('sonarqube');
    });

    it('scanResultAvailable is true only for terminal statuses', () => {
      const c = make();
      expect(c['scanResultAvailable']('Success')).toBe(true);
      expect(c['scanResultAvailable']('Failed')).toBe(true);
      expect(c['scanResultAvailable']('Running')).toBe(false);
    });

    it('scan URL lookup stays silent (button hidden) when unavailable', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      appService.getScanResultUrl.and.returnValue(throwError(() => new Error('x')));
      const run = makeRun({ stages: { ...makeRun().stages, scan: 'Failed' } });
      c['onStageClick'](evt(), run, 'scan');
      expect(a.scanResultUrl()).toBeNull();
    });

    it('openScanResult opens a new tab only when a URL is present', () => {
      const c = make();
      const a = asAny(c);
      const openSpy = spyOn(window, 'open');
      c['openScanResult'](evt());
      expect(openSpy).not.toHaveBeenCalled();
      a.scanResultUrl.set('https://sonarqube.nonprod.pge.com/dashboard?id=epic-web');
      c['openScanResult'](evt());
      expect(openSpy).toHaveBeenCalledWith('https://sonarqube.nonprod.pge.com/dashboard?id=epic-web', '_blank', 'noopener');
    });

    it('onStageClick shows a toast when stage detail fails', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      appService.getStageDetail.and.returnValue(throwError(() => new Error('x')));
      c['onStageClick'](evt(), makeRun(), 'build');
      expect(a.toastMessage()).toContain('Failed to load stage detail');
      expect(a.expandedStage()).toBeNull();
    });

    it('onStageClick bails when no app is selected', () => {
      const c = make();
      c['onStageClick'](evt(), makeRun(), 'build');
      expect(appService.getStageDetail).not.toHaveBeenCalled();
    });

    it('isStageExpanded reflects the current expansion', () => {
      const c = make();
      asAny(c).expandedStage.set({ runId: 200, stageName: 'build' });
      expect(c['isStageExpanded'](200, 'build')).toBe(true);
      expect(c['isStageExpanded'](200, 'scan')).toBe(false);
    });

    it('stageStatusOf reads a stage status off a run; clickableStages lists the expandable stages', () => {
      const c = make();
      const run = makeRun({ stages: { ...makeRun().stages, scan: 'Failed' } });
      expect(c['stageStatusOf'](run, 'scan')).toBe('Failed');
      expect(c['stageStatusOf'](run, 'build')).toBe('Success');
      expect(c['clickableStages'].map((s) => s.key)).toContain('review');
      expect(c['clickableStages'].length).toBe(7);
    });

    it('stageSteps returns empty when no detail is loaded', () => {
      expect(asAny(make()).stageSteps()).toEqual([]);
    });

    it('stageSteps flattens jobs', () => {
      const c = make();
      asAny(c).stageDetail.set({
        stageName: 'build',
        status: 'Success',
        duration: '1m',
        jobs: [{ name: 'j', status: 'Success', duration: '1m', steps: [{ name: 's', status: 'Success', duration: '1m', logId: 1 }] }],
      } as StageDetail);
      expect(asAny(c).stageSteps().length).toBe(1);
    });

    it('onStepClick toggles, loads log, and handles errors', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'build' });
      const e = evt();
      c['onStepClick'](e, { logId: null }); // no log — bail
      expect(a.expandedLogId()).toBeNull();
      c['onStepClick'](e, { logId: 7 });
      expect(a.stepLog()).toBe('log text');
      c['onStepClick'](e, { logId: 7 }); // toggle closed
      expect(a.expandedLogId()).toBeNull();
    });

    it('onStepClick bails after expanding when app/run context is missing', () => {
      const c = make();
      const a = asAny(c);
      // logId set, but no selectedApp / expandedStage → the guard returns before fetching.
      c['onStepClick'](evt(), { logId: 7 });
      expect(a.expandedLogId()).toBe(7);
      expect(appService.getStepLog).not.toHaveBeenCalled();
    });

    it('onStepClick shows a toast on log error', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'build' });
      appService.getStepLog.and.returnValue(throwError(() => new Error('x')));
      c['onStepClick'](evt(), { logId: 7 });
      expect(a.toastMessage()).toContain('Failed to load step log');
    });

    it('copyLog writes to the clipboard when a log is present', fakeAsync(() => {
      const c = make();
      asAny(c).stepLog.set('hello');
      const writeText = spyOn(navigator.clipboard, 'writeText').and.resolveTo();
      c['copyLog'](evt());
      flushMicrotasks();
      expect(writeText).toHaveBeenCalledWith('hello');
    }));

    it('copyLog is a no-op with no log', () => {
      const c = make();
      const writeText = spyOn(navigator.clipboard, 'writeText').and.resolveTo();
      c['copyLog'](evt());
      expect(writeText).not.toHaveBeenCalled();
    });

    it('collapseStageDetail resets stage state', () => {
      const c = make();
      const a = asAny(c);
      a.expandedStage.set({ runId: 1, stageName: 'build' });
      c['collapseStageDetail']();
      expect(a.expandedStage()).toBeNull();
    });
  });

  // ── Compliance ────────────────────────────────────────────────────────────────

  describe('compliance', () => {
    function evt(): Event {
      return { stopPropagation: jasmine.createSpy() } as unknown as Event;
    }

    it('complianceVerdictRows orders known verdicts and appends extras', () => {
      const c = make();
      const a = asAny(c);
      expect(c['complianceVerdictRows']()).toEqual([]);
      a.complianceSummary.set(makeComplianceSummary({ byVerdict: { PASS: 3, WEIRD: 1, FAIL: 2 } }));
      const rows = c['complianceVerdictRows']();
      expect(rows[0]).toEqual({ verdict: 'FAIL', count: 2 });
      expect(rows.some((r: { verdict: string }) => r.verdict === 'WEIRD')).toBe(true);
    });

    it('complianceVerdictRows tolerates a summary with no byVerdict map', () => {
      const c = make();
      asAny(c).complianceSummary.set(makeComplianceSummary({ byVerdict: undefined as any }));
      expect(c['complianceVerdictRows']()).toEqual([]);
    });

    it('loadComplianceSummary clears on error', () => {
      const c = make();
      const a = asAny(c);
      appService.getComplianceSummary.and.returnValue(throwError(() => new Error('x')));
      c['loadComplianceSummary']('my-app', 200);
      expect(a.complianceSummary()).toBeNull();
    });

    it('reviewReportAvailable only for terminal states', () => {
      const c = make();
      expect(c['reviewReportAvailable']('Success')).toBe(true);
      expect(c['reviewReportAvailable']('Failed')).toBe(true);
      expect(c['reviewReportAvailable']('Running' as RunStatus)).toBe(false);
    });

    it('downloadComplianceReport fetches and triggers a download', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'review' });
      spyOn(URL, 'createObjectURL').and.returnValue('blob:x');
      spyOn(URL, 'revokeObjectURL');
      const click = spyOn(HTMLAnchorElement.prototype, 'click');
      c['downloadComplianceReport'](evt());
      expect(click).toHaveBeenCalled();
      expect(a.complianceReportDownloading()).toBe(false);
    });

    it('downloadComplianceReport shows a toast on error', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'review' });
      appService.getComplianceReport.and.returnValue(throwError(() => new Error('x')));
      c['downloadComplianceReport'](evt());
      expect(a.toastMessage()).toContain('No compliance report available');
    });

    it('downloadComplianceReport bails without app/run', () => {
      const c = make();
      c['downloadComplianceReport'](evt());
      expect(appService.getComplianceReport).not.toHaveBeenCalled();
    });

    it('viewComplianceReport opens the modal with the report', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'review' });
      c['viewComplianceReport'](evt());
      expect(a.showReportModal()).toBe(true);
      expect(a.reportModalReport()).toBeTruthy();
    });

    it('viewComplianceReport shows a toast and closes on error', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.expandedStage.set({ runId: 200, stageName: 'review' });
      appService.getComplianceReportJson.and.returnValue(throwError(() => new Error('x')));
      c['viewComplianceReport'](evt());
      expect(a.showReportModal()).toBe(false);
      expect(a.toastMessage()).toContain('No compliance report available');
    });

    it('viewComplianceReport bails without app/run', () => {
      const c = make();
      c['viewComplianceReport'](evt());
      expect(appService.getComplianceReportJson).not.toHaveBeenCalled();
    });

    it('toggle/close report modal and reportFindingGroups', () => {
      const c = make();
      const a = asAny(c);
      c['toggleReportModalFullscreen']();
      expect(a.reportModalFullscreen()).toBe(true);
      a.reportModalReport.set({
        summary: makeComplianceSummary(),
        profile: null,
        findings: [
          { nistId: 'AC-2', title: 't', requirement: null, verdict: 'FAIL', kind: null, severity: null, message: null, remediation: null, inheritedFrom: null, evidence: null },
          { nistId: 'AC-3', title: 't', requirement: null, verdict: 'PASS', kind: null, severity: null, message: null, remediation: null, inheritedFrom: null, evidence: null },
        ],
      });
      const groups = c['reportFindingGroups']();
      expect(groups[0].verdict).toBe('FAIL');
      c['closeReportModal']();
      expect(a.showReportModal()).toBe(false);
      expect(c['reportFindingGroups']()).toEqual([]);
    });
  });

  // ── Add modal ───────────────────────────────────────────────────────────────

  describe('add-app modal', () => {
    it('onAddApp resets and opens', () => {
      const c = make();
      c['onAddApp']();
      expect(asAny(c).showAddModal()).toBe(true);
      expect(asAny(c).repoCheckStatus()).toBe('idle');
    });

    it('onAddApp loads GitHub sources and defaults the selection on first open', () => {
      const c = make();
      appService.getGitHubSources.and.returnValue(of({ sources: GITHUB_SOURCES, defaultSource: 'pgetech' }));
      c['onAddApp']();
      expect(appService.getGitHubSources).toHaveBeenCalled();
      expect(asAny(c).githubSources()).toEqual(GITHUB_SOURCES);
      expect(asAny(c).selectedSource()).toBe('pgetech');
    });

    it('onAddApp leaves sources empty and does not throw when the load errors', () => {
      const c = make();
      appService.getGitHubSources.and.returnValue(throwError(() => new Error('x')));
      expect(() => c['onAddApp']()).not.toThrow();
      expect(asAny(c).githubSources()).toEqual([]);
      expect(asAny(c).selectedSource()).toBe('');
    });

    it('onAddApp does not reload sources on a second open and re-defaults to the isDefault source', () => {
      const c = make();
      const a = asAny(c);
      a.githubSources.set(GITHUB_SOURCES);
      a.selectedSource.set(''); // reset by a prior source change
      appService.getGitHubSources.calls.reset();
      c['onAddApp']();
      expect(appService.getGitHubSources).not.toHaveBeenCalled();
      expect(a.selectedSource()).toBe('pgetech'); // isDefault
    });

    it('onAddApp re-defaults to the first source when none is marked default', () => {
      const c = make();
      const a = asAny(c);
      a.githubSources.set([
        { name: 'one', org: 'One', isDefault: false },
        { name: 'two', org: 'Two', isDefault: false },
      ]);
      a.selectedSource.set('');
      c['onAddApp']();
      expect(a.selectedSource()).toBe('one'); // fallback to first
    });

    it('onAddApp re-defaults to empty when the only source has no name (final ?? fallback)', () => {
      const c = make();
      const a = asAny(c);
      // Non-empty list (so the else-if runs) whose sole entry has no name: neither the
      // isDefault lookup nor githubSources()[0]?.name resolves, so the final `?? ''` fires.
      a.githubSources.set([{ org: 'One', isDefault: false } as unknown as GitHubSourceOption]);
      a.selectedSource.set('');
      c['onAddApp']();
      expect(a.selectedSource()).toBe('');
    });

    it('onSourceChange resets the repo check state', () => {
      const c = make();
      const a = asAny(c);
      a.repoCheckStatus.set('available');
      a.foundMasterApp.set({ name: 'r' } as AppLookup);
      c['onSourceChange']();
      expect(a.repoCheckStatus()).toBe('idle');
      expect(a.foundMasterApp()).toBeNull();
    });

    it('renders the org select in the modal only when more than one source is configured', () => {
      configure();
      const fixture: ComponentFixture<App> = TestBed.createComponent(App);
      const a = asAny(fixture.componentInstance);
      const el = fixture.nativeElement as HTMLElement;

      // The modal only renders once authenticated.
      a.authState.set('authenticated');
      // One source → no select.
      a.githubSources.set([GITHUB_SOURCES[0]]);
      a.showAddModal.set(true);
      fixture.detectChanges();
      expect(el.querySelector('#onboard-source')).toBeNull();

      // More than one → select with an option per source.
      a.githubSources.set(GITHUB_SOURCES);
      fixture.detectChanges();
      const select = el.querySelector('#onboard-source');
      expect(select).not.toBeNull();
      expect(select!.querySelectorAll('option').length).toBe(GITHUB_SOURCES.length);
      expect(el.textContent).toContain('PGEDigitalCatalyst');
    });

    it('onRepoChange / closeAddModal reset state', () => {
      const c = make();
      const a = asAny(c);
      a.repoCheckStatus.set('available');
      c['onRepoChange']();
      expect(a.repoCheckStatus()).toBe('idle');
      c['closeAddModal']();
      expect(a.showAddModal()).toBe(false);
    });

    it('onRepoBlur sets idle for empty repo', () => {
      const c = make();
      c['newAppRepo'] = '   ';
      c['onRepoBlur']();
      expect(asAny(c).repoCheckStatus()).toBe('idle');
    });

    it('onRepoBlur stores the check result and passes the selected source', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).selectedSource.set('pgedc');
      const master: AppLookup = { name: 'r', displayName: 'R', technology: 'Angular', cloud: 'AWS', environment: 'dev', github: { repo: 'org/repo' } };
      appService.checkRepo.and.returnValue(of({ status: 'in-epic-not-mine', masterApp: master }));
      c['onRepoBlur']();
      expect(appService.checkRepo).toHaveBeenCalledWith('org/repo', 'pgedc');
      expect(asAny(c).repoCheckStatus()).toBe('in-epic-not-mine');
      expect(asAny(c).foundMasterApp()).toEqual(master);
    });

    it('onRepoBlur passes undefined for the source when none is selected', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).selectedSource.set(''); // falsy → || undefined
      c['onRepoBlur']();
      expect(appService.checkRepo).toHaveBeenCalledWith('org/repo', undefined);
    });

    it('onRepoBlur sets not-found on error', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      appService.checkRepo.and.returnValue(throwError(() => new Error('x')));
      c['onRepoBlur']();
      expect(asAny(c).repoCheckStatus()).toBe('not-found');
    });

    it('canOnboard requires a repo and available status', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).repoCheckStatus.set('available');
      expect(c['canOnboard']).toBe(true);
      asAny(c).repoCheckStatus.set('not-found');
      expect(c['canOnboard']).toBe(false);
    });

    it('onOnboardApp adds the app on success and forwards the selected source', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).selectedSource.set('pgedc');
      asAny(c).repoCheckStatus.set('available');
      c['onOnboardApp']();
      expect(appService.onboardApp).toHaveBeenCalledWith('org/repo', 'pgedc');
      expect(asAny(c).apps().length).toBe(1);
      expect(asAny(c).toastMessage()).toContain('has been added to EPIC');
    });

    it('onOnboardApp passes undefined for the source when none is selected', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).selectedSource.set(''); // falsy → || undefined
      asAny(c).repoCheckStatus.set('available');
      c['onOnboardApp']();
      expect(appService.onboardApp).toHaveBeenCalledWith('org/repo', undefined);
    });

    it('onOnboardApp surfaces the server error message', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).repoCheckStatus.set('available');
      appService.onboardApp.and.returnValue(throwError(() => ({ error: { error: 'nope' } })));
      c['onOnboardApp']();
      expect(asAny(c).toastMessage()).toBe('nope');
    });

    it('onOnboardApp falls back to a default message when the error has no body', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      asAny(c).repoCheckStatus.set('available');
      appService.onboardApp.and.returnValue(throwError(() => new Error('x')));
      c['onOnboardApp']();
      expect(asAny(c).toastMessage()).toContain('Failed to onboard');
    });

    it('onOnboardApp is a no-op when it cannot onboard', () => {
      const c = make();
      c['onOnboardApp']();
      expect(appService.onboardApp).not.toHaveBeenCalled();
    });

    it('onRepoBlur stores a null master app when none is returned', () => {
      const c = make();
      c['newAppRepo'] = 'org/repo';
      appService.checkRepo.and.returnValue(of({ status: 'available' }));
      c['onRepoBlur']();
      expect(asAny(c).foundMasterApp()).toBeNull();
    });

    it('onAddToMyList adds the master app', () => {
      const c = make();
      const master: AppLookup = { name: 'r', displayName: 'R', technology: 'Angular', cloud: 'AWS', environment: 'dev', github: { repo: 'org/repo' } };
      asAny(c).foundMasterApp.set(master);
      c['onAddToMyList']();
      expect(asAny(c).apps().length).toBe(1);
    });

    it('onAddToMyList shows a toast on error', () => {
      const c = make();
      const master: AppLookup = { name: 'r', displayName: 'R', technology: 'Angular', cloud: 'AWS', environment: 'dev', github: { repo: 'org/repo' } };
      asAny(c).foundMasterApp.set(master);
      appService.addToMyApps.and.returnValue(throwError(() => new Error('x')));
      c['onAddToMyList']();
      expect(asAny(c).toastMessage()).toContain('Failed to add');
    });

    it('onAddToMyList is a no-op with no master app', () => {
      const c = make();
      c['onAddToMyList']();
      expect(appService.addToMyApps).not.toHaveBeenCalled();
    });
  });

  // ── New Run modal ────────────────────────────────────────────────────────────

  describe('new-run modal', () => {
    function openRun(c: App): void {
      asAny(c).appDetail.set(makeDetail());
      c['onNewRun']();
    }

    it('onNewRun resets state from the detail', () => {
      const c = make();
      openRun(c);
      expect(asAny(c).showNewRunModal()).toBe(true);
      expect(asAny(c).newRunEnvironment).toBe('dev');
    });

    it('onNewRun is a no-op without a detail', () => {
      const c = make();
      c['onNewRun']();
      expect(asAny(c).showNewRunModal()).toBe(false);
    });

    it('onNewRunBranchChange locks prod for release branches', () => {
      const c = make();
      c['newRunBranch'] = 'release2';
      c['onNewRunBranchChange']();
      expect(c['newRunEnvironment']).toBe('prod');
      expect(asAny(c).newRunEnvLocked()).toBe(true);

      c['newRunBranch'] = 'feature';
      c['onNewRunBranchChange']();
      expect(asAny(c).newRunEnvLocked()).toBe(false);
    });

    it('onNewRunBranchBlur is idle for empty branch/repo', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = '';
      c['onNewRunBranchBlur']();
      expect(asAny(c).configSearchStatus()).toBe('idle');
    });

    it('onNewRunBranchBlur → not-found when no configs (forces Review-only)', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      // Simulate a stale non-Review selection that must be cleared.
      c['newRunBuild'] = true;
      c['newRunScan'] = true;
      appService.getConfigs.and.returnValue(of({ configs: [] }));
      c['onNewRunBranchBlur']();
      expect(asAny(c).configSearchStatus()).toBe('not-found');
      expect(c['newRunReview']).toBe(true);
      expect(c['newRunBuild']).toBe(false);
      expect(c['newRunScan']).toBe(false);
      expect(c['newRunTests']).toBe(false);
      expect(c['newRunDeploy']).toBe(false);
      expect(c['newRunIntegrations']).toBe(false);
      expect(c['newRunDeployInfra']).toBe('none');
    });

    it('onNewRunBranchBlur → found (single config auto-checks infra)', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      appService.getConfigs.and.returnValue(of({ configs: ['.pipeline/epic.json'] }));
      c['onNewRunBranchBlur']();
      expect(asAny(c).configSearchStatus()).toBe('found');
      expect(asAny(c).newRunHasInfra()).toBe(true);
      expect(asAny(c).newRunDeployInfra).toBe('apply');
    });

    it('onNewRunBranchBlur → found (multiple configs, no auto-check)', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      appService.getConfigs.and.returnValue(of({ configs: ['a.json', 'b.json'] }));
      c['onNewRunBranchBlur']();
      expect(asAny(c).newRunValidating()).toBe(false);
      expect(asAny(c).newRunConfig).toBe('');
    });

    it('onNewRunBranchBlur single-config infra error resets flags', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      appService.getConfigs.and.returnValue(of({ configs: ['.pipeline/epic.json'] }));
      appService.checkConfigInfra.and.returnValue(throwError(() => new Error('x')));
      c['onNewRunBranchBlur']();
      expect(asAny(c).newRunHasInfra()).toBe(false);
    });

    it('onNewRunBranchBlur → error status when getConfigs fails', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      appService.getConfigs.and.returnValue(throwError(() => new Error('x')));
      c['onNewRunBranchBlur']();
      expect(asAny(c).configSearchStatus()).toBe('error');
    });

    it('onNewRunBranchBlur skips re-validation of the same branch', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      appService.getConfigs.and.returnValue(of({ configs: ['.pipeline/epic.json'] }));
      c['onNewRunBranchBlur']();
      appService.getConfigs.calls.reset();
      c['onNewRunBranchBlur']();
      expect(appService.getConfigs).not.toHaveBeenCalled();
    });

    it('onConfigSelect checks infra for the chosen config', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      c['newRunConfig'] = '.pipeline/epic.json';
      c['onConfigSelect']();
      expect(appService.checkConfigInfra).toHaveBeenCalled();
      expect(asAny(c).newRunHasInfra()).toBe(true);
    });

    it('onConfigSelect is a no-op without repo/branch/config', () => {
      const c = make();
      openRun(c);
      c['newRunConfig'] = '';
      appService.checkConfigInfra.calls.reset();
      c['onConfigSelect']();
      expect(appService.checkConfigInfra).not.toHaveBeenCalled();
    });

    it('checkInfraForConfig error path resets flags', () => {
      const c = make();
      openRun(c);
      c['newRunBranch'] = 'main';
      c['newRunConfig'] = '.pipeline/epic.json';
      appService.checkConfigInfra.and.returnValue(throwError(() => new Error('x')));
      c['onConfigSelect']();
      expect(asAny(c).newRunHasInfra()).toBe(false);
      expect(asAny(c).newRunValidating()).toBe(false);
    });

    it('applyAppTypeDefaults for btp forces stages off and plan', () => {
      const c = make();
      c['applyAppTypeDefaults']('btp');
      expect(c['newRunReview']).toBe(false);
      expect(c['newRunDeployInfra']).toBe('plan');
    });

    it('applyAppTypeDefaults for infra sets apply', () => {
      const c = make();
      c['applyAppTypeDefaults']('infra');
      expect(c['newRunDeployInfra']).toBe('apply');
    });

    describe('stage disabled getters', () => {
      it('reviewDisabled', () => {
        const c = make();
        expect(c['reviewDisabled']).toBe(true); // no config
        c['newRunConfig'] = 'x';
        asAny(c).newRunConfigAppType.set('angular');
        expect(c['reviewDisabled']).toBe(false);
        asAny(c).newRunConfigAppType.set('btp');
        expect(c['reviewDisabled']).toBe(true);
      });

      it('reviewDisabled — contract-less (no config) keeps Review available', () => {
        const c = make();
        // No config selected, but the repo/branch has no epic.json at all.
        asAny(c).configSearchStatus.set('not-found');
        expect(c['noConfig']).toBe(true);
        expect(c['reviewDisabled']).toBe(false);
        // ...unless it's resolved as an infra appType (defensive; shouldn't co-occur).
        asAny(c).newRunConfigAppType.set('infra');
        expect(c['reviewDisabled']).toBe(true);
      });

      it('buildTestsDisabled / scanDisabled', () => {
        const c = make();
        c['newRunConfig'] = 'x';
        asAny(c).newRunBuildTestTool.set('jest');
        expect(c['buildTestsDisabled']).toBe(false);
        asAny(c).newRunBuildTestTool.set(null);
        expect(c['buildTestsDisabled']).toBe(true);
        asAny(c).newRunScanTool.set('sonarqube');
        expect(c['scanDisabled']).toBe(false);
        // .NET scans are compile-instrumented: disabled until Build is selected.
        asAny(c).newRunConfigAppType.set('dotnet');
        c['newRunBuild'] = false;
        expect(c['scanDisabled']).toBe(true);
        c['newRunBuild'] = true;
        expect(c['scanDisabled']).toBe(false);
      });

      it('deployDisabled handles cap, infra presence and btp', () => {
        const c = make();
        c['newRunConfig'] = 'x';
        c['newRunBuild'] = true;
        asAny(c).newRunConfigAppType.set('cap');
        expect(c['deployDisabled']).toBe(false);
        asAny(c).newRunConfigAppType.set('angular');
        asAny(c).newRunHasInfra.set(false);
        asAny(c).newRunHasInfraParams.set(false);
        expect(c['deployDisabled']).toBe(true);
        asAny(c).newRunHasInfra.set(true);
        expect(c['deployDisabled']).toBe(false);
      });

      it('integrationTestsDisabled requires the tool and infra/cap', () => {
        const c = make();
        expect(c['integrationTestsDisabled']).toBe(true); // no tool
        asAny(c).newRunIntegrationTestTool.set('playwright');
        c['newRunConfig'] = 'x';
        asAny(c).newRunConfigAppType.set('cap');
        expect(c['integrationTestsDisabled']).toBe(false);
        asAny(c).newRunConfigAppType.set('angular');
        asAny(c).newRunHasInfra.set(true);
        expect(c['integrationTestsDisabled']).toBe(false);
      });

      it('infraDisabled reflects newRunHasInfra', () => {
        const c = make();
        expect(c['infraDisabled']).toBe(true);
        asAny(c).newRunHasInfra.set(true);
        expect(c['infraDisabled']).toBe(false);
      });
    });

    it('onBuildToggle unchecks deploy when build is off', () => {
      const c = make();
      c['newRunDeploy'] = true;
      c['onBuildToggle'](false);
      expect(c['newRunDeploy']).toBe(false);
    });

    it('onBuildToggle unchecks scan for .NET when build is off', () => {
      const c = make();
      asAny(c).newRunConfigAppType.set('dotnet');
      c['newRunScan'] = true;
      c['onBuildToggle'](false);
      expect(c['newRunScan']).toBe(false);
    });

    it('onBuildToggle leaves scan alone for non-.NET apps', () => {
      const c = make();
      asAny(c).newRunConfigAppType.set('angular');
      c['newRunScan'] = true;
      c['onBuildToggle'](false);
      expect(c['newRunScan']).toBe(true);
    });

    it('planOnlyWithDeploy / missingS3Backend / infraDeployBlockedNoS3Backend / showForceStateCopy', () => {
      const c = make();
      const a = asAny(c);
      c['newRunDeployInfra'] = 'plan';
      c['newRunDeploy'] = true;
      expect(c['planOnlyWithDeploy']).toBe(true);

      a.newRunHasInfra.set(true);
      a.newRunHasS3Backend.set(false);
      expect(c['missingS3Backend']).toBe(true);
      c['newRunDeployInfra'] = 'apply';
      expect(c['infraDeployBlockedNoS3Backend']).toBe(true);

      a.newRunHasTfState.set(true);
      a.newRunHasS3Backend.set(true);
      expect(c['showForceStateCopy']).toBe(true);
    });

    it('canRunNewPipeline requires branch, env, found config, and no S3 block', () => {
      const c = make();
      const a = asAny(c);
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '.pipeline/epic.json';
      a.configSearchStatus.set('found');
      expect(c['canRunNewPipeline']).toBe(true);
    });

    it('canRunNewPipeline — contract-less run allowed only when Review is selected', () => {
      const c = make();
      const a = asAny(c);
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '';
      a.configSearchStatus.set('not-found');
      c['newRunReview'] = true;
      expect(c['canRunNewPipeline']).toBe(true);
      // Deselecting Review leaves nothing to run.
      c['newRunReview'] = false;
      expect(c['canRunNewPipeline']).toBe(false);
      // A blank branch still blocks it.
      c['newRunReview'] = true;
      c['newRunBranch'] = '';
      expect(c['canRunNewPipeline']).toBe(false);
    });

    it('closeNewRunModal returns to the manage modal', () => {
      const c = make();
      asAny(c).showNewRunModal.set(true);
      c['closeNewRunModal']();
      expect(asAny(c).showNewRunModal()).toBe(false);
      expect(asAny(c).showManageModal()).toBe(true);
    });

    it('onConfirmNewRun triggers a run and records pending state', () => {
      const c = make();
      const a = asAny(c);
      a.newRunApp.set(makeDetail());
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '.pipeline/epic.json';
      a.configSearchStatus.set('found');
      a.apps.set([makeApp({ name: 'my-app' })]);
      c['onConfirmNewRun']();
      expect(appService.triggerRun).toHaveBeenCalled();
      expect(a.pendingRuns.size).toBe(1);
      expect(a.toastMessage()).toContain('has been queued');
    });

    it('onConfirmNewRun is a no-op when it cannot run', () => {
      const c = make();
      c['onConfirmNewRun']();
      expect(appService.triggerRun).not.toHaveBeenCalled();
    });

    it('onConfirmNewRun defaults config, marks review skipped, and seeds a pending app without a current row', () => {
      const c = make();
      const a = asAny(c);
      a.newRunApp.set(makeDetail());
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      // Config searchable/found via canRunNewPipeline, but trimmed value empty → default branch.
      a.configSearchStatus.set('found');
      Object.defineProperty(c, 'canRunNewPipeline', { get: () => true });
      c['newRunConfig'] = '   ';
      c['newRunReview'] = false; // review off → Skipped stage branch
      a.apps.set([]); // no current row → default seed branch
      c['onConfirmNewRun']();
      const args = appService.triggerRun.calls.mostRecent().args[1];
      expect(args.config).toBe('.pipeline/epic.json');
      expect(a.pendingRuns.get(555)!.run.stages.review).toBe('Skipped');
    });

    it('onConfirmNewRun forwards forceStateCopy when the option is shown and checked', () => {
      const c = make();
      const a = asAny(c);
      a.newRunApp.set(makeDetail());
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '.pipeline/epic.json';
      a.configSearchStatus.set('found');
      a.newRunHasTfState.set(true);
      a.newRunHasS3Backend.set(true);
      c['newRunDeployInfra'] = 'apply';
      c['newRunForceStateCopy'] = true;
      // A non-matching app row exercises the map's identity (`: a`) branch.
      a.apps.set([makeApp({ name: 'other' }), makeApp({ name: 'my-app' })]);
      c['onConfirmNewRun']();
      expect(appService.triggerRun.calls.mostRecent().args[1].forceStateCopy).toBe(true);
    });

    it('onConfirmNewRun bails when the run is allowed but no app is set', () => {
      const c = make();
      Object.defineProperty(c, 'canRunNewPipeline', { get: () => true });
      asAny(c).newRunApp.set(null);
      c['onConfirmNewRun']();
      expect(appService.triggerRun).not.toHaveBeenCalled();
    });

    it('onConfirmNewRun aborts a destroy when the user cancels the confirm', () => {
      const c = make();
      const a = asAny(c);
      a.newRunApp.set(makeDetail());
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '.pipeline/epic.json';
      a.configSearchStatus.set('found');
      c['newRunDeployInfra'] = 'destroy';
      spyOn(window, 'confirm').and.returnValue(false);
      c['onConfirmNewRun']();
      expect(appService.triggerRun).not.toHaveBeenCalled();
    });

    it('onConfirmNewRun shows a toast on trigger error', () => {
      const c = make();
      const a = asAny(c);
      a.newRunApp.set(makeDetail());
      c['newRunBranch'] = 'main';
      c['newRunEnvironment'] = 'dev';
      c['newRunConfig'] = '.pipeline/epic.json';
      a.configSearchStatus.set('found');
      appService.triggerRun.and.returnValue(throwError(() => new Error('x')));
      c['onConfirmNewRun']();
      expect(a.toastMessage()).toContain('Failed to trigger pipeline run');
    });
  });

  // ── Cancel / remove ───────────────────────────────────────────────────────────

  describe('cancel & remove', () => {
    it('onCancelRunById optimistically cancels and confirms', () => {
      const c = make();
      const a = asAny(c);
      a.appDetail.set(makeDetail());
      a.pagedRuns.set([makeRun({ id: 200, status: 'Running' })]);
      a.apps.set([makeApp({ runId: 200, runStatus: 'Running' })]);
      c['onCancelRunById'](200);
      expect(appService.cancelRun).toHaveBeenCalled();
      expect(a.toastMessage()).toContain('has been cancelled');
    });

    it('onCancelRunById reverts on error', () => {
      const c = make();
      const a = asAny(c);
      a.appDetail.set(makeDetail());
      // Include a non-matching run + app row so the map's false-branches run too.
      a.pagedRuns.set([makeRun({ id: 200, status: 'Running' }), makeRun({ id: 201, status: 'Running' })]);
      a.apps.set([makeApp({ name: 'my-app', runId: 200, runStatus: 'Running' }), makeApp({ name: 'other', runId: 999, runStatus: 'Running' })]);
      appService.cancelRun.and.returnValue(throwError(() => new Error('x')));
      c['onCancelRunById'](200);
      expect(a.cancelledRuns.has(200)).toBe(false);
      expect(a.pagedRuns()[0].status).toBe('Running');
    });

    it('onCancelRunById is a no-op without a detail', () => {
      const c = make();
      c['onCancelRunById'](200);
      expect(appService.cancelRun).not.toHaveBeenCalled();
    });

    it('onRemoveApp removes after confirm', () => {
      const c = make();
      const a = asAny(c);
      a.selectedApp.set(makeApp());
      a.apps.set([makeApp()]);
      spyOn(window, 'confirm').and.returnValue(true);
      c['onRemoveApp']();
      expect(a.apps().length).toBe(0);
      expect(a.toastMessage()).toContain('has been removed');
    });

    it('onRemoveApp aborts when the confirm is dismissed', () => {
      const c = make();
      asAny(c).selectedApp.set(makeApp());
      spyOn(window, 'confirm').and.returnValue(false);
      c['onRemoveApp']();
      expect(appService.removeFromMyApps).not.toHaveBeenCalled();
    });

    it('onRemoveApp shows a toast on error', () => {
      const c = make();
      asAny(c).selectedApp.set(makeApp());
      spyOn(window, 'confirm').and.returnValue(true);
      appService.removeFromMyApps.and.returnValue(throwError(() => new Error('x')));
      c['onRemoveApp']();
      expect(asAny(c).toastMessage()).toContain('Failed to remove app');
    });

    it('onRemoveApp is a no-op with no selected app', () => {
      const c = make();
      c['onRemoveApp']();
      expect(appService.removeFromMyApps).not.toHaveBeenCalled();
    });
  });

  // ── Builder modal ───────────────────────────────────────────────────────────

  describe('builder modal', () => {
    it('onBuilderAppTypeChange resets and prefills tools', () => {
      const c = make();
      c['builderAppType'] = 'angular';
      c['onBuilderAppTypeChange']();
      expect(c['builderScanTool']).toBe('sonarqube');
      expect(c['builderUnitTestTool']).toBe('karma');
    });

    it('onBuilderAppTypeChange leaves tools empty for an infra type', () => {
      const c = make();
      c['builderAppType'] = 'btp';
      c['onBuilderAppTypeChange']();
      expect(c['builderScanTool']).toBe('');
      expect(c['builderUnitTestTool']).toBe('');
    });

    it('open/close builder toggles state and return target', () => {
      const c = make();
      c['openBuilder']();
      expect(asAny(c).showBuilderModal()).toBe(true);
      c['closeBuilder']();
      expect(asAny(c).showHowToModal()).toBe(true);
    });

    it('openBuilderFromNewRun returns to the manage modal on close', () => {
      const c = make();
      c['openBuilderFromNewRun']();
      expect(asAny(c).showBuilderModal()).toBe(true);
      c['closeBuilder']();
      expect(asAny(c).showManageModal()).toBe(true);
    });

    it('builderNext / builderBack move through steps', () => {
      const c = make();
      const a = asAny(c);
      c['builderNext']();
      expect(a.builderStep()).toBe(2);
      c['builderNext']();
      expect(a.builderStep()).toBe(3);
      c['builderBack']();
      expect(a.builderStep()).toBe(2);
      c['builderBack']();
      expect(a.builderStep()).toBe(1);
    });

    it('secret key add/remove/update (add focuses the new row)', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      c['addSecretKey']();
      c['addSecretKey']();
      tick();
      expect(a.builderSecretsManagerKeys().length).toBe(3);
      c['updateSecretKey'](1, 'CF_USER'); // middle index → exercises both ternary branches
      expect(a.builderSecretsManagerKeys()[1]).toBe('CF_USER');
      c['removeSecretKey'](0);
      expect(a.builderSecretsManagerKeys().length).toBe(2);
    }));

    it('component add/remove/update', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      c['addComponent']();
      c['addComponent']();
      tick();
      expect(a.builderComponents().length).toBe(3);
      c['updateComponent'](1, 'server');
      expect(a.builderComponents()[1]).toBe('server');
      c['removeComponent'](0);
      expect(a.builderComponents().length).toBe(2);
    }));

    it('builderJson renders app + cloud with cap fields', () => {
      const c = make();
      c['builderAppName'] = 'my-cap';
      c['builderAppType'] = 'cap';
      c['builderAwsAccountId'] = '123456789012';
      c['builderCfApi'] = 'https://api';
      asAny(c).builderSecretsManagerKeys.set(['CF_USER']);
      const json = JSON.parse(c['builderJson']);
      expect(json.app.appType).toBe('cap');
      expect(json.cloud.cfApi).toBe('https://api');
      expect(json.cloud.secretsManager.keys).toEqual(['CF_USER']);
    });

    it('builderJson emits components for ami and secretsManager for btp', () => {
      const c = make();
      c['builderAppType'] = 'ami';
      asAny(c).builderComponents.set(['server', '']);
      expect(JSON.parse(c['builderJson']).cloud.components).toEqual(['server']);

      c['builderAppType'] = 'btp';
      c['builderSecretsManagerName'] = 'sm';
      asAny(c).builderSecretsManagerKeys.set(['BTP_USERNAME']);
      expect(JSON.parse(c['builderJson']).cloud.secretsManager.name).toBe('sm');
    });

    it('builderJson includes optional app fields when set', () => {
      const c = make();
      c['builderAppName'] = 'a';
      c['builderAppType'] = 'angular';
      c['builderCodePath'] = 'code/';
      c['builderRuntimeVersion'] = '20';
      c['builderInfraPath'] = '.infra';
      c['builderConfigPath'] = '.pipeline';
      c['builderScanTool'] = 'sonarqube';
      c['builderUnitTestTool'] = 'jest';
      c['builderIntegrationTestTool'] = 'playwright';
      const app = JSON.parse(c['builderJson']).app;
      expect(app.codePath).toBe('code/');
      expect(app.infraPath).toBe('.infra');
      expect(app.configPath).toBe('.pipeline');
      expect(app.integrationTestTool).toBe('playwright');
    });

    it('builderJson omits secretsManager for btp/infra with no name or keys', () => {
      const c = make();
      c['builderAppType'] = 'infra';
      asAny(c).builderSecretsManagerKeys.set(['']);
      c['builderSecretsManagerName'] = '';
      expect(JSON.parse(c['builderJson']).cloud.secretsManager).toBeUndefined();
    });

    it('copyBuilderJson writes to clipboard', fakeAsync(() => {
      const c = make();
      c['builderAppName'] = 'a';
      c['builderAppType'] = 'angular';
      const writeText = spyOn(navigator.clipboard, 'writeText').and.resolveTo();
      c['copyBuilderJson']();
      flushMicrotasks();
      expect(writeText).toHaveBeenCalled();
    }));

    it('normalizers run on change', () => {
      const c = make();
      c['onBuilderAppNameChange']('My App');
      expect(c['builderAppName']).toBe('my-app');
      c['onBuilderAwsAccountIdChange']('12-34');
      expect(c['builderAwsAccountId']).toBe('1234');
    });

    it('builder inline errors (valid, empty, and malformed)', () => {
      const c = make();
      expect(c['builderAppNameError']).toBeNull(); // empty
      c['builderAppName'] = 'my-app';
      expect(c['builderAppNameError']).toBeNull(); // valid
      c['builderAppName'] = 'Bad Name!';
      expect(c['builderAppNameError']).toBeTruthy(); // malformed

      expect(c['builderAwsAccountIdError']).toBeNull(); // empty
      c['builderAwsAccountId'] = '123456789012';
      expect(c['builderAwsAccountIdError']).toBeNull(); // valid
      c['builderAwsAccountId'] = '123';
      expect(c['builderAwsAccountIdError']).toBeTruthy(); // malformed
    });

    it('canBuilderNext gates each step', () => {
      const c = make();
      const a = asAny(c);
      expect(c['canBuilderNext']).toBe(false); // step 1, no name
      c['builderAppName'] = 'my-app';
      c['builderAppType'] = 'angular';
      expect(c['canBuilderNext']).toBe(true);

      a.builderStep.set(2);
      c['builderAwsAccountId'] = '';
      expect(c['canBuilderNext']).toBe(false); // invalid AWS account guard
      c['builderAwsAccountId'] = '123456789012';
      expect(c['canBuilderNext']).toBe(true);

      c['builderAppType'] = 'cap';
      expect(c['canBuilderNext']).toBe(false); // missing CF fields
      c['builderCfApi'] = 'a';
      c['builderCfOrg'] = 'o';
      c['builderCfSpace'] = 's';
      c['builderCfOrigin'] = 'i';
      expect(c['canBuilderNext']).toBe(true);

      c['builderAppType'] = 'ami';
      asAny(c).builderComponents.set(['']);
      expect(c['canBuilderNext']).toBe(false);
      asAny(c).builderComponents.set(['server']);
      expect(c['canBuilderNext']).toBe(true);

      a.builderStep.set(3);
      expect(c['canBuilderNext']).toBe(true);
    });
  });

  // ── Wizard ────────────────────────────────────────────────────────────────────

  describe('create-app wizard', () => {
    it('build/integration test options key off appType', () => {
      const c = make();
      asAny(c).wizardAnswers.update((a: any) => ({ ...a, appType: 'react' }));
      expect(c['wizardBuildTestOptions']()).toContain('vitest');
      expect(c['wizardIntegrationTestOptions']()).toContain('playwright');
      asAny(c).wizardAnswers.update((a: any) => ({ ...a, appType: '' }));
      expect(c['wizardBuildTestOptions']()).toEqual([]);
      expect(c['wizardIntegrationTestOptions']()).toEqual([]);
    });

    it('wizard error computeds', () => {
      const c = make();
      const a = asAny(c);
      expect(a.wizardAppNameError()).toBeNull(); // empty
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'valid-name' }));
      expect(a.wizardAppNameError()).toBeNull(); // valid, no collision
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'Bad!' }));
      expect(a.wizardAppNameError()).toBeTruthy();
      a.apps.set([makeApp({ name: 'taken' })]);
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'taken' }));
      expect(a.wizardAppNameError()).toContain('already onboarded');

      expect(a.wizardAwsAccountIdError()).toBeNull(); // empty
      a.wizardAnswers.update((x: any) => ({ ...x, awsAccountId: '123456789012' }));
      expect(a.wizardAwsAccountIdError()).toBeNull(); // valid
      a.wizardAnswers.update((x: any) => ({ ...x, awsAccountId: '12' }));
      expect(a.wizardAwsAccountIdError()).toBeTruthy();

      expect(a.wizardAzureSubscriptionIdError()).toBeNull(); // empty
      a.wizardAnswers.update((x: any) => ({ ...x, azureSubscriptionId: 'abcdef00-1111-2222-3333-444455556666' }));
      expect(a.wizardAzureSubscriptionIdError()).toBeNull(); // valid
      a.wizardAnswers.update((x: any) => ({ ...x, azureSubscriptionId: 'bad' }));
      expect(a.wizardAzureSubscriptionIdError()).toBeTruthy();
    });

    it('appType option list and helpers', () => {
      const c = make();
      const a = asAny(c);
      expect(a.wizardAppTypeOptions().length).toBeGreaterThan(0);
      a.wizardAnswers.update((x: any) => ({ ...x, appType: 'btp' }));
      expect(a.wizardArchitectureSkipped()).toBe(true);
      expect(c['wizardAppTypeLabel']()).toBe('SAP BTP');
      a.wizardAnswers.update((x: any) => ({ ...x, appType: '' }));
      expect(c['wizardAppTypeLabel']()).toBe('');
    });

    it('onCreateNewApp opens the wizard and loads steering', fakeAsync(() => {
      const c = make();
      spyOn(window, 'fetch').and.resolveTo({ ok: true, text: () => Promise.resolve('# steering') } as unknown as Response);
      c['onCreateNewApp']();
      flushMicrotasks();
      flushMicrotasks();
      expect(asAny(c).showCreateAppWizard()).toBe(true);
      expect(asAny(c).epicInfraContent()).toContain('steering');
    }));

    it('loadEpicInfraSteering flags an error on non-ok fetch', fakeAsync(() => {
      const c = make();
      spyOn(window, 'fetch').and.resolveTo({ ok: false, status: 500, text: () => Promise.resolve('') } as unknown as Response);
      c['loadEpicInfraSteering']();
      flushMicrotasks();
      flushMicrotasks();
      expect(asAny(c).epicInfraLoadError()).toBe(true);
    }));

    it('loadEpicInfraSteering is skipped when content already present', () => {
      const c = make();
      asAny(c).epicInfraContent.set('cached');
      const fetchSpy = spyOn(window, 'fetch');
      c['loadEpicInfraSteering']();
      expect(fetchSpy).not.toHaveBeenCalled();
    });

    it('closeCreateAppWizard closes', () => {
      const c = make();
      asAny(c).showCreateAppWizard.set(true);
      c['closeCreateAppWizard']();
      expect(asAny(c).showCreateAppWizard()).toBe(false);
    });

    it('wizardNext validates step 1 and advances; renders preview on step 4', () => {
      const c = make();
      const a = asAny(c);
      // step 1 invalid → stays
      c['wizardNext']();
      expect(a.wizardStep()).toBe(1);
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'my-app', appType: 'angular' }));
      c['wizardNext']();
      expect(a.wizardStep()).toBe(2);
      // jump to step 4 to hit the preview branch
      a.wizardStep.set(4);
      c['wizardNext']();
      expect(a.wizardStep()).toBe(5);
      expect(a.wizardPreview().length).toBeGreaterThan(0);
    });

    it('wizardNext blocks on invalid step 3', () => {
      const c = make();
      const a = asAny(c);
      a.wizardStep.set(3);
      a.wizardAnswers.update((x: any) => ({ ...x, appType: 'btp', awsAccountId: '', secretsManagerName: '' }));
      c['wizardNext']();
      expect(a.wizardStep()).toBe(3);
    });

    it('wizardBack steps down', () => {
      const c = make();
      asAny(c).wizardStep.set(3);
      c['wizardBack']();
      expect(asAny(c).wizardStep()).toBe(2);
    });

    it('stampedAnswers falls back to "unknown" when no user is known', () => {
      const c = make();
      const a = asAny(c);
      a.currentUser.set('');
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'my-app', appType: 'angular', generatedBy: '' }));
      a.wizardStep.set(4);
      c['wizardNext']();
      expect(a.wizardPreview()).toContain('unknown');
    });

    it('wizardUpdate sets a field', () => {
      const c = make();
      c['wizardUpdate']('acceptanceCriteria', 'AC');
      expect(asAny(c).wizardAnswers().acceptanceCriteria).toBe('AC');
    });

    it('wizardOnAppTypeChange configures frontend/backend/infra defaults', () => {
      const c = make();
      const a = asAny(c);
      c['wizardOnAppTypeChange']('angular');
      expect(a.wizardAnswers().hasFrontend).toBe(true);
      c['wizardOnAppTypeChange']('node');
      expect(a.wizardAnswers().hasBackend).toBe(true);
      c['wizardOnAppTypeChange']('btp');
      expect(a.wizardAnswers().secretsManagerKeys).toContain('BTP_USERNAME');
      expect(a.wizardAnswers().includeInfra).toBe(true);
      c['wizardOnAppTypeChange']('cap');
      expect(a.wizardAnswers().secretsManagerKeys).toEqual(['CF_USER', 'CF_PASSWORD']);
      expect(a.wizardAnswers().includeInfra).toBe(false);
      c['wizardOnAppTypeChange']('ami');
      expect(a.wizardAnswers().amiComponents).toEqual(['']);
      c['wizardOnAppTypeChange']('html');
      expect(a.wizardAnswers().includeInfra).toBe(false);
    });

    it('wizardOnCloudChange clears an app type invalid for the cloud', () => {
      const c = make();
      const a = asAny(c);
      a.wizardAnswers.update((x: any) => ({ ...x, appType: 'ami' }));
      c['wizardOnCloudChange']('azure');
      expect(a.wizardAnswers().appType).toBe('');
    });

    it('deploy-target helpers', () => {
      const c = make();
      const a = asAny(c);
      a.wizardAnswers.update((x: any) => ({ ...x, appType: 'angular', cloudProvider: 'aws', includeInfra: false }));
      expect(c['wizardDeployTargetKeys']()).toContain('s3');
      expect(c['wizardShowDeployTargetKey']('s3')).toBe(true);
      expect(c['wizardShowDeployTargetSection']).toBe(true);
      c['wizardUpdateDeployTarget']('s3', 'my-bucket');
      expect(a.wizardAnswers().deployTarget.s3).toBe('my-bucket');
      a.wizardAnswers.update((x: any) => ({ ...x, appType: '' }));
      expect(c['wizardDeployTargetKeys']()).toEqual([]);
    });

    it('wizard secret key + component list mutators', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      c['wizardAddSecretKey']();
      c['wizardAddSecretKey']();
      c['wizardAddSecretKey']();
      tick();
      // Update index 1 in a 3-element list so the (i === index ? value : k) false-branch runs.
      c['wizardUpdateSecretKey'](1, 'K');
      expect(a.wizardAnswers().secretsManagerKeys[1]).toBe('K');
      c['wizardRemoveSecretKey'](0);
      expect(a.wizardAnswers().secretsManagerKeys.length).toBe(2);

      c['wizardAddComponent']();
      c['wizardAddComponent']();
      c['wizardAddComponent']();
      tick();
      c['wizardUpdateComponent'](1, 'C');
      expect(a.wizardAnswers().amiComponents[1]).toBe('C');
      c['wizardRemoveComponent'](0);
      expect(a.wizardAnswers().amiComponents.length).toBe(2);
    }));

    it('architecture toggles create and clear sub-objects', () => {
      const c = make();
      const a = asAny(c);
      c['wizardToggleFrontend'](true);
      expect(a.wizardAnswers().frontend).toBeTruthy();
      c['wizardToggleFrontend'](false);
      expect(a.wizardAnswers().frontend).toBeNull();

      c['wizardToggleBackend'](true);
      expect(a.wizardAnswers().backend).toBeTruthy();
      c['wizardToggleBackend'](false);
      expect(a.wizardAnswers().backend).toBeNull();

      c['wizardToggleDatabase'](true);
      expect(a.wizardAnswers().database).toBeTruthy();
      c['wizardToggleDatabase'](false);

      c['wizardToggleQueue'](true);
      expect(a.wizardAnswers().queue).toBeTruthy();
      c['wizardToggleQueue'](false);

      c['wizardToggleScheduler'](true);
      expect(a.wizardAnswers().needsScheduler).toBe(true);
      c['wizardToggleScheduler'](false);

      c['wizardToggleStorage'](true);
      expect(a.wizardAnswers().storage).toBeTruthy();
      c['wizardToggleStorage'](false);
    });

    it('architecture sub-object updaters', () => {
      const c = make();
      const a = asAny(c);
      c['wizardToggleFrontend'](true);
      c['wizardUpdateFrontend']('authClientId', 'cid');
      expect(a.wizardAnswers().frontend.authClientId).toBe('cid');

      c['wizardToggleBackend'](true);
      c['wizardUpdateBackend']('runtime', '20');
      expect(a.wizardAnswers().backend.runtime).toBe('20');

      c['wizardToggleDatabase'](true);
      c['wizardUpdateDatabase']('engine', 'dynamodb');
      expect(a.wizardAnswers().database.engine).toBe('dynamodb');

      c['wizardToggleQueue'](true);
      c['wizardUpdateQueue']('sns');
      expect(a.wizardAnswers().queue.kind).toBe('sns');

      c['wizardToggleStorage'](true);
      c['wizardUpdateStorage']('azure-blob');
      expect(a.wizardAnswers().storage.kind).toBe('azure-blob');
    });

    it('sub-object updaters are no-ops when the object is null', () => {
      const c = make();
      const a = asAny(c);
      c['wizardUpdateFrontend']('authClientId', 'x');
      c['wizardUpdateBackend']('runtime', 'x');
      c['wizardUpdateDatabase']('engine', 'postgres');
      c['wizardUpdateQueue']('sqs');
      c['wizardUpdateStorage']('s3');
      expect(a.wizardAnswers().frontend).toBeNull();
      expect(a.wizardAnswers().queue).toBeNull();
    });

    it('canWizardNext gates step 1 and step 3', () => {
      const c = make();
      const a = asAny(c);
      expect(c['canWizardNext']).toBe(false);
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'my-app', appType: 'angular' }));
      expect(c['canWizardNext']).toBe(true);
      a.wizardStep.set(3);
      a.wizardAnswers.update((x: any) => ({ ...x, appType: 'angular', includeInfra: true, cloudProvider: 'aws', awsAccountId: '123456789012', awsRegion: 'us-west-2' }));
      expect(c['canWizardNext']).toBe(true);
      a.wizardStep.set(2);
      expect(c['canWizardNext']).toBe(true);
    });

    it('validateWizardStep3 covers cap/btp/ami/azure/aws paths', () => {
      const c = make();
      const a = asAny(c);
      const set = (o: any) => a.wizardAnswers.update((x: any) => ({ ...x, ...o }));

      set({ appType: 'cap', awsAccountId: '123456789012', awsRegion: 'us-west-2', cfApi: 'a', cfOrg: 'o', cfSpace: 's', cfOrigin: 'i', secretsManagerName: 'sm' });
      expect(c['validateWizardStep3']()).toBe(true);

      set({ appType: 'btp', secretsManagerName: 'sm' });
      expect(c['validateWizardStep3']()).toBe(true);

      set({ appType: 'ami', amiComponents: ['server'] });
      expect(c['validateWizardStep3']()).toBe(true);

      set({ appType: 'angular', includeInfra: false });
      expect(c['validateWizardStep3']()).toBe(true);

      set({ appType: 'angular', includeInfra: true, cloudProvider: 'azure', azureSubscriptionId: 'abcdef00-1111-2222-3333-444455556666' });
      expect(c['validateWizardStep3']()).toBe(true);

      // includeInfra with a cloud that is neither aws nor azure → final `return true`.
      set({ appType: 'angular', includeInfra: true, cloudProvider: 'sap' });
      expect(c['validateWizardStep3']()).toBe(true);
    });

    it('wizardDownload and wizardCopy produce output; error path warns', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      a.wizardAnswers.update((x: any) => ({ ...x, appName: 'my-app', appType: 'angular' }));
      spyOn(URL, 'createObjectURL').and.returnValue('blob:x');
      spyOn(URL, 'revokeObjectURL');
      spyOn(HTMLAnchorElement.prototype, 'click');
      c['wizardDownload']();
      expect(a.toastMessage()).toContain('epic.md downloaded');

      const writeText = spyOn(navigator.clipboard, 'writeText').and.resolveTo();
      c['wizardCopy']();
      flushMicrotasks();
      expect(writeText).toHaveBeenCalled();

      a.epicInfraLoadError.set(true);
      c['wizardDownload']();
      expect(a.toastMessage()).toContain('failed to load');
      c['wizardCopy']();
      expect(a.toastMessage()).toContain('failed to load');
    }));
  });

  // ── Toast ──────────────────────────────────────────────────────────────────────

  describe('toast', () => {
    it('getRunUrl builds an ADO URL', () => {
      expect(make()['getRunUrl'](42)).toContain('buildId=42');
    });

    it('showToast auto-dismisses; dismiss/pause/resume manage the timer', fakeAsync(() => {
      const c = make();
      const a = asAny(c);
      c['showToast']('hi');
      expect(a.toastMessage()).toBe('hi');
      c['pauseToast']();
      c['resumeToast']();
      tick(5000);
      expect(a.toastMessage()).toBeNull();

      c['showToast']('again');
      c['dismissToast']();
      expect(a.toastMessage()).toBeNull();
    }));
  });

  describe('ngOnDestroy', () => {
    it('tears down timers and subjects', () => {
      const c = make();
      asAny(c).startAutoRefresh();
      c['showToast']('x');
      expect(() => c.ngOnDestroy()).not.toThrow();
    });
  });
});
