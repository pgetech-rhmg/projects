import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router, Navigation, ActivatedRoute } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { of, throwError } from 'rxjs';
import { RepoResultsComponent } from './repo-results.component';

jest.mock('~/core/app.component', () => ({
	AppComponent: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/services/repo.service', () => ({
	RepoService: jest.fn().mockImplementation(() => ({
		analyze: jest.fn()
	}))
}));

jest.mock('~/core/services/appconfig.service', () => ({
	AppConfigService: jest.fn().mockImplementation(() => ({
		getConfig: jest.fn()
	}))
}));

jest.mock('~/core/services/appsettings.service', () => ({
	AppSettingsService: jest.fn().mockImplementation(() => ({
		getSettings: jest.fn()
	}))
}));

jest.mock('~/core/services/activity.service', () => ({
	ActivityService: jest.fn().mockImplementation(() => ({
		SaveActivity: jest.fn()
	}))
}));

jest.mock('~/pages/base.component', () => ({
	BaseComponent: class {
		isLoading = false;
		async initAsync() { }
	}
}));

import { AppComponent } from '~/core/app.component';
import { RepoService } from '~/services/repo.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

describe('RepoResultsComponent', () => {
	let component: RepoResultsComponent;
	let fixture: ComponentFixture<RepoResultsComponent>;
	let mockRouter: any;
	let mockRepoService: any;
	let mockActivatedRoute: any;

	const mockResponseData = {
		repo: {
			repoName: 'test-repo',
			branch: 'main'
		},
		analysis: null,
		aiAssessment: null
	};

	const mockResponseWithAnalysis = {
		repo: {
			repoName: 'test-repo',
			branch: 'main'
		},
		analysis: { output: 'existing analysis output' },
		aiAssessment: null
	};

	beforeEach(async () => {
		mockRouter = {
			currentNavigation: jest.fn(),
			navigate: jest.fn().mockResolvedValue(true),
			url: '/repo-results'
		};

		mockRepoService = {
			analyze: jest.fn()
		};

		mockActivatedRoute = {
			snapshot: {},
			params: of({}),
			queryParams: of({})
		};

		await TestBed.configureTestingModule({
			imports: [RepoResultsComponent],
			providers: [
				{ provide: Router, useValue: mockRouter },
				{ provide: ActivatedRoute, useValue: mockActivatedRoute },
				{ provide: AppComponent, useValue: {} },
				{ provide: RepoService, useValue: mockRepoService },
				{ provide: AppConfigService, useValue: { getConfig: jest.fn() } },
				{ provide: AppSettingsService, useValue: { getSettings: jest.fn() } },
				{ provide: ActivityService, useValue: { SaveActivity: jest.fn() } }
			],
			schemas: [NO_ERRORS_SCHEMA]
		}).compileComponents();
	});

	function createComponent(navState: any) {
		mockRouter.currentNavigation.mockReturnValue(navState);
		fixture = TestBed.createComponent(RepoResultsComponent);
		component = fixture.componentInstance;
		(component as any).repoService = mockRepoService;
	}

	//*************************************************************************
	//  Constructor
	//*************************************************************************
	describe('Constructor', () => {
		it('should create with navigation state data and set isLoading true', () => {
			createComponent({ extras: { state: { data: mockResponseData } } });

			expect(component).toBeTruthy();
			expect(component.isLoading).toBe(true);
			expect(component.response).toEqual(mockResponseData);
		});

		it('should initialize tabs with summary and signals inputs when data is present', () => {
			createComponent({ extras: { state: { data: mockResponseData } } });

			expect(component.tabs[0].inputs).toEqual({ repoData: mockResponseData });
			expect(component.tabs[1].inputs).toEqual({ repoData: mockResponseData });
		});

		it('should set analysis tab isAnalyzing true when no analysis exists', () => {
			createComponent({ extras: { state: { data: mockResponseData } } });

			expect(component.tabs[2].inputs).toEqual({ isAnalyzing: true, output: null });
		});

		it('should set analysis tab isAnalyzing false when analysis exists', () => {
			createComponent({ extras: { state: { data: mockResponseWithAnalysis } } });

			expect(component.tabs[2].inputs).toEqual({
				isAnalyzing: false,
				output: mockResponseWithAnalysis.analysis
			});
		});

		it('should wire setAiAssessment output on analysis tab', () => {
			createComponent({ extras: { state: { data: mockResponseData } } });

			const aiOutput = { result: 'ai result' };
			component.tabs[2].outputs['setAiAssessment'](aiOutput);

			expect(component.response.aiAssessment).toEqual({ output: aiOutput });
			expect(component.tabs[0].inputs).toEqual({ repoData: component.response });
		});

		it('should navigate to /repo when no state data', () => {
			createComponent({ extras: { state: {} } });

			expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
		});

		it('should navigate to /repo when state is undefined', () => {
			createComponent({ extras: { state: undefined } });

			expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
		});

		it('should navigate to /repo when extras is empty', () => {
			createComponent({ extras: {} });

			expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
		});

		it('should navigate to /repo when navigation is null', () => {
			createComponent(null);

			expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
		});
	});

	//*************************************************************************
	//  Default Property Values
	//*************************************************************************
	describe('Default Property Values', () => {
		beforeEach(() => createComponent(null));

		it('should initialize response as null', () => {
			expect(component.response).toBeNull();
		});

		it('should initialize groupedEntries as empty object', () => {
			expect(component.groupedEntries).toEqual({});
		});

		it('should initialize messageStyle as empty string', () => {
			expect(component.messageStyle).toBe('');
		});

		it('should initialize username as empty string', () => {
			expect(component.username).toBe('');
		});

		it('should initialize analysisRan as false', () => {
			expect(component.analysisRan).toBe(false);
		});

		it('should initialize activeTab as first tab', () => {
			expect(component.activeTab).toBe(component.tabs[0]);
		});

		it('should initialize with 3 tabs', () => {
			expect(component.tabs).toHaveLength(3);
			expect(component.tabs[0].title).toBe('Summary');
			expect(component.tabs[1].title).toBe('Signals');
			expect(component.tabs[2].title).toBe('Analysis');
		});
	});

	//*************************************************************************
	//  ngOnInit
	//*************************************************************************
	describe('ngOnInit', () => {
		beforeEach(() => {
			createComponent({ extras: { state: { data: mockResponseData } } });
		});

		it('should call initAsync and set isLoading to false', async () => {
			jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

			component.ngOnInit();
			await fixture.whenStable();

			expect((component as any).initAsync).toHaveBeenCalled();
			expect(component.isLoading).toBe(false);
		});
	});

	//*************************************************************************
	//  setActiveTab
	//*************************************************************************
	describe('setActiveTab', () => {
		beforeEach(() => {
			createComponent({ extras: { state: { data: mockResponseData } } });
		});

		it('should set activeTab to the incoming tab', () => {
			const event = { to: component.tabs[1] };
			component.setActiveTab(event);

			expect(component.activeTab).toBe(component.tabs[1]);
		});

		it('should trigger analyze when switching to Analysis tab for first time with no analysis', () => {
			const analyzeSpy = jest.spyOn(component as any, 'analyze').mockImplementation(() => { });
			const event = { to: component.tabs[2] };

			component.setActiveTab(event);

			expect(analyzeSpy).toHaveBeenCalled();
			expect(component.analysisRan).toBe(true);
		});

		it('should not trigger analyze when switching to Analysis tab a second time', () => {
			const analyzeSpy = jest.spyOn(component as any, 'analyze').mockImplementation(() => { });
			const event = { to: component.tabs[2] };

			component.setActiveTab(event);
			component.setActiveTab(event);

			expect(analyzeSpy).toHaveBeenCalledTimes(1);
		});

		it('should not trigger analyze when switching to Analysis tab if analysis already exists', () => {
			createComponent({ extras: { state: { data: mockResponseWithAnalysis } } });
			(component as any).repoService = mockRepoService;

			const analyzeSpy = jest.spyOn(component as any, 'analyze').mockImplementation(() => { });
			const event = { to: component.tabs[2] };

			component.setActiveTab(event);

			expect(analyzeSpy).not.toHaveBeenCalled();
		});

		it('should update analysis tab inputs when analysis already exists', () => {
			createComponent({ extras: { state: { data: mockResponseWithAnalysis } } });
			(component as any).repoService = mockRepoService;

			const event = { to: component.tabs[2] };
			component.setActiveTab(event);

			expect(component.tabs[2].inputs).toEqual({
				isAnalyzing: false,
				output: mockResponseWithAnalysis.analysis
			});
		});

		it('should set isAnalyzing true when switching to Analysis with no analysis and already ran', () => {
			component.analysisRan = true;
			const event = { to: component.tabs[2] };
			component.setActiveTab(event);

			expect(component.tabs[2].inputs).toEqual({ isAnalyzing: true, output: null });
		});

		it('should set activeTab when switching to non-Analysis tab', () => {
			const event = { to: component.tabs[0] };
			component.setActiveTab(event);

			expect(component.activeTab).toBe(component.tabs[0]);
		});
	});

	//*************************************************************************
	//  back
	//*************************************************************************
	describe('back', () => {
		beforeEach(() => {
			createComponent({ extras: { state: { data: mockResponseData } } });
			mockRouter.navigate.mockClear();
		});

		it('should navigate to /repo with repoName and branch from response', () => {
			component.back();

			expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], {
				state: {
					data: {
						repository: 'test-repo',
						branch: 'main'
					}
				}
			});
		});
	});

	//*************************************************************************
	//  analyze (private)
	//*************************************************************************
    describe('analyze (private)', () => {
        beforeEach(() => {
            createComponent({ extras: { state: { data: mockResponseData } } });
            // Reset response to a clean deep copy to avoid state pollution from prior tests
            component.response = JSON.parse(JSON.stringify(mockResponseData));
        });

		it('should return early when repoName is empty', () => {
			component.response.repo.repoName = '';
			component.isLoading = true;

			(component as any).analyze();

			expect(mockRepoService.analyze).not.toHaveBeenCalled();
			expect(component.isLoading).toBe(false);
		});

		it('should return early when branch is empty', () => {
			component.response.repo.branch = '';
			component.isLoading = true;

			(component as any).analyze();

			expect(mockRepoService.analyze).not.toHaveBeenCalled();
			expect(component.isLoading).toBe(false);
		});

		it('should call repoService.analyze with the current response', () => {
			mockRepoService.analyze.mockReturnValue(of({ output: 'analysis result' }));

			(component as any).analyze();

			expect(mockRepoService.analyze).toHaveBeenCalledWith(component.response);
		});

		it('should update response.analysis and tab inputs on success', () => {
			const analysisOutput = 'analysis result';
			mockRepoService.analyze.mockReturnValue(of({ output: analysisOutput }));

			(component as any).analyze();

			expect(component.response.analysis).toBe(analysisOutput);
			expect(component.isLoading).toBe(false);
			expect(component.tabs[0].inputs).toEqual({ repoData: component.response });
			expect(component.tabs[1].inputs).toEqual({ repoData: component.response });
			expect(component.tabs[2].inputs).toEqual({ isAnalyzing: false, output: analysisOutput });
		});

		it('should not update tabs when response output is falsy', () => {
			mockRepoService.analyze.mockReturnValue(of({ output: null }));
			const originalTab0Inputs = { ...component.tabs[0].inputs };

			(component as any).analyze();

			expect(component.isLoading).toBe(false);
			expect(component.tabs[0].inputs).toEqual(originalTab0Inputs);
		});

		it('should set isLoading false on error', () => {
			mockRepoService.analyze.mockReturnValue(throwError(() => new Error('API Error')));
			component.isLoading = true;

			(component as any).analyze();

			expect(component.isLoading).toBe(false);
		});
	});
});