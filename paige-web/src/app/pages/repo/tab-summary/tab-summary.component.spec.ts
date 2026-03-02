import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { of, throwError } from 'rxjs';
import { TabSummaryComponent } from './tab-summary.component';

jest.mock('~/services/scan.service', () => ({
	ScanService: jest.fn().mockImplementation(() => ({
		scan: jest.fn()
	}))
}));

jest.mock('~/pages/base.component', () => ({
	BaseComponent: class {
		isLoading = false;
		async initAsync() { }
	}
}));

import { ScanService } from '~/services/scan.service';

describe('TabSummaryComponent', () => {
	let component: TabSummaryComponent;
	let fixture: ComponentFixture<TabSummaryComponent>;
	let mockRouter: any;
	let mockScanService: any;

	const mockRepoData = {
		summary: {
			structure: {
				repoName: 'test-repo',
				branch: 'main'
			}
		}
	};

	beforeEach(async () => {
		mockRouter = {
			navigate: jest.fn().mockResolvedValue(true)
		};

		mockScanService = {
			scan: jest.fn()
		};

		await TestBed.configureTestingModule({
			imports: [TabSummaryComponent],
			providers: [
				{ provide: Router, useValue: mockRouter },
				{ provide: ScanService, useValue: mockScanService }
			],
			schemas: [NO_ERRORS_SCHEMA]
		}).compileComponents();

		fixture = TestBed.createComponent(TabSummaryComponent);
		component = fixture.componentInstance;
	});

	//*************************************************************************
	//  Default Property Values
	//*************************************************************************
	describe('Default Property Values', () => {
		it('should create the component', () => {
			expect(component).toBeTruthy();
		});

		it('should initialize repoData as null', () => {
			expect(component.repoData).toBeNull();
		});

		it('should initialize isAnalyzing as false', () => {
			expect(component.isAnalyzing).toBe(false);
		});
	});

	//*************************************************************************
	//  convert
	//*************************************************************************
	describe('convert', () => {
		beforeEach(() => {
			component.repoData = JSON.parse(JSON.stringify(mockRepoData));
		});

		it('should set isAnalyzing to true immediately when called', () => {
			const delayedObservable = new Promise(() => { });
			mockScanService.scan.mockReturnValue({ subscribe: jest.fn() });

			component.convert();

			expect(component.isAnalyzing).toBe(true);
		});

		it('should call scanService.scan with repoName and branch from repoData', () => {
			mockScanService.scan.mockReturnValue(of({}));

			component.convert();

			expect(mockScanService.scan).toHaveBeenCalledWith({
				repoName: 'test-repo',
				branch: 'main'
			});
		});

		it('should set isAnalyzing to false and navigate to /cfn on success', () => {
			const mockResponse = { terraform: 'output' };
			mockScanService.scan.mockReturnValue(of(mockResponse));

			component.convert();

			expect(component.isAnalyzing).toBe(false);
			expect(mockRouter.navigate).toHaveBeenCalledWith(['/cfn'], {
				state: {
					repoData: component.repoData,
					data: mockResponse
				}
			});
		});

		it('should set isAnalyzing to false on error', () => {
			mockScanService.scan.mockReturnValue(throwError(() => new Error('API Error')));

			component.convert();

			expect(component.isAnalyzing).toBe(false);
			expect(mockRouter.navigate).not.toHaveBeenCalled();
		});
	});
});