import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router, Navigation } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { RepoComponent } from './repo.component';

// Mock the imports
jest.mock('~/core/app.component', () => ({
    AppComponent: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/services/repo.service', () => ({
    RepoService: jest.fn().mockImplementation(() => ({
        assess: jest.fn()
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
import { RepoService } from '~/services/repo.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

describe('RepoComponent', () => {
    let component: RepoComponent;
    let fixture: ComponentFixture<RepoComponent>;
    let mockRouter: any;
    let mockRepoService: any;
    let mockNavigation: Partial<Navigation>;

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            currentNavigation: jest.fn(),
            navigate: jest.fn().mockResolvedValue(true),
            url: '/repo'
        };

        // Create mock RepoService instance
        mockRepoService = {
            assess: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [RepoComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: AppComponent, useValue: {} },
                { provide: RepoService, useValue: mockRepoService },
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
            const mockData = {
                repository: 'test-repo',
                branch: 'main'
            };
            mockNavigation = {
                extras: {
                    state: {
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
            expect(component.repository).toBe('test-repo');
            expect(component.branch).toBe('main');
        });

        it('should initialize with empty repository and branch when no navigation state', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {}
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.repository).toBe('');
            expect(component.branch).toBe('');
        });

        it('should initialize with empty repository and branch when navigation state is undefined', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: undefined
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.repository).toBe('');
            expect(component.branch).toBe('');
        });

        it('should initialize with empty repository and branch when navigation extras is empty', () => {
            // Arrange
            mockNavigation = {
                extras: {}
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.repository).toBe('');
            expect(component.branch).toBe('');
        });

        it('should initialize with empty repository and branch when navigation is null', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.repository).toBe('');
            expect(component.branch).toBe('');
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue(null);
            fixture = TestBed.createComponent(RepoComponent);
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

    describe('scan', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue(null);
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;
        });

        it('should return early when repository is empty', () => {
            // Arrange
            component.repository = '';
            component.branch = 'main';

            // Act
            component.scan();

            // Assert
            expect(mockRepoService.assess).not.toHaveBeenCalled();
        });

        it('should return early when branch is empty', () => {
            // Arrange
            component.repository = 'test-repo';
            component.branch = '';

            // Act
            component.scan();

            // Assert
            expect(mockRepoService.assess).not.toHaveBeenCalled();
        });

        it('should return early when both repository and branch are empty', () => {
            // Arrange
            component.repository = '';
            component.branch = '';

            // Act
            component.scan();

            // Assert
            expect(mockRepoService.assess).not.toHaveBeenCalled();
        });

        it('should set isLoading to true and call repoService.assess with correct request', (done) => {
            // Arrange
            component.repository = 'test-repo';
            component.branch = 'main';
            const mockResponse = { result: 'success' };
            
            let subscriptionCallback: any;
            const delayedObservable = new Observable((subscriber) => {
                subscriptionCallback = () => {
                    subscriber.next(mockResponse);
                    subscriber.complete();
                };
            });
            
            mockRepoService.assess.mockReturnValue(delayedObservable);

            // Act
            component.scan();

            // Assert - check immediately after call, before observable completes
            expect(component.isLoading).toBe(true);
            expect(mockRepoService.assess).toHaveBeenCalledWith({
                RepoName: 'test-repo',
                branch: 'main'
            });
            
            // Complete the observable
            subscriptionCallback();
            done();
        });

        it('should navigate to /repo-results with response data on success', () => {
            // Arrange
            component.repository = 'test-repo';
            component.branch = 'main';
            const mockResponse = { result: 'success', data: 'test-data' };
            mockRepoService.assess.mockReturnValue(of(mockResponse));

            // Act
            component.scan();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo-results'], {
                state: { data: mockResponse }
            });
        });

        it('should set isLoading to false and log error on failure', () => {
            // Arrange
            component.repository = 'test-repo';
            component.branch = 'main';
            const mockError = new Error('API Error');
            mockRepoService.assess.mockReturnValue(throwError(() => mockError));

            // Act
            component.scan();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });
    });

    describe('Component Initialization', () => {
        it('should initialize repository as empty string by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.repository).toBe('');
        });

        it('should initialize branch as empty string by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.branch).toBe('');
        });
    });

    describe('Integration: Full scan flow', () => {
        it('should complete full flow from scan through successful response', async () => {
            // Arrange
            const mockResponse = {
                repository: 'test-repo',
                branch: 'main',
                results: ['file1.ts', 'file2.ts']
            };
            mockRouter.currentNavigation.mockReturnValue(null);
            mockRepoService.assess.mockReturnValue(of(mockResponse));
            
            fixture = TestBed.createComponent(RepoComponent);
            component = fixture.componentInstance;
            component.repository = 'test-repo';
            component.branch = 'main';
            
            // Act
            component.scan();
            await fixture.whenStable();

            // Assert
            expect(mockRepoService.assess).toHaveBeenCalledWith({
                RepoName: 'test-repo',
                branch: 'main'
            });
            expect(component.isLoading).toBe(false);
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo-results'], {
                state: { data: mockResponse }
            });
        });
    });
});
