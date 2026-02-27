import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AccessComponent } from './access.component';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { AppSettings } from '~/core/models/appsettings';

describe('AccessComponent', () => {
    let component: AccessComponent;
    let fixture: ComponentFixture<AccessComponent>;
    let mockAppSettingsService: jest.Mocked<AppSettingsService>;
    let mockAppSettings: AppSettings;
    let originalHistoryState: any;

    beforeEach(async () => {
        // Save original history state
        originalHistoryState = globalThis.history.state;
        
        // Set default history state to prevent null reference errors
        Object.defineProperty(globalThis.history, 'state', {
            value: {},
            writable: true,
            configurable: true
        });

        // Create mock AppSettings
        mockAppSettings = new AppSettings();
        mockAppSettings.title = 'Test Application';
        mockAppSettings.supportLink = 'https://support.example.com';

        // Create mock service
        mockAppSettingsService = {
            getSettings: jest.fn().mockResolvedValue(mockAppSettings)
        } as any;

        await TestBed.configureTestingModule({
            imports: [AccessComponent],
            providers: [
                { provide: AppSettingsService, useValue: mockAppSettingsService }
            ]
        }).compileComponents();

        fixture = TestBed.createComponent(AccessComponent);
        component = fixture.componentInstance;
    });

    afterEach(() => {
        jest.restoreAllMocks();
        
        // Restore original history state
        Object.defineProperty(globalThis.history, 'state', {
            value: originalHistoryState,
            writable: true,
            configurable: true
        });
    });

    describe('Component Initialization', () => {
        it('should create', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize with default values', () => {
            expect(component.title).toBe('');
            expect(component.type).toBe('application');
            expect(component.supportLink).toBe('');
        });

        it('should be a standalone component', () => {
            const componentMetadata = (AccessComponent as any).ɵcmp;
            expect(componentMetadata.standalone).toBe(true);
        });

        it('should have correct selector', () => {
            const componentMetadata = (AccessComponent as any).ɵcmp;
            expect(componentMetadata.selectors).toEqual([['access']]);
        });
    });

    describe('ngOnInit', () => {
        it('should fetch app settings on init', async () => {
            // Arrange
            fixture.detectChanges(); // Triggers ngOnInit

            // Wait for async operations
            await fixture.whenStable();

            // Assert
            expect(mockAppSettingsService.getSettings).toHaveBeenCalledTimes(1);
        });

        it('should set title from app settings', async () => {
            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.title).toBe('Test Application');
        });

        it('should set supportLink from app settings', async () => {
            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.supportLink).toBe('https://support.example.com');
        });

        it('should use default type when no history state is present', async () => {
            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe('application');
        });

        it('should set type from history state when provided', async () => {
            // Arrange
            Object.defineProperty(globalThis.history, 'state', {
                value: { type: 'admin' },
                writable: true,
                configurable: true
            });

            // Recreate component with new state
            fixture = TestBed.createComponent(AccessComponent);
            component = fixture.componentInstance;

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe('admin');
        });

        it('should not change type when history state type is empty string', async () => {
            // Arrange
            Object.defineProperty(globalThis.history, 'state', {
                value: { type: '' },
                writable: true,
                configurable: true
            });

            // Recreate component with new state
            fixture = TestBed.createComponent(AccessComponent);
            component = fixture.componentInstance;

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe('application');
        });

        it('should handle different type values from history state', async () => {
            // Arrange
            const testTypes = ['user', 'guest', 'superadmin', 'readonly'];

            for (const testType of testTypes) {
                Object.defineProperty(globalThis.history, 'state', {
                    value: { type: testType },
                    writable: true,
                    configurable: true
                });

                // Create new component instance for each test
                const testFixture = TestBed.createComponent(AccessComponent);
                const testComponent = testFixture.componentInstance;

                // Act
                testFixture.detectChanges();
                await testFixture.whenStable();

                // Assert
                expect(testComponent.type).toBe(testType);
            }
        });

        it('should handle app settings with empty values', async () => {
            // Arrange
            const emptySettings = new AppSettings();
            emptySettings.title = '';
            emptySettings.supportLink = '';
            mockAppSettingsService.getSettings.mockResolvedValue(emptySettings);

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.title).toBe('');
            expect(component.supportLink).toBe('');
        });

        it('should handle app settings with special characters', async () => {
            // Arrange
            const specialSettings = new AppSettings();
            specialSettings.title = 'Test & Special <Characters>';
            specialSettings.supportLink = 'https://support.example.com?param=value&other=123';
            mockAppSettingsService.getSettings.mockResolvedValue(specialSettings);

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.title).toBe('Test & Special <Characters>');
            expect(component.supportLink).toBe('https://support.example.com?param=value&other=123');
        });
    });

    describe('Service Integration', () => {
        it('should call getSettings only once during initialization', async () => {
            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Multiple change detections should not trigger additional calls
            fixture.detectChanges();
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(mockAppSettingsService.getSettings).toHaveBeenCalledTimes(1);
        });

        it('should update component properties after async settings load', async () => {
            // Arrange
            const delayedSettings = new AppSettings();
            delayedSettings.title = 'Delayed Title';
            delayedSettings.supportLink = 'https://delayed.example.com';

            // Update the existing mock to return delayed settings
            mockAppSettingsService.getSettings.mockImplementation(() => {
                return new Promise((resolve) => {
                    setTimeout(() => resolve(delayedSettings), 50);
                });
            });

            // Create a new component fixture
            const testFixture = TestBed.createComponent(AccessComponent);
            const testComponent = testFixture.componentInstance;

            // Act
            testFixture.detectChanges();
            
            // Before promise resolves
            expect(testComponent.title).toBe('');
            
            // Wait for promise to resolve
            await new Promise(resolve => setTimeout(resolve, 60));

            // Assert - after promise resolves
            expect(testComponent.title).toBe('Delayed Title');
            expect(testComponent.supportLink).toBe('https://delayed.example.com');
            
            // Reset mock for other tests
            mockAppSettingsService.getSettings.mockResolvedValue(mockAppSettings);
        });
    });

    describe('Public Properties', () => {
        it('should have title as public property', () => {
            expect(component.title).toBeDefined();
            expect(typeof component.title).toBe('string');
        });

        it('should have type as public property', () => {
            expect(component.type).toBeDefined();
            expect(typeof component.type).toBe('string');
        });

        it('should have supportLink as public property', () => {
            expect(component.supportLink).toBeDefined();
            expect(typeof component.supportLink).toBe('string');
        });

        it('should allow title to be modified', () => {
            component.title = 'New Title';
            expect(component.title).toBe('New Title');
        });

        it('should allow type to be modified', () => {
            component.type = 'custom';
            expect(component.type).toBe('custom');
        });

        it('should allow supportLink to be modified', () => {
            component.supportLink = 'https://new-support.example.com';
            expect(component.supportLink).toBe('https://new-support.example.com');
        });
    });

    describe('History State Edge Cases', () => {
        it('should handle history state with type as null', async () => {
            // Arrange
            Object.defineProperty(globalThis.history, 'state', {
                value: { type: null },
                writable: true,
                configurable: true
            });

            // Recreate component
            fixture = TestBed.createComponent(AccessComponent);
            component = fixture.componentInstance;

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe('application');
        });

        it('should handle history state with type as number', async () => {
            // Arrange
            Object.defineProperty(globalThis.history, 'state', {
                value: { type: 123 },
                writable: true,
                configurable: true
            });

            // Recreate component
            fixture = TestBed.createComponent(AccessComponent);
            component = fixture.componentInstance;

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe(123);
        });

        it('should handle history state with additional properties', async () => {
            // Arrange
            Object.defineProperty(globalThis.history, 'state', {
                value: { 
                    type: 'admin',
                    userId: 123,
                    extra: 'data'
                },
                writable: true,
                configurable: true
            });

            // Recreate component
            fixture = TestBed.createComponent(AccessComponent);
            component = fixture.componentInstance;

            // Act
            fixture.detectChanges();
            await fixture.whenStable();

            // Assert
            expect(component.type).toBe('admin');
        });
    });
});
