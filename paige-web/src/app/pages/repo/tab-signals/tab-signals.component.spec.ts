import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { TabSignalsComponent } from './tab-signals.component';

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

describe('TabSignalsComponent', () => {
	let component: TabSignalsComponent;
	let fixture: ComponentFixture<TabSignalsComponent>;
	let mockRouter: any;
	let mockScanService: any;

	beforeEach(async () => {
		mockRouter = {
			navigate: jest.fn().mockResolvedValue(true)
		};

		mockScanService = {
			scan: jest.fn()
		};

		await TestBed.configureTestingModule({
			imports: [TabSignalsComponent],
			providers: [
				{ provide: Router, useValue: mockRouter },
				{ provide: ScanService, useValue: mockScanService }
			],
			schemas: [NO_ERRORS_SCHEMA]
		}).compileComponents();

		fixture = TestBed.createComponent(TabSignalsComponent);
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
});