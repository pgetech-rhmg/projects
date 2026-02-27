import { ComponentFixture, TestBed } from '@angular/core/testing';
import { EventEmitter, NO_ERRORS_SCHEMA } from '@angular/core';
import { DatePipe } from '@angular/common';

import { ReportComponent } from './report.component';

// Mock Chart.js
const mockChart = {
    destroy: jest.fn()
};

jest.mock('chart.js/auto', () => {
    return jest.fn().mockImplementation(() => mockChart);
});

import Chart from 'chart.js/auto';

// Mock ActivityService
jest.mock('~/core/services/activity.service', () => ({
    ActivityService: jest.fn().mockImplementation(() => ({
        GetActivity: jest.fn()
    }))
}));

// Mock Colors utility
jest.mock('~/core/utils/colors', () => ({
    Colors: {
        getRandomColors: jest.fn()
    }
}));

import { ActivityService } from '~/core/services/activity.service';
import { Colors } from '~/core/utils/colors';

describe('ReportComponent', () => {
    let component: ReportComponent;
    let fixture: ComponentFixture<ReportComponent>;
    let mockActivityService: any;

    beforeEach(async () => {
        mockActivityService = {
            GetActivity: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [ReportComponent],
            providers: [
                { provide: ActivityService, useValue: mockActivityService }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        jest.clearAllMocks();
        (Colors.getRandomColors as jest.Mock).mockReturnValue(['#FF0000', '#00FF00', '#0000FF']);
    });

    describe('Constructor', () => {
        it('should create component', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
        });

        it('should initialize types array', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.types).toEqual(["Activities", "Sessions", "Users"]);
        });

        it('should initialize timeframes array', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.timeframes).toEqual(["[Custom]", "Last 30 days", "Last 60 days", "Last 90 days", "Last 120 days", "YTD"]);
        });

        it('should initialize selectedType as ["Activities"]', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.selectedType).toEqual(["Activities"]);
        });

        it('should initialize selectedTimeframe as "Last 30 days"', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.selectedTimeframe).toBe("Last 30 days");
        });

        it('should initialize showDates as false', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.showDates).toBe(false);
        });

        it('should initialize showFilters as false', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.showFilters).toBe(false);
        });

        it('should initialize total as null', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.total).toBe(null);
        });

        it('should initialize isLoading as false', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.isLoading).toBe(false);
        });

        it('should initialize error as empty string', () => {
            // Act
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.error).toBe("");
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
        });

        it('should call setTimeframe and loadData', async () => {
            // Arrange
            jest.spyOn(component, 'setTimeframe');
            jest.spyOn(component, 'loadData').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(component.setTimeframe).toHaveBeenCalledWith(["Last 30 days"]);
            expect(component.loadData).toHaveBeenCalled();
        });
    });

    describe('setTimeframe', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
        });

        it('should set showDates to true for [Custom]', () => {
            // Act
            component.setTimeframe(['[Custom]']);

            // Assert
            expect(component.selectedTimeframe).toBe('[Custom]');
            expect(component.showDates).toBe(true);
        });

        it('should calculate dates for Last 30 days', () => {
            // Act
            component.setTimeframe(['Last 30 days']);

            // Assert
            expect(component.selectedTimeframe).toBe('Last 30 days');
            expect(component.showDates).toBe(false);
            expect(component.startDate).toBeTruthy();
            expect(component.endDate).toBeTruthy();
        });

        it('should calculate dates for Last 60 days', () => {
            // Act
            component.setTimeframe(['Last 60 days']);

            // Assert
            expect(component.selectedTimeframe).toBe('Last 60 days');
            expect(component.showDates).toBe(false);
        });

        it('should calculate dates for Last 90 days', () => {
            // Act
            component.setTimeframe(['Last 90 days']);

            // Assert
            expect(component.selectedTimeframe).toBe('Last 90 days');
            expect(component.showDates).toBe(false);
        });

        it('should calculate dates for Last 120 days', () => {
            // Act
            component.setTimeframe(['Last 120 days']);

            // Assert
            expect(component.selectedTimeframe).toBe('Last 120 days');
            expect(component.showDates).toBe(false);
        });

        it('should calculate dates for YTD', () => {
            // Act
            component.setTimeframe(['YTD']);

            // Assert
            expect(component.selectedTimeframe).toBe('YTD');
            expect(component.showDates).toBe(false);
        });

        it('should handle any other timeframe as default (YTD)', () => {
            // Act
            component.setTimeframe(['Unknown']);

            // Assert
            expect(component.selectedTimeframe).toBe('Unknown');
            expect(component.showDates).toBe(false);
        });
    });

    describe('validateDates', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
            jest.useFakeTimers({ doNotFake: ['Date'] });
        });

        afterEach(() => {
            jest.useRealTimers();
        });

        it('should adjust startDate if it is after endDate', () => {
            // Arrange
            component.startDate = '12/31/2023';
            component.endDate = '01/01/2023';

            // Act
            component.validateDates('start');
            jest.advanceTimersByTime(1);

            // Assert
            expect(component.startDate).toBe(component.endDate);
        });

        it('should adjust endDate if it is before startDate', () => {
            // Arrange
            component.startDate = '12/31/2023';
            component.endDate = '01/01/2023';

            // Act
            component.validateDates('end');
            jest.advanceTimersByTime(1);

            // Assert
            expect(component.endDate).toBe(component.startDate);
        });

        it('should not adjust dates if startDate is before endDate', () => {
            // Arrange
            component.startDate = '01/01/2023';
            component.endDate = '12/31/2023';
            const originalStart = component.startDate;
            const originalEnd = component.endDate;

            // Act
            component.validateDates('start');
            jest.advanceTimersByTime(1);

            // Assert
            expect(component.startDate).toBe(originalStart);
            expect(component.endDate).toBe(originalEnd);
        });

        it('should not adjust if startDate is empty', () => {
            // Arrange
            component.startDate = '';
            component.endDate = '12/31/2023';

            // Act
            component.validateDates('start');
            jest.advanceTimersByTime(1);

            // Assert
            expect(component.startDate).toBe('');
        });

        it('should not adjust if endDate is empty', () => {
            // Arrange
            component.startDate = '01/01/2023';
            component.endDate = '';

            // Act
            component.validateDates('end');
            jest.advanceTimersByTime(1);

            // Assert
            expect(component.endDate).toBe('');
        });
    });

    describe('closeFilters', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
        });

        it('should set showFilters to false', () => {
            // Arrange
            component.showFilters = true;

            // Act
            component.closeFilters();

            // Assert
            expect(component.showFilters).toBe(false);
        });
    });

    describe('close', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
        });

        it('should emit closeEvent', (done) => {
            // Arrange
            component.closeEvent.subscribe(() => {
                // Assert
                done();
            });

            // Act
            component.close();
        });
    });

    describe('loadData', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
            component.startDate = '01/01/2023';
            component.endDate = '12/31/2023';
            component.selectedType = ['Activities'];
        });

        it('should load activity data and create chart', async () => {
            // Arrange
            const mockData = [
                { event: 'View', count: 10, value: 'user1' },
                { event: 'Search', count: 5, value: 'user2' }
            ];
            mockActivityService.GetActivity.mockResolvedValue(mockData);
            jest.spyOn(component as any, 'createChart').mockImplementation();

            // Act
            await component.loadData();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(component['data']).toEqual(mockData);
            expect(component.error).toBe('');
            expect((component as any).createChart).toHaveBeenCalled();
        });

        it('should calculate total for sessions type', async () => {
            // Arrange
            component.selectedType = ['Sessions'];
            const mockData = [
                { event: 'Session', count: 3, value: 'session1' },
                { event: 'Session', count: 2, value: 'session2' },
                { event: 'Session', count: 1, value: 'session1' } // Duplicate
            ];
            mockActivityService.GetActivity.mockResolvedValue(mockData);
            jest.spyOn(component as any, 'createChart').mockImplementation();

            // Act
            await component.loadData();

            // Assert
            expect(component.total).toBe(2); // Unique values: session1, session2
        });

        it('should calculate total for users type', async () => {
            // Arrange
            component.selectedType = ['Users'];
            const mockData = [
                { event: 'Login', count: 5, value: 'user1' },
                { event: 'Login', count: 3, value: 'user2' },
                { event: 'Login', count: 2, value: 'user1' } // Duplicate
            ];
            mockActivityService.GetActivity.mockResolvedValue(mockData);
            jest.spyOn(component as any, 'createChart').mockImplementation();

            // Act
            await component.loadData();

            // Assert
            expect(component.total).toBe(2); // Unique values: user1, user2
        });

        it('should set total to null for activities type', async () => {
            // Arrange
            component.selectedType = ['Activities'];
            const mockData = [
                { event: 'View', count: 10, value: 'val1' }
            ];
            mockActivityService.GetActivity.mockResolvedValue(mockData);
            jest.spyOn(component as any, 'createChart').mockImplementation();

            // Act
            await component.loadData();

            // Assert
            expect(component.total).toBe(null);
        });

        it('should handle null response', async () => {
            // Arrange
            mockActivityService.GetActivity.mockResolvedValue(null);

            // Act
            await component.loadData();

            // Assert
            expect(component['data']).toBe(null);
            expect(component.total).toBe(null);
            expect(component.isLoading).toBe(false);
        });

        it('should handle errors', async () => {
            // Arrange
            const mockError = new Error('API Error');
            mockActivityService.GetActivity.mockRejectedValue(mockError);

            // Act
            await component.loadData();

            // Assert
            expect(component.error).toBe('API Error');
            expect(component.isLoading).toBe(false);
        });

        it('should set filter properties', async () => {
            // Arrange
            component.selectedType = ['Sessions'];
            component.startDate = '01/01/2023';
            component.endDate = '12/31/2023';
            mockActivityService.GetActivity.mockResolvedValue([]);
            jest.spyOn(component as any, 'createChart').mockImplementation();

            // Act
            await component.loadData();

            // Assert
            expect(component.filterType).toEqual(['Sessions']);
            expect(component.filterStartDate).toBeTruthy();
            expect(component.filterEndDate).toBeTruthy();
        });
    });

    describe('createChart (private method)', () => {
        let testComponent: ReportComponent;
        let mockCanvas: any;
        let mockCtx: any;

        beforeEach(() => {
            testComponent = new ReportComponent(mockActivityService);
            
            // Mock canvas and context
            mockCtx = {};
            mockCanvas = {
                getContext: jest.fn().mockReturnValue(mockCtx)
            };
            
            testComponent.chartCanvas = {
                nativeElement: mockCanvas
            } as any;

            testComponent['data'] = [
                { event: 'View', count: 10 },
                { event: 'Search', count: 5 }
            ];
        });

        it('should create a chart with correct data', () => {
            // Act
            (testComponent as any).createChart();

            // Assert
            expect(Chart).toHaveBeenCalledWith(mockCtx, expect.objectContaining({
                type: 'bar',
                data: expect.objectContaining({
                    labels: expect.arrayContaining(['Visits', 'Searches']),
                    datasets: expect.any(Array)
                }),
                options: expect.any(Object)
            }));
        });

        it('should map "File" event to "Files Viewed"', () => {
            // Arrange
            testComponent['data'] = [{ event: 'File', count: 3 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            expect(callArgs.data.labels).toContain('Files Viewed');
        });

        it('should map "Search" event to "Searches"', () => {
            // Arrange
            testComponent['data'] = [{ event: 'Search', count: 5 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            expect(callArgs.data.labels).toContain('Searches');
        });

        it('should map "View" event to "Visits"', () => {
            // Arrange
            testComponent['data'] = [{ event: 'View', count: 10 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            expect(callArgs.data.labels).toContain('Visits');
        });

        it('should keep unmapped events as-is', () => {
            // Arrange
            testComponent['data'] = [{ event: 'CustomEvent', count: 7 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            expect(callArgs.data.labels).toContain('CustomEvent');
        });

        it('should call destroyChart before creating new chart', () => {
            // Arrange
            jest.spyOn(testComponent as any, 'destroyChart');

            // Act
            (testComponent as any).createChart();

            // Assert
            expect((testComponent as any).destroyChart).toHaveBeenCalled();
        });

        it('should get random colors for chart', () => {
            // Arrange
            testComponent['data'] = [
                { event: 'View', count: 10 },
                { event: 'Search', count: 5 }
            ];

            // Act
            (testComponent as any).createChart();

            // Assert
            expect(Colors.getRandomColors).toHaveBeenCalledWith(2);
        });

        it('should configure tooltip label callback to return raw value', () => {
            // Arrange
            testComponent['data'] = [{ event: 'View', count: 10 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            const tooltipCallback = callArgs.options.plugins.tooltip.callbacks.label;
            
            // Test the callback with a mock context
            const mockContext = { raw: 42 };
            const result = tooltipCallback(mockContext);
            
            expect(result).toBe('42');
        });

        it('should handle tooltip label callback with string value', () => {
            // Arrange
            testComponent['data'] = [{ event: 'View', count: 10 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            const tooltipCallback = callArgs.options.plugins.tooltip.callbacks.label;
            
            // Test the callback with a mock context containing a string
            const mockContext = { raw: '100' };
            const result = tooltipCallback(mockContext);
            
            expect(result).toBe('100');
        });

        it('should handle tooltip label callback with zero value', () => {
            // Arrange
            testComponent['data'] = [{ event: 'View', count: 10 }];

            // Act
            (testComponent as any).createChart();

            // Assert
            const callArgs = (Chart as unknown as jest.Mock).mock.calls[0][1];
            const tooltipCallback = callArgs.options.plugins.tooltip.callbacks.label;
            
            // Test the callback with zero value
            const mockContext = { raw: 0 };
            const result = tooltipCallback(mockContext);
            
            expect(result).toBe('0');
        });
    });

    describe('destroyChart (private method)', () => {
        let testComponent: ReportComponent;

        beforeEach(() => {
            testComponent = new ReportComponent(mockActivityService);
        });

        it('should destroy existing chart', () => {
            // Arrange
            testComponent['chartjs'] = mockChart;

            // Act
            (testComponent as any).destroyChart();

            // Assert
            expect(mockChart.destroy).toHaveBeenCalled();
            expect(testComponent['chartjs']).toBeUndefined();
        });

        it('should not error if no chart exists', () => {
            // Arrange
            testComponent['chartjs'] = undefined;

            // Act & Assert
            expect(() => (testComponent as any).destroyChart()).not.toThrow();
        });
    });

    describe('Output Events', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(ReportComponent);
            component = fixture.componentInstance;
        });

        it('should have closeEvent output', () => {
            // Assert
            expect(component.closeEvent).toBeDefined();
            expect(component.closeEvent).toBeInstanceOf(EventEmitter);
        });
    });
});
