import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { TabAnalysisComponent } from './tab-analysis.component';

jest.mock('~/services/markdown.service', () => ({
	MarkdownService: jest.fn().mockImplementation(() => ({
		render: jest.fn()
	}))
}));

jest.mock('~/pages/base.component', () => ({
	BaseComponent: class {
		isLoading = false;
		async initAsync() { }
	}
}));

import { MarkdownService } from '~/services/markdown.service';

describe('TabAnalysisComponent', () => {
	let component: TabAnalysisComponent;
	let fixture: ComponentFixture<TabAnalysisComponent>;
	let mockMarkdownService: any;

	beforeEach(async () => {
		mockMarkdownService = {
			render: jest.fn().mockReturnValue('<p>rendered</p>')
		};

		await TestBed.configureTestingModule({
			imports: [TabAnalysisComponent],
			providers: [
				{ provide: MarkdownService, useValue: mockMarkdownService }
			],
			schemas: [NO_ERRORS_SCHEMA]
		}).compileComponents();

		fixture = TestBed.createComponent(TabAnalysisComponent);
		component = fixture.componentInstance;
	});

	//*************************************************************************
	//  Default Property Values
	//*************************************************************************
	describe('Default Property Values', () => {
		it('should create the component', () => {
			expect(component).toBeTruthy();
		});

		it('should initialize isAnalyzing as true', () => {
			expect(component.isAnalyzing).toBe(true);
		});

		it('should initialize output as null', () => {
			expect(component.output).toBeNull();
		});

		it('should initialize data as empty string', () => {
			expect(component.data).toBe('');
		});

		it('should initialize setAiAssessment as an EventEmitter', () => {
			expect(component.setAiAssessment).toBeDefined();
			expect(typeof component.setAiAssessment.emit).toBe('function');
		});
	});

	//*************************************************************************
	//  ngOnChanges
	//*************************************************************************
	describe('ngOnChanges', () => {
		it('should render markdown and emit setAiAssessment when output has a currentValue', () => {
			const mockOutput = { text: 'analysis content' };
			const emitSpy = jest.spyOn(component.setAiAssessment, 'emit');
			component.output = mockOutput;

			component.ngOnChanges({
				output: { currentValue: mockOutput }
			});

			expect(mockMarkdownService.render).toHaveBeenCalledWith(mockOutput);
			expect(component.data).toBe('<p>rendered</p>');
			expect(emitSpy).toHaveBeenCalledWith(mockOutput);
		});

		it('should not render or emit when output currentValue is falsy', () => {
			const emitSpy = jest.spyOn(component.setAiAssessment, 'emit');

			component.ngOnChanges({
				output: { currentValue: null }
			});

			expect(mockMarkdownService.render).not.toHaveBeenCalled();
			expect(component.data).toBe('');
			expect(emitSpy).not.toHaveBeenCalled();
		});

		it('should not render or emit when output currentValue is undefined', () => {
			const emitSpy = jest.spyOn(component.setAiAssessment, 'emit');

			component.ngOnChanges({
				output: { currentValue: undefined }
			});

			expect(mockMarkdownService.render).not.toHaveBeenCalled();
			expect(component.data).toBe('');
			expect(emitSpy).not.toHaveBeenCalled();
		});

		it('should not render or emit when output currentValue is empty string', () => {
			const emitSpy = jest.spyOn(component.setAiAssessment, 'emit');

			component.ngOnChanges({
				output: { currentValue: '' }
			});

			expect(mockMarkdownService.render).not.toHaveBeenCalled();
			expect(component.data).toBe('');
			expect(emitSpy).not.toHaveBeenCalled();
		});
	});
});