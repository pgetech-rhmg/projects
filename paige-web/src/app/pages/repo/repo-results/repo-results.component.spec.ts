import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router, Navigation } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { RepoResultsComponent } from './repo-results.component';

// Mock the imports
jest.mock('~/core/app.component', () => ({
    AppComponent: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/services/scan.service', () => ({
    ScanService: jest.fn().mockImplementation(() => ({
        scan: jest.fn()
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

// Import the mocked classes
import { AppComponent } from '~/core/app.component';
import { ScanService } from '~/services/scan.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

describe('RepoResultsComponent', () => {
    let component: RepoResultsComponent;
    let fixture: ComponentFixture<RepoResultsComponent>;
    let mockRouter: any;
    let mockScanService: any;
    let mockNavigation: Partial<Navigation>;

    const mockResponseData = {
        summary: {
            structure: {
                repoName: 'test-repo',
                branch: 'main',
                keyFiles: [
                    { category: 'Infrastructure', name: 'file1.tf', path: '/path/to/file1.tf' },
                    { category: 'Infrastructure', name: 'file2.tf', path: '/path/to/file2.tf' },
                    { category: 'Configuration', name: 'config.yaml', path: '/path/to/config.yaml' },
                    { category: 'Documentation', name: 'README.md', path: '/README.md' }
                ]
            }
        }
    };

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            currentNavigation: jest.fn(),
            navigate: jest.fn().mockResolvedValue(true),
            url: '/repo-results'
        };

        // Create mock ScanService instance
        mockScanService = {
            scan: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [RepoResultsComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: AppComponent, useValue: {} },
                { provide: ScanService, useValue: mockScanService },
                { provide: AppConfigService, useValue: { getConfig: jest.fn() } },
                { provide: AppSettingsService, useValue: { getSettings: jest.fn() } },
                { provide: ActivityService, useValue: { SaveActivity: jest.fn() } }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();
    });

    describe('Constructor', () => {
        it('should create component and initialize with navigation state data', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
            expect(component.isLoading).toBe(true);
            expect(component.response).toEqual(mockResponseData);
            expect(component.groupedEntries).toBeDefined();
            expect(component.groupedEntries['Infrastructure']).toHaveLength(2);
            expect(component.groupedEntries['Configuration']).toHaveLength(1);
            expect(component.groupedEntries['Documentation']).toHaveLength(1);
        });

        it('should navigate to /repo when no navigation state data', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {}
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when navigation state is undefined', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: undefined
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when navigation extras is empty', () => {
            // Arrange
            mockNavigation = {
                extras: {}
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when navigation is null', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should group entries correctly by category', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(Object.keys(component.groupedEntries)).toHaveLength(3);
            expect(component.groupedEntries['Infrastructure']).toEqual([
                { category: 'Infrastructure', name: 'file1.tf', path: '/path/to/file1.tf' },
                { category: 'Infrastructure', name: 'file2.tf', path: '/path/to/file2.tf' }
            ]);
            expect(component.groupedEntries['Configuration']).toEqual([
                { category: 'Configuration', name: 'config.yaml', path: '/path/to/config.yaml' }
            ]);
            expect(component.groupedEntries['Documentation']).toEqual([
                { category: 'Documentation', name: 'README.md', path: '/README.md' }
            ]);
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
        });

        it('should call initAsync and set isLoading to false', async () => {
            // Arrange
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).initAsync).toHaveBeenCalled();
            expect(component.isLoading).toBe(false);
        });
    });

    describe('convert', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
            mockRouter.navigate.mockClear();
        });

        it('should set isLoading to true and call scanService.scan with correct request', (done) => {
            // Arrange
            const mockScanResponse = { result: 'success' };
            
            let subscriptionCallback: any;
            const delayedObservable = new Observable((subscriber) => {
                subscriptionCallback = () => {
                    subscriber.next(mockScanResponse);
                    subscriber.complete();
                };
            });
            
            mockScanService.scan.mockReturnValue(delayedObservable);

            // Act
            component.convert();

            // Assert - check immediately after call, before observable completes
            expect(component.isLoading).toBe(true);
            expect(mockScanService.scan).toHaveBeenCalledWith({
                repoName: 'test-repo',
                branch: 'main'
            });
            
            // Complete the observable
            subscriptionCallback();
            done();
        });

        it('should navigate to /cfn with repoData and response data on success', () => {
            // Arrange
            const mockScanResponse = { 
                terraform: 'data',
                modules: ['module1', 'module2']
            };
            mockScanService.scan.mockReturnValue(of(mockScanResponse));

            // Act
            component.convert();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/cfn'], {
                state: { 
                    repoData: mockResponseData,
                    data: mockScanResponse 
                }
            });
        });

        it('should set isLoading to false and log error on failure', () => {
            // Arrange
            const mockError = new Error('Scan Error');
            mockScanService.scan.mockReturnValue(throwError(() => mockError));

            // Act
            component.convert();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });
    });

    describe('objectKeys', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
        });

        it('should return array of object keys', () => {
            // Arrange
            const testObject = {
                key1: 'value1',
                key2: 'value2',
                key3: 'value3'
            };

            // Act
            const result = component.objectKeys(testObject);

            // Assert
            expect(result).toEqual(['key1', 'key2', 'key3']);
        });

        it('should return empty array for empty object', () => {
            // Arrange
            const testObject = {};

            // Act
            const result = component.objectKeys(testObject);

            // Assert
            expect(result).toEqual([]);
        });
    });

    describe('back', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
            mockRouter.navigate.mockClear();
        });

        it('should navigate to /repo with repository and branch data', () => {
            // Act
            component.back();

            // Assert
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

    describe('groupKeyEntries (private method)', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue(null);
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
        });

        it('should group entries by category correctly', () => {
            // Arrange
            const entries = [
                { category: 'TypeA', name: 'item1' },
                { category: 'TypeA', name: 'item2' },
                { category: 'TypeB', name: 'item3' },
                { category: 'TypeC', name: 'item4' },
                { category: 'TypeA', name: 'item5' }
            ];

            // Act
            (component as any).groupKeyEntries(entries);

            // Assert
            expect(component.groupedEntries['TypeA']).toHaveLength(3);
            expect(component.groupedEntries['TypeB']).toHaveLength(1);
            expect(component.groupedEntries['TypeC']).toHaveLength(1);
            expect(component.groupedEntries['TypeA']).toEqual([
                { category: 'TypeA', name: 'item1' },
                { category: 'TypeA', name: 'item2' },
                { category: 'TypeA', name: 'item5' }
            ]);
        });

        it('should handle empty entries array', () => {
            // Arrange
            const entries: any[] = [];

            // Act
            (component as any).groupKeyEntries(entries);

            // Assert
            expect(component.groupedEntries).toEqual({});
        });

        it('should handle single entry', () => {
            // Arrange
            const entries = [
                { category: 'SingleType', name: 'single-item' }
            ];

            // Act
            (component as any).groupKeyEntries(entries);

            // Assert
            expect(Object.keys(component.groupedEntries)).toHaveLength(1);
            expect(component.groupedEntries['SingleType']).toEqual([
                { category: 'SingleType', name: 'single-item' }
            ]);
        });
    });

    describe('Component Initialization', () => {
        it('should initialize response as null by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert - component navigates away, but initial value is null
            expect(component.response).toBeNull();
        });

        it('should initialize groupedEntries as empty object by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.groupedEntries).toEqual({});
        });

        it('should initialize messageStyle as empty string by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.messageStyle).toBe('');
        });

        it('should initialize username as empty string by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.username).toBe('');
        });
    });

    describe('Integration: Full convert flow', () => {
        it('should complete full flow from convert through successful response', async () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        data: mockResponseData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            
            const mockScanResponse = {
                terraform: { files: ['main.tf', 'variables.tf'] },
                modules: ['networking', 'compute']
            };
            mockScanService.scan.mockReturnValue(of(mockScanResponse));
            
            fixture = TestBed.createComponent(RepoResultsComponent);
            component = fixture.componentInstance;
            mockRouter.navigate.mockClear();
            
            // Act
            component.convert();
            await fixture.whenStable();

            // Assert
            expect(mockScanService.scan).toHaveBeenCalledWith({
                repoName: 'test-repo',
                branch: 'main'
            });
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/cfn'], {
                state: {
                    repoData: mockResponseData,
                    data: mockScanResponse
                }
            });
        });
    });
});
