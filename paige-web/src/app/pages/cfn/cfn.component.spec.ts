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
    let mockNgZone: any;

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
        // Create mock router
        mockRouter = {
            currentNavigation: jest.fn(),
            navigate: jest.fn().mockResolvedValue(true),
            url: '/cfn'
        };

        // Create mock CfnService
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

    describe('Constructor', () => {
        it('should create component', () => {
            // Arrange - set up navigation state before creating component
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent).toBeTruthy();
        });

        it('should initialize with navigation state data', fakeAsync(() => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.isLoading).toBe(true);
            expect(newComponent.repoData).toEqual(mockRepoData);
            expect(newComponent.response).toEqual(mockResponse);
            expect(newComponent.data).toHaveLength(3);
            expect(newComponent.total).toBe(3);

            // Verify status field was added
            newComponent.data.forEach((item: any) => {
                expect(item.status).toBe("");
            });

            tick(150); // Increase tick time to ensure setTimeout completes

            expect(newComponent.updateGrid).toBe(true);
            expect(newComponent.showGrid).toBe(true);
        }));

        it('should navigate to /repo when no navigation state data exists', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({ extras: { state: {} } });

            // Act
            TestBed.createComponent(CfnComponent);

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(["/repo"], { state: { data: null } });
        });

        it('should navigate to /repo when navigation is null', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue(null);

            // Act
            TestBed.createComponent(CfnComponent);

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(["/repo"], { state: { data: null } });
        });

        it('should initialize columns correctly', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.columns).toHaveLength(6);
            expect(newComponent.columns[0].Name).toBe('status');
            expect(newComponent.columns[1].Name).toBe('path');
            expect(newComponent.columns[2].Name).toBe('format');
            expect(newComponent.columns[3].Name).toBe('classification');
            expect(newComponent.columns[4].Name).toBe('resourceTypes');
            expect(newComponent.columns[5].Name).toBe('parameterDefaults');
        });

        it('should configure grid options correctly', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.options.header).toBe(false);
            expect(newComponent.options.footer).toBe(false);
            expect(newComponent.options.options).toBe(false);
            expect(newComponent.options.formulas).toBe(false);
            expect(newComponent.options.nowrap).toBe(true);
        });

        it('should initialize modules as empty array', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.modules).toEqual([]);
        });

        it('should initialize isProcessing as false', () => {
            // Arrange
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.isProcessing).toBe(false);
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should call initAsync', async () => {
            // Arrange
            jest.spyOn(component as any, 'initAsync').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect((component as any).initAsync).toHaveBeenCalled();
        });
    });

    describe('loadData', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
            // Don't call detectChanges - it tries to render template with sdk-datagrid
        });

        it('should return early when event is null', async () => {
            // Arrange
            component.isLoading = false;
            component.showGrid = false;

            // Act
            await component.loadData(null);

            // Assert
            expect(component.isLoading).toBe(false);
            expect(component.showGrid).toBe(false);
        });

        it('should set loading state and update grid when event is provided', fakeAsync(() => {
            // Arrange
            component.isLoading = false;
            component.updateGrid = false;
            component.showGrid = false;

            // Act
            component.loadData({ some: 'event' });

            // Assert
            expect(component.error).toBe("");

            tick(150);

            expect(component.updateGrid).toBe(true);
            expect(component.showGrid).toBe(true);
        }));
    });

    describe('generateTerraform', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
            // Don't call detectChanges - it tries to render template with sdk-datagrid
        });

        it('should return early if already processing', () => {
            // Arrange
            component.isProcessing = true;

            // Act
            component.generateTerraform();

            // Assert
            expect(mockCfnService.generate).not.toHaveBeenCalled();
        });

        it('should initiate terraform generation process', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            } as any;

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Assert
            expect(component.isProcessing).toBe(true);
            expect(component.modules).toEqual([]);
            expect(mockCfnService.generate).toHaveBeenCalled();

            const generateArg = mockCfnService.generate.mock.calls[0][0];
            expect(generateArg).toHaveLength(3);
            expect(generateArg[0]).toEqual({
                module: 'template1',
                rawCfn: 'cfn-content-1'
            });
        });

        it('should update processing message with correct count', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            } as any;

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Assert
            expect(component.processingMessage).toBe('Processing files: (0/3)');
        });

        it('should update data items status to processing', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            } as any;

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Assert
            component.data.forEach((item: any) => {
                expect(item.status).toBe('processing');
            });
            expect(component.updateGrid).toBe(true);
        });

        it('should handle SSE message events', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Mock document.getElementById
            const mockElement = { innerHTML: '' };
            jest.spyOn(document, 'getElementById').mockReturnValue(mockElement as any);

            // Act
            component.generateTerraform();

            const moduleResult: TerraformModuleResult = {
                module: 'template1',
                files: { 'main.tf': 'terraform content' }
            };

            // Wait for onmessage to be assigned, then simulate SSE message
            setTimeout(() => {
                const messageEvent = {
                    data: JSON.stringify(moduleResult)
                } as MessageEvent;

                mockEventSource.onmessage(messageEvent);

                // Assert
                expect(component.modules).toHaveLength(1);
                expect(component.modules[0]).toEqual(moduleResult);
                expect(component.data[0].status).toBe('fin');
                expect(mockElement.innerHTML).toBe('<div class="icon green">check</div>');
                expect(component.processingMessage).toBe('Processing (1/3)...');
            }, 10);
        });

        it('should handle SSE message event for module not found in data', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            const moduleResult: TerraformModuleResult = {
                module: 'unknown-module',
                files: { 'main.tf': 'terraform content' }
            };

            // Wait for onmessage to be assigned
            setTimeout(() => {
                const messageEvent = {
                    data: JSON.stringify(moduleResult)
                } as MessageEvent;

                mockEventSource.onmessage(messageEvent);

                // Assert
                expect(component.modules).toHaveLength(1);
                expect(component.modules[0]).toEqual(moduleResult);
            }, 10);
        });

        it('should handle complete event', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Get the complete event handler
            const completeHandler = mockEventSource.addEventListener.mock.calls.find(
                (call: any) => call[0] === 'complete'
            )?.[1];

            expect(completeHandler).toBeDefined();

            // Simulate complete event
            completeHandler();

            // Assert
            expect(mockEventSource.close).toHaveBeenCalled();
            expect(component.isLoading).toBe(false);
            expect(component.isProcessing).toBe(false);
            expect(mockRouter.navigate).toHaveBeenCalledWith(
                ['/terraform'],
                {
                    state: {
                        repoData: mockRepoData,
                        data: mockResponse,
                        modules: component.modules
                    }
                }
            );
        });

        it('should handle SSE error event', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource: any = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            };

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Simulate error event
            mockEventSource.onerror(new Event('error'));

            // Assert
            expect(mockEventSource.close).toHaveBeenCalled();
            expect(component.isLoading).toBe(false);
            expect(component.isProcessing).toBe(false);
        });

        it('should handle generate service error', () => {
            // Arrange
            const mockError = new Error('Generate failed');
            mockCfnService.generate.mockReturnValue(throwError(() => mockError));

            // Act
            component.generateTerraform();

            // Assert
            expect(component.isLoading).toBe(false);
        });

        it('should call setActiveJob with jobId', () => {
            // Arrange
            const mockJobId = { jobId: 'job-123' };
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            } as any;

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            component.generateTerraform();

            // Assert
            expect(mockCfnService.setActiveJob).toHaveBeenCalledWith(mockJobId);
            expect(mockCfnService.generateStream).toHaveBeenCalledWith('job-123');
        });
    });

    describe('cancel', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
            // Don't call detectChanges - it tries to render template with sdk-datagrid
        });

        it('should close eventSource and call cancel service', () => {
            // Arrange
            const mockEventSource = {
                close: jest.fn()
            } as any;

            component['eventSource'] = mockEventSource;
            mockCfnService.cancel.mockReturnValue(of(undefined));

            // Act
            component.cancel();

            // Assert
            expect(mockEventSource.close).toHaveBeenCalled();
            expect(component['eventSource']).toBeUndefined();
            expect(mockCfnService.cancel).toHaveBeenCalled();
        });

        it('should reset loading and processing states', () => {
            // Arrange
            mockCfnService.cancel.mockReturnValue(of(undefined));

            component.isLoading = true;
            component.isProcessing = true;

            // Act
            component.cancel();

            // Assert
            expect(component.isLoading).toBe(false);
            expect(component.isProcessing).toBe(false);
        });

        it('should reset processing items status', () => {
            // Arrange
            mockCfnService.cancel.mockReturnValue(of(undefined));

            component.data[0].status = 'processing';
            component.data[1].status = '';
            component.data[2].status = 'processing';

            // Act
            component.cancel();

            // Assert
            expect(component.data[0].status).toBe('');
            expect(component.data[1].status).toBe('');
            expect(component.data[2].status).toBe('');
            expect(component.updateGrid).toBe(true);
        });

        it('should handle cancel when event source is undefined', () => {
            // Arrange
            component['eventSource'] = undefined;
            mockCfnService.cancel.mockReturnValue(of(undefined));

            // Act & Assert
            expect(() => component.cancel()).not.toThrow();
            expect(mockCfnService.cancel).toHaveBeenCalled();
        });
    });

    describe('getModuleNameFromPath', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should extract module name from yaml file path', () => {
            // Act
            const result = component.getModuleNameFromPath('path/to/template.yaml');

            // Assert
            expect(result).toBe('template');
        });

        it('should extract module name from yml file path', () => {
            // Act
            const result = component.getModuleNameFromPath('path/to/template.yml');

            // Assert
            expect(result).toBe('template');
        });

        it('should extract module name from json file path', () => {
            // Act
            const result = component.getModuleNameFromPath('path/to/template.json');

            // Assert
            expect(result).toBe('template');
        });

        it('should handle file in root directory', () => {
            // Act
            const result = component.getModuleNameFromPath('template.yaml');

            // Assert
            expect(result).toBe('template');
        });

        it('should handle uppercase extensions', () => {
            // Act
            const result = component.getModuleNameFromPath('template.YAML');

            // Assert
            expect(result).toBe('template');
        });

        it('should handle mixed case extensions', () => {
            // Act
            const result = component.getModuleNameFromPath('template.YmL');

            // Assert
            expect(result).toBe('template');
        });
    });

    describe('back', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should navigate to repo-results with repoData', () => {
            // Act
            component.back();

            // Assert
            expect(mockRouter.navigate).toHaveBeenCalledWith(
                ["/repo-results"],
                { state: { data: mockRepoData } }
            );
        });
    });

    describe('getClassificationLabel (private method)', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should return "root" for classification 0', () => {
            // Act
            const result = component['getClassificationLabel'](0);

            // Assert
            expect(result).toBe('root');
        });

        it('should return "nested" for classification 1', () => {
            // Act
            const result = component['getClassificationLabel'](1);

            // Assert
            expect(result).toBe('nested');
        });

        it('should return "partial" for classification 2', () => {
            // Act
            const result = component['getClassificationLabel'](2);

            // Assert
            expect(result).toBe('partial');
        });

        it('should return "unknown" for classification 3', () => {
            // Act
            const result = component['getClassificationLabel'](3);

            // Assert
            expect(result).toBe('unknown');
        });

        it('should return "unknown" for negative classification', () => {
            // Act
            const result = component['getClassificationLabel'](-1);

            // Assert
            expect(result).toBe('unknown');
        });

        it('should return "unknown" for large classification number', () => {
            // Act
            const result = component['getClassificationLabel'](999);

            // Assert
            expect(result).toBe('unknown');
        });
    });

    describe('getIndex (private method)', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should return correct index for existing module', () => {
            // Act
            const result = component['getIndex']('template1');

            // Assert
            expect(result).toBe(0);
        });

        it('should return correct index for nested module', () => {
            // Act
            const result = component['getIndex']('template2');

            // Assert
            expect(result).toBe(1);
        });

        it('should return -1 for non-existing module', () => {
            // Act
            const result = component['getIndex']('non-existing');

            // Assert
            expect(result).toBe(-1);
        });
    });

    describe('Column formatData', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should format classification data correctly', () => {
            // Arrange
            const classificationColumn = component.columns.find(col => col.Name === 'classification');
            expect(classificationColumn).toBeDefined();
            expect(classificationColumn!.formatData).toBeDefined();

            // Act & Assert
            const result0 = classificationColumn!.formatData!(0);
            expect(result0).toBe('root');

            const result1 = classificationColumn!.formatData!(1);
            expect(result1).toBe('nested');

            const result2 = classificationColumn!.formatData!(2);
            expect(result2).toBe('partial');
        });
    });

    describe('Input Properties', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should have default username as empty string', () => {
            // Assert
            expect(component.username).toBe("");
        });

        it('should accept username input', () => {
            // Act
            component.username = "testuser";

            // Assert
            expect(component.username).toBe("testuser");
        });
    });

    describe('Component State Properties', () => {
        beforeEach(() => {
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: mockResponse,
                        repoData: mockRepoData
                    }
                }
            });
            fixture = TestBed.createComponent(CfnComponent);
            component = fixture.componentInstance;
        });

        it('should initialize state properties correctly', () => {
            // Assert
            expect(component.isProcessing).toBe(false);
            expect(component.processingMessage).toBe("");
            expect(component.error).toBe("");
            expect(component.messageStyle).toBe("");
            expect(component.modules).toEqual([]);
        });
    });

    describe('Edge Cases', () => {
        it('should handle empty cloudFormationFiles array', fakeAsync(() => {
            // Arrange
            const emptyResponse = { cloudFormationFiles: [] };
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: emptyResponse,
                        repoData: mockRepoData
                    }
                }
            });

            // Act
            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;

            // Assert
            expect(newComponent.data).toEqual([]);
            expect(newComponent.total).toBe(0);

            tick(150); // Increase tick time to ensure setTimeout completes

            expect(newComponent.showGrid).toBe(true);
        }));

        it('should handle generateTerraform with empty data', () => {
            // Arrange
            const emptyResponse = { cloudFormationFiles: [] };
            mockRouter.currentNavigation.mockReturnValue({
                extras: {
                    state: {
                        data: emptyResponse,
                        repoData: mockRepoData
                    }
                }
            });

            const newFixture = TestBed.createComponent(CfnComponent);
            const newComponent = newFixture.componentInstance;
            // Don't call detectChanges

            const mockJobId = { jobId: 'job-123' };
            const mockEventSource = {
                onmessage: null,
                onerror: null,
                addEventListener: jest.fn(),
                close: jest.fn()
            } as any;

            mockCfnService.generate.mockReturnValue(of(mockJobId));
            mockCfnService.generateStream.mockReturnValue(mockEventSource);

            // Act
            newComponent.generateTerraform();

            // Assert
            expect(newComponent.processingMessage).toBe('Processing files: (0/0)');
            expect(mockCfnService.generate).toHaveBeenCalledWith([]);
        });
    });
});
