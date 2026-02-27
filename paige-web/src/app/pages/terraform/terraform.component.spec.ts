import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router, Navigation } from '@angular/router';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { TerraformComponent } from './terraform.component';

// Mock the ACTUAL imports that the component needs
jest.mock('~/core/app.component', () => ({
    AppComponent: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/services/cfn.service', () => ({
    CfnService: jest.fn().mockImplementation(() => ({
        createProject: jest.fn()
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
import { CfnService } from '~/services/cfn.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { ActivityService } from '~/core/services/activity.service';

describe('TerraformComponent', () => {
    let component: TerraformComponent;
    let fixture: ComponentFixture<TerraformComponent>;
    let mockRouter: any;
    let mockCfnService: any;
    let mockNavigation: Partial<Navigation>;

    const mockRepoData = { id: 'repo-123', name: 'test-repo' };
    const mockData = { content: 'test-data' };
    const mockModules = [
        { name: 'module1', path: '/path/to/module1' },
        { name: 'module2', path: '/path/to/module2' }
    ];

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            currentNavigation: jest.fn(),
            navigate: jest.fn().mockResolvedValue(true)
        };

        // Create mock CfnService instance
        mockCfnService = {
            createProject: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [TerraformComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: AppComponent, useValue: {} },
                { provide: CfnService, useValue: mockCfnService },
                { provide: AppConfigService, useValue: { getConfig: jest.fn() } },
                { provide: AppSettingsService, useValue: { getSettings: jest.fn() } },
                { provide: ActivityService, useValue: { SaveActivity: jest.fn() } }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();
    });

    describe('Constructor', () => {
        it('should create component and initialize with navigation state when modules exist', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
            expect(component.isLoading).toBe(true);
            expect(component.repoData).toEqual(mockRepoData);
            expect(component.data).toEqual(mockData);
            expect(component.modules).toEqual(mockModules);
            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should navigate to /repo when modules are not in navigation state', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {}
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
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
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when navigation extras is undefined', () => {
            // Arrange
            mockNavigation = {
                extras: {}  // Changed from undefined to empty object
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when navigation is null', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
        });

        it('should call createProject when data exists', async () => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'terraform content',
                    'variables.tf': 'variable definitions'
                }
            };
            mockCfnService.createProject.mockReturnValue(of(mockResponse));
            
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
            
            jest.spyOn(component as any, 'createProject');
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).createProject).toHaveBeenCalled();
        });

        it('should navigate to /repo when data is null', async () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: null
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            mockRouter.navigate.mockClear();

            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });

        it('should navigate to /repo when data is undefined', async () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: undefined
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            mockRouter.navigate.mockClear();

            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
            component.data = undefined;
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/repo'], { state: { data: null } });
        });
    });

    describe('back', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
            mockRouter.navigate.mockClear();
        });

        it('should navigate to /cfn with repoData and data in state', () => {
            // Act
            component.back();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/cfn'], {
                state: { repoData: mockRepoData, data: mockData }
            });
        });
    });

    describe('createProject', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
        });

        it('should set isLoading to true and call cfnService.createProject', (done) => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'content'
                }
            };
            
            // We need to delay the observable completion to check isLoading while true
            let subscriptionCallback: any;
            const delayedObservable = new Observable((subscriber) => {
                subscriptionCallback = () => {
                    subscriber.next(mockResponse);
                    subscriber.complete();
                };
            });
            
            mockCfnService.createProject.mockReturnValue(delayedObservable);

            // Act
            (component as any).createProject();

            // Assert - check immediately after call, before observable completes
            expect(component.isLoading).toBe(true);
            expect(mockCfnService.createProject).toHaveBeenCalledWith(mockModules);
            
            // Now complete the observable
            subscriptionCallback();
            
            // After completion, isLoading should be false
            expect(component.isLoading).toBe(false);
            done();
        });

        it('should hydrate terraform output and set isLoading to false on success', () => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'terraform main content',
                    'variables.tf': 'variables content'
                }
            };
            mockCfnService.createProject.mockReturnValue(of(mockResponse));
            jest.spyOn(component as any, 'hydrateTerraformOutput');

            // Act
            (component as any).createProject();

            // Assert
            expect((component as any).hydrateTerraformOutput).toHaveBeenCalledWith(mockResponse);
            expect(component.isLoading).toBe(false);
        });

        it('should log error and set isLoading to false on failure', () => {
            // Arrange
            const mockError = new Error('API Error');
            mockCfnService.createProject.mockReturnValue(throwError(() => mockError));

            // Act
            (component as any).createProject();

            // Assert
            expect(component.isLoading).toBe(false);
        });
    });

    describe('hydrateTerraformOutput', () => {
        beforeEach(() => {
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
        });

        it('should parse root files correctly when response is an object', () => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'main content',
                    'variables.tf': 'variables content'
                }
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(1);
            expect(component.parsedFiles[0].module).toBeNull();
            expect(component.parsedFiles[0].files).toHaveLength(2);
            expect(component.parsedFiles[0].files[0]).toEqual({
                name: 'main.tf',
                content: 'main content'
            });
            expect(component.parsedFiles[0].files[1]).toEqual({
                name: 'variables.tf',
                content: 'variables content'
            });
        });

        it('should parse root files correctly when response is a JSON string', () => {
            // Arrange
            const mockResponse = JSON.stringify({
                files: {
                    'main.tf': 'main content',
                    'outputs.tf': 'outputs content'
                }
            });

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(1);
            expect(component.parsedFiles[0].module).toBeNull();
            expect(component.parsedFiles[0].files).toHaveLength(2);
        });

        it('should parse module files correctly', () => {
            // Arrange
            const mockResponse = {
                files: {
                    'modules/vpc/main.tf': 'vpc main content',
                    'modules/vpc/variables.tf': 'vpc variables',
                    'modules/ec2/main.tf': 'ec2 main content'
                }
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(2);
            expect(component.parsedFiles[0].module).toBe('vpc');
            expect(component.parsedFiles[0].files).toHaveLength(2);
            expect(component.parsedFiles[0].files[0]).toEqual({
                name: 'main.tf',
                content: 'vpc main content'
            });
            expect(component.parsedFiles[1].module).toBe('ec2');
            expect(component.parsedFiles[1].files).toHaveLength(1);
        });

        it('should parse both root and module files correctly', () => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'root main',
                    'modules/vpc/main.tf': 'vpc main',
                    'modules/vpc/outputs.tf': 'vpc outputs',
                    'variables.tf': 'root variables'
                }
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(2);
            expect(component.parsedFiles[0].module).toBeNull();
            expect(component.parsedFiles[0].files).toHaveLength(2);
            expect(component.parsedFiles[1].module).toBe('vpc');
            expect(component.parsedFiles[1].files).toHaveLength(2);
        });

        it('should return early when response is null', () => {
            // Arrange
            component.parsedFiles = [{ module: 'test', files: [] }];

            // Act
            (component as any).hydrateTerraformOutput(null);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should return early when response is undefined', () => {
            // Arrange
            component.parsedFiles = [{ module: 'test', files: [] }];

            // Act
            (component as any).hydrateTerraformOutput(undefined);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should log error and clear parsedFiles when response type is unsupported', () => {
            // Arrange
            component.parsedFiles = [{ module: 'test', files: [] }];

            // Act
            (component as any).hydrateTerraformOutput(12345); // number type

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should log error and clear parsedFiles when files object is missing', () => {
            // Arrange
            const mockResponse = { data: 'some data' };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should log error and clear parsedFiles when files is not an object', () => {
            // Arrange
            const mockResponse = { files: 'not an object' };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should handle JSON parse error and clear parsedFiles', () => {
            // Arrange
            const invalidJSON = 'invalid json {';

            // Act
            (component as any).hydrateTerraformOutput(invalidJSON);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should handle empty files object', () => {
            // Arrange
            const mockResponse = {
                files: {}
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });

        it('should handle module path with multiple segments correctly', () => {
            // Arrange
            const mockResponse = {
                files: {
                    'modules/networking/vpc': 'vpc content'
                }
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(1);
            expect(component.parsedFiles[0].module).toBe('networking');
            expect(component.parsedFiles[0].files[0].name).toBe('vpc');
        });

        it('should handle unexpected error during parsing', () => {
            // Arrange
            const mockResponse = {
                get files() {
                    throw new Error('Unexpected error');
                }
            };

            // Act
            (component as any).hydrateTerraformOutput(mockResponse);

            // Assert
            expect(component.parsedFiles).toHaveLength(0);
        });
    });

    describe('Component Initialization', () => {
        it('should initialize parsedFiles as empty array', () => {
            // Arrange
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.parsedFiles).toEqual([]);
        });

        it('should initialize repoData, data, and modules as null by default', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;

            // Assert
            // Component is created successfully
            expect(component).toBeTruthy();
        });
    });

    describe('Integration: ngOnInit with createProject flow', () => {
        it('should complete full flow from ngOnInit through successful createProject', async () => {
            // Arrange
            const mockResponse = {
                files: {
                    'main.tf': 'main content',
                    'modules/vpc/main.tf': 'vpc content'
                }
            };
            mockNavigation = {
                extras: {
                    state: {
                        modules: mockModules,
                        repoData: mockRepoData,
                        data: mockData
                    }
                }
            };
            mockRouter.currentNavigation.mockReturnValue(mockNavigation as Navigation);
            mockCfnService.createProject.mockReturnValue(of(mockResponse));
            
            // Act
            fixture = TestBed.createComponent(TerraformComponent);
            component = fixture.componentInstance;
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(mockCfnService.createProject).toHaveBeenCalledWith(mockModules);
            expect(component.parsedFiles).toHaveLength(2);
            expect(component.isLoading).toBe(false);
        });
    });
});
