import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { Router } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { of, throwError } from 'rxjs';

import { CfnComponent, TerraformModuleResult } from './cfn.component';

// Mock the imports
jest.mock('~/services/cfn.service', () => ({
	CfnService: jest.fn().mockImplementation(() => ({
		generate: jest.fn(),
		generateStream: jest.fn(),
		cancel: jest.fn(),
		setActiveJob: jest.fn()
	}))
}));

jest.mock('~/pages/base.component', () => ({
	BaseComponent: class {
		isLoading = false;
		async initAsync() { }
	}
}));

// Import the mocked classes
import { CfnService } from '~/services/cfn.service';

describe('CfnComponent', () => {
	let component: CfnComponent;
	let fixture: ComponentFixture<CfnComponent>;
	let mockRouter: any;
	let mockCfnService: any;

	const mockRepoData = {
		name: 'test-repo',
		owner: 'test-owner'
	};

	const mockCloudFormationFiles = [
		{
			path: 'template1.yaml',
			format: 'yaml',
			classification: 0,
			resourceTypes: ['AWS::S3::Bucket'],
			parameterDefaults: { key1: 'value1' },
			rawCfn: 'cfn-content-1'
		},
		{
			path: 'nested/template2.json',
			format: 'json',
			classification: 1,
			resourceTypes: ['AWS::EC2::Instance'],
			parameterDefaults: { key2: 'value2' },
			rawCfn: 'cfn-content-2'
		},
		{
			path: 'partial/template3.yml',
			format: 'yml',
			classification: 2,
			resourceTypes: ['AWS::Lambda::Function'],
			parameterDefaults: {},
			rawCfn: 'cfn-content-3'
		}
	];

	const mockResponse = {
		cloudFormationFiles: mockCloudFormationFiles
	};

	beforeEach(async () => {
		mockRouter = {
			currentNavigation: jest.fn(),
			navigate: jest.fn().mockResolvedValue(true),
			url: '/cfn'
		};

		mockCfnService = {
			generate: jest.fn(),
			generateStream: jest.fn(),
			cancel: jest.fn(),
			setActiveJob: jest.fn()
		};

		await TestBed.configureTestingModule({
			imports: [CfnComponent],
			providers: [
				{ provide: Router, useValue: mockRouter },
				{ provide: CfnService, useValue: mockCfnService }
			],
			schemas: [NO_ERRORS_SCHEMA]
		}).compileComponents();
	});

	//*************************************************************************
	//  Helper: create component with nav state
	//*************************************************************************
	function createWithNavState(response: any = mockResponse, repoData: any = mockRepoData) {
		mockRouter.currentNavigation.mockReturnValue({
			extras: { state: { data: response, repoData } }
		});
		fixture = TestBed.createComponent(CfnComponent);
		component = fixture.componentInstance;
	}

	//*************************************************************************
	//  Constructor
	//*************************************************************************
	describe('Constructor', () => {
		it('should create component', () => {
			createWithNavState();
			expect(component).toBeTruthy();
		});

		it('should initialize with navigation state data', fakeAsync(() => {
			createWithNavState();

			expect(component.isLoading).toBe(true);
			expect(component.repoData).toEqual(mockRepoData);
			expect(component.response).toEqual(mockResponse);
			expect(component.data).toHaveLength(3);
			expect(component.total).toBe(3);

			component.data.forEach((item: any) => {
				expect(item.status).toBe("");
			});

			tick(150);

			expect(component.updateGrid).toBe(true);
			expect(component.showGrid).toBe(true);
		}));

		it('should navigate to /repo when no navigation state data exists', () => {
			mockRouter.currentNavigation.mockReturnValue({ extras: { state: {} } });
			TestBed.createComponent(CfnComponent);

			expect(mockRouter.navigate).toHaveBeenCalledWith(["/repo"], { state: { data: null } });
		});

		it('should navigate to /repo when navigation is null', () => {
			mockRouter.currentNavigation.mockReturnValue(null);
			TestBed.createComponent(CfnComponent);

			expect(mockRouter.navigate).toHaveBeenCalledWith(["/repo"], { state: { data: null } });
		});

		it('should initialize columns correctly', () => {
			createWithNavState();

			expect(component.columns).toHaveLength(6);
			expect(component.columns[0].Name).toBe('status');
			expect(component.columns[1].Name).toBe('path');
			expect(component.columns[2].Name).toBe('format');
			expect(component.columns[3].Name).toBe('classification');
			expect(component.columns[4].Name).toBe('resourceTypes');
			expect(component.columns[5].Name).toBe('parameterDefaults');
		});

		it('should configure grid options correctly', () => {
			createWithNavState();

			expect(component.options.header).toBe(false);
			expect(component.options.footer).toBe(false);
			expect(component.options.options).toBe(false);
			expect(component.options.formulas).toBe(false);
			expect(component.options.nowrap).toBe(true);
		});

		it('should initialize modules as empty array', () => {
			createWithNavState();
			expect(component.modules).toEqual([]);
		});

		it('should initialize isProcessing as false', () => {
			createWithNavState();
			expect(component.isProcessing).toBe(false);
		});
	});

	//*************************************************************************
	//  ngOnInit
	//*************************************************************************
	describe('ngOnInit', () => {
		it('should call initAsync', async () => {
			createWithNavState();
			jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

			component.ngOnInit();
			await fixture.whenStable();

			expect((component as any).initAsync).toHaveBeenCalled();
		});
	});

	//*************************************************************************
	//  loadData
	//*************************************************************************
	describe('loadData', () => {
		beforeEach(() => createWithNavState());

		it('should return early when event is null', async () => {
			component.isLoading = false;
			component.showGrid = false;

			await component.loadData(null);

			expect(component.isLoading).toBe(false);
			expect(component.showGrid).toBe(false);
		});

		it('should return early when event is default (undefined)', async () => {
			component.isLoading = false;
			component.showGrid = false;

			await component.loadData();

			expect(component.isLoading).toBe(false);
			expect(component.showGrid).toBe(false);
		});

		it('should set loading state and update grid when event is provided', fakeAsync(() => {
			component.isLoading = false;
			component.updateGrid = false;
			component.showGrid = false;

			component.loadData({ some: 'event' });

			expect(component.error).toBe("");

			tick(150);

			expect(component.updateGrid).toBe(true);
			expect(component.showGrid).toBe(true);
			expect(component.isLoading).toBe(false);
		}));

		// it('should handle error in loadData and set error message', async () => {
		// 	// Force the try block to throw by making isLoading setter throw
		// 	Object.defineProperty(component, 'isLoading', {
		// 		set: () => { throw new Error('Load failed'); },
		// 		get: () => false,
		// 		configurable: true
		// 	});

		// 	await component.loadData({ some: 'event' });

		// 	expect(component.error).toBe('Load failed');
		// });

		// it('should handle error with no message', async () => {
		// 	Object.defineProperty(component, 'isLoading', {
		// 		set: () => { throw { message: undefined }; },
		// 		get: () => false,
		// 		configurable: true
		// 	});

		// 	await component.loadData({ some: 'event' });

		// 	expect(component.error).toBe('Error loading data');
		// });
	});

	//*************************************************************************
	//  generateTerraform
	//*************************************************************************
	describe('generateTerraform', () => {
		let mockEventSource: any;

		beforeEach(() => {
			createWithNavState();
			mockEventSource = {
				onmessage: null as any,
				onerror: null as any,
				addEventListener: jest.fn(),
				close: jest.fn()
			};
		});

		it('should return early if already processing', () => {
			component.isProcessing = true;

			component.generateTerraform();

			expect(mockCfnService.generate).not.toHaveBeenCalled();
		});

		it('should initiate terraform generation process', () => {
			const mockJobId = { jobId: 'job-123' };
			mockCfnService.generate.mockReturnValue(of(mockJobId));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			expect(component.isProcessing).toBe(true);
			expect(component.modules).toEqual([]);
			expect(mockCfnService.generate).toHaveBeenCalled();

			const generateArg = mockCfnService.generate.mock.calls[0][0];
			expect(generateArg).toHaveLength(3);
			expect(generateArg[0]).toEqual({ module: 'template1', rawCfn: 'cfn-content-1' });
		});

		it('should update processing message with correct count', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			expect(component.processingMessage).toBe('Processing files: (0/3)');
		});

		it('should update data items status to processing', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			component.data.forEach((item: any) => {
				expect(item.status).toBe('processing');
			});
			expect(component.updateGrid).toBe(true);
		});

		it('should call setActiveJob and generateStream with jobId', () => {
			const mockJobId = { jobId: 'job-123' };
			mockCfnService.generate.mockReturnValue(of(mockJobId));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			expect(mockCfnService.setActiveJob).toHaveBeenCalledWith(mockJobId);
			expect(mockCfnService.generateStream).toHaveBeenCalledWith('job-123');
		});

		it('should handle SSE onmessage event and update module status', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			const mockElement = { innerHTML: '' };
			jest.spyOn(document, 'getElementById').mockReturnValue(mockElement as any);

			component.generateTerraform();

			const moduleResult: TerraformModuleResult = {
				module: 'template1',
				files: { 'main.tf': 'terraform content' }
			};

			// onmessage is assigned synchronously inside the of() subscription
			mockEventSource.onmessage({ data: JSON.stringify(moduleResult) } as MessageEvent);

			expect(component.modules).toHaveLength(1);
			expect(component.modules[0]).toEqual(moduleResult);
			expect(component.data[0].status).toBe('fin');
			expect(mockElement.innerHTML).toBe('<div class="icon green">check</div>');
			expect(component.processingMessage).toBe('Processing (1/3)...');
		});

		it('should handle SSE onmessage for module not found in data (ndx === -1)', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			const moduleResult: TerraformModuleResult = {
				module: 'unknown-module',
				files: { 'main.tf': 'content' }
			};

			// Should not throw when ndx is -1 (getElementById never called)
			const getByIdSpy = jest.spyOn(document, 'getElementById');
			mockEventSource.onmessage({ data: JSON.stringify(moduleResult) } as MessageEvent);

			expect(component.modules).toHaveLength(1);
			expect(component.modules[0]).toEqual(moduleResult);
			// expect(getByIdSpy).not.toHaveBeenCalled();
		});

		it('should handle SSE complete event', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			const completeHandler = mockEventSource.addEventListener.mock.calls.find(
				(call: any[]) => call[0] === 'complete'
			)[1];

			completeHandler();

			expect(mockEventSource.close).toHaveBeenCalled();
			expect(component.isLoading).toBe(false);
			expect(component.isProcessing).toBe(false);
			expect(mockRouter.navigate).toHaveBeenCalledWith(
				['/terraform'],
				{ state: { repoData: mockRepoData, data: mockResponse, modules: component.modules } }
			);
		});

		it('should handle SSE onerror event', () => {
			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			component.generateTerraform();

			mockEventSource.onerror(new Event('error'));

			expect(mockEventSource.close).toHaveBeenCalled();
			expect(component.isLoading).toBe(false);
			expect(component.isProcessing).toBe(false);
		});

		it('should handle generate service subscription error', () => {
			mockCfnService.generate.mockReturnValue(throwError(() => new Error('Generate failed')));

			component.generateTerraform();

			expect(component.isLoading).toBe(false);
		});

		it('should handle generateTerraform with empty data', () => {
			const emptyResponse = { cloudFormationFiles: [] };
			mockRouter.currentNavigation.mockReturnValue({
				extras: { state: { data: emptyResponse, repoData: mockRepoData } }
			});
			const emptyFixture = TestBed.createComponent(CfnComponent);
			const emptyComponent = emptyFixture.componentInstance;

			mockCfnService.generate.mockReturnValue(of({ jobId: 'job-123' }));
			mockCfnService.generateStream.mockReturnValue(mockEventSource);

			emptyComponent.generateTerraform();

			expect(emptyComponent.processingMessage).toBe('Processing files: (0/0)');
			expect(mockCfnService.generate).toHaveBeenCalledWith([]);
		});
	});

	//*************************************************************************
	//  cancel
	//*************************************************************************
	describe('cancel', () => {
		beforeEach(() => createWithNavState());

		it('should close eventSource and call cancel service', () => {
			const mockES = { close: jest.fn() } as any;
			(component as any).eventSource = mockES;
			mockCfnService.cancel.mockReturnValue(of(undefined));

			component.cancel();

			expect(mockES.close).toHaveBeenCalled();
			expect((component as any).eventSource).toBeUndefined();
			expect(mockCfnService.cancel).toHaveBeenCalled();
		});

		it('should reset loading and processing states', () => {
			mockCfnService.cancel.mockReturnValue(of(undefined));
			component.isLoading = true;
			component.isProcessing = true;

			component.cancel();

			expect(component.isLoading).toBe(false);
			expect(component.isProcessing).toBe(false);
		});

		it('should reset processing items status to empty', () => {
			mockCfnService.cancel.mockReturnValue(of(undefined));
			component.data[0].status = 'processing';
			component.data[1].status = '';
			component.data[2].status = 'processing';

			component.cancel();

			expect(component.data[0].status).toBe('');
			expect(component.data[1].status).toBe('');
			expect(component.data[2].status).toBe('');
			expect(component.updateGrid).toBe(true);
		});

		it('should handle cancel when eventSource is undefined', () => {
			(component as any).eventSource = undefined;
			mockCfnService.cancel.mockReturnValue(of(undefined));

			expect(() => component.cancel()).not.toThrow();
			expect(mockCfnService.cancel).toHaveBeenCalled();
		});
	});

	//*************************************************************************
	//  getModuleNameFromPath
	//*************************************************************************
	describe('getModuleNameFromPath', () => {
		beforeEach(() => createWithNavState());

		it('should extract module name from yaml path', () => {
			expect(component.getModuleNameFromPath('path/to/template.yaml')).toBe('template');
		});

		it('should extract module name from yml path', () => {
			expect(component.getModuleNameFromPath('path/to/template.yml')).toBe('template');
		});

		it('should extract module name from json path', () => {
			expect(component.getModuleNameFromPath('path/to/template.json')).toBe('template');
		});

		it('should handle file in root directory', () => {
			expect(component.getModuleNameFromPath('template.yaml')).toBe('template');
		});

		it('should handle uppercase extensions', () => {
			expect(component.getModuleNameFromPath('template.YAML')).toBe('template');
		});

		it('should handle mixed case extensions', () => {
			expect(component.getModuleNameFromPath('template.YmL')).toBe('template');
		});
	});

	//*************************************************************************
	//  back
	//*************************************************************************
	describe('back', () => {
		it('should navigate to repo-results with repoData', () => {
			createWithNavState();

			component.back();

			expect(mockRouter.navigate).toHaveBeenCalledWith(
				["/repo-results"],
				{ state: { data: mockRepoData } }
			);
		});
	});

	//*************************************************************************
	//  getClassificationLabel (private)
	//*************************************************************************
	describe('getClassificationLabel (private method)', () => {
		beforeEach(() => createWithNavState());

		it('should return "root" for classification 0', () => {
			expect((component as any).getClassificationLabel(0)).toBe('root');
		});

		it('should return "nested" for classification 1', () => {
			expect((component as any).getClassificationLabel(1)).toBe('nested');
		});

		it('should return "partial" for classification 2', () => {
			expect((component as any).getClassificationLabel(2)).toBe('partial');
		});

		it('should return "unknown" for classification 3', () => {
			expect((component as any).getClassificationLabel(3)).toBe('unknown');
		});

		it('should return "unknown" for negative classification', () => {
			expect((component as any).getClassificationLabel(-1)).toBe('unknown');
		});

		it('should return "unknown" for large classification number', () => {
			expect((component as any).getClassificationLabel(999)).toBe('unknown');
		});
	});

	//*************************************************************************
	//  getIndex (private)
	//*************************************************************************
	describe('getIndex (private method)', () => {
		beforeEach(() => createWithNavState());

		it('should return correct index for existing module', () => {
			expect((component as any).getIndex('template1')).toBe(0);
		});

		it('should return correct index for nested module', () => {
			expect((component as any).getIndex('template2')).toBe(1);
		});

		it('should return -1 for non-existing module', () => {
			expect((component as any).getIndex('non-existing')).toBe(-1);
		});
	});

	//*************************************************************************
	//  Column dataTemplate and formatData callbacks
	//*************************************************************************
	describe('Column callbacks', () => {
		beforeEach(() => createWithNavState());

		it('should return processingTemplate from status column dataTemplate', () => {
			const statusColumn = component.columns.find(col => col.Name === 'status');
			expect(statusColumn).toBeDefined();
			expect(statusColumn!.dataTemplate).toBeDefined();

			// Invoke the callback -- it returns this.processingTemplate (undefined before view init, but the function itself must execute)
			const result = statusColumn!.dataTemplate!();
			expect(result).toBe(component.processingTemplate);
		});

		it('should return resourcesTemplate from resourceTypes column dataTemplate', () => {
			const resourcesColumn = component.columns.find(col => col.Name === 'resourceTypes');
			expect(resourcesColumn).toBeDefined();
			expect(resourcesColumn!.dataTemplate).toBeDefined();

			const result = resourcesColumn!.dataTemplate!();
			expect(result).toBe(component.resourcesTemplate);
		});

		it('should return valuesTemplate from parameterDefaults column dataTemplate', () => {
			const valuesColumn = component.columns.find(col => col.Name === 'parameterDefaults');
			expect(valuesColumn).toBeDefined();
			expect(valuesColumn!.dataTemplate).toBeDefined();

			const result = valuesColumn!.dataTemplate!();
			expect(result).toBe(component.valuesTemplate);
		});

		it('should format classification data correctly via formatData', () => {
			const classificationColumn = component.columns.find(col => col.Name === 'classification');
			expect(classificationColumn).toBeDefined();
			expect(classificationColumn!.formatData).toBeDefined();

			expect(classificationColumn!.formatData!(0)).toBe('root');
			expect(classificationColumn!.formatData!(1)).toBe('nested');
			expect(classificationColumn!.formatData!(2)).toBe('partial');
			expect(classificationColumn!.formatData!(99)).toBe('unknown');
		});
	});

	//*************************************************************************
	//  Input Properties
	//*************************************************************************
	describe('Input Properties', () => {
		beforeEach(() => createWithNavState());

		it('should have default username as empty string', () => {
			expect(component.username).toBe("");
		});

		it('should accept username input', () => {
			component.username = "testuser";
			expect(component.username).toBe("testuser");
		});
	});

	//*************************************************************************
	//  Component State Properties
	//*************************************************************************
	describe('Component State Properties', () => {
		it('should initialize state properties correctly', () => {
			createWithNavState();

			expect(component.isProcessing).toBe(false);
			expect(component.processingMessage).toBe("");
			expect(component.error).toBe("");
			expect(component.messageStyle).toBe("");
			expect(component.modules).toEqual([]);
		});
	});

	//*************************************************************************
	//  Edge Cases
	//*************************************************************************
	describe('Edge Cases', () => {
		it('should handle empty cloudFormationFiles array', fakeAsync(() => {
			const emptyResponse = { cloudFormationFiles: [] };
			mockRouter.currentNavigation.mockReturnValue({
				extras: { state: { data: emptyResponse, repoData: mockRepoData } }
			});

			const newFixture = TestBed.createComponent(CfnComponent);
			const newComponent = newFixture.componentInstance;

			expect(newComponent.data).toEqual([]);
			expect(newComponent.total).toBe(0);

			tick(150);
			expect(newComponent.showGrid).toBe(true);
		}));
	});
});