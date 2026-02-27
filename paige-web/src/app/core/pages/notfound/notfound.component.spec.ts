import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Location } from '@angular/common';
import { NotFoundComponent } from './notfound.component';
import { AppSettings } from '~/core/models/appsettings';

describe('NotFoundComponent', () => {
    let component: NotFoundComponent;
    let fixture: ComponentFixture<NotFoundComponent>;
    let mockLocation: jest.Mocked<Location>;

    beforeEach(async () => {
        // Create mock Location
        mockLocation = {
            back: jest.fn()
        } as any;

        await TestBed.configureTestingModule({
            imports: [NotFoundComponent],
            providers: [
                { provide: Location, useValue: mockLocation }
            ]
        }).compileComponents();

        fixture = TestBed.createComponent(NotFoundComponent);
        component = fixture.componentInstance;
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    describe('Component Initialization', () => {
        it('should create', () => {
            expect(component).toBeTruthy();
        });

        it('should initialize with new AppSettings instance', () => {
            expect(component.appSettings).toBeDefined();
            expect(component.appSettings).toBeInstanceOf(AppSettings);
        });

        it('should be a standalone component', () => {
            const componentMetadata = (NotFoundComponent as any).ɵcmp;
            expect(componentMetadata.standalone).toBe(true);
        });

        it('should have correct selector', () => {
            const componentMetadata = (NotFoundComponent as any).ɵcmp;
            expect(componentMetadata.selectors).toEqual([['notfound']]);
        });
    });

    describe('Public Properties', () => {
        it('should have appSettings as public property', () => {
            expect(component.appSettings).toBeDefined();
            expect(typeof component.appSettings).toBe('object');
        });

        it('should allow appSettings to be modified', () => {
            const newSettings = new AppSettings();
            newSettings.title = 'Test Title';
            
            component.appSettings = newSettings;
            
            expect(component.appSettings).toBe(newSettings);
            expect(component.appSettings.title).toBe('Test Title');
        });

        it('should maintain appSettings instance across change detection', () => {
            const originalSettings = component.appSettings;
            
            fixture.detectChanges();
            
            expect(component.appSettings).toBe(originalSettings);
        });
    });

    describe('goBack method', () => {
        it('should call location.back when invoked', () => {
            // Act
            component.goBack();

            // Assert
            expect(mockLocation.back).toHaveBeenCalledTimes(1);
        });

        it('should call location.back with no arguments', () => {
            // Act
            component.goBack();

            // Assert
            expect(mockLocation.back).toHaveBeenCalledWith();
        });

        it('should handle multiple consecutive calls', () => {
            // Act
            component.goBack();
            component.goBack();
            component.goBack();

            // Assert
            expect(mockLocation.back).toHaveBeenCalledTimes(3);
        });

        it('should not throw error when called', () => {
            // Act & Assert
            expect(() => component.goBack()).not.toThrow();
        });

        it('should work correctly after component initialization', () => {
            // Arrange
            fixture.detectChanges();

            // Act
            component.goBack();

            // Assert
            expect(mockLocation.back).toHaveBeenCalled();
        });

        it('should handle rapid successive calls', () => {
            // Act
            for (let i = 0; i < 10; i++) {
                component.goBack();
            }

            // Assert
            expect(mockLocation.back).toHaveBeenCalledTimes(10);
        });
    });

    describe('Location Service Integration', () => {
        it('should inject Location service', () => {
            expect(mockLocation).toBeDefined();
        });

        it('should use the provided Location service', () => {
            component.goBack();
            expect(mockLocation.back).toHaveBeenCalled();
        });

        it('should not call location.back on component creation', () => {
            expect(mockLocation.back).not.toHaveBeenCalled();
        });

        it('should only call location.back when goBack is explicitly invoked', () => {
            fixture.detectChanges();
            expect(mockLocation.back).not.toHaveBeenCalled();

            component.goBack();
            expect(mockLocation.back).toHaveBeenCalledTimes(1);
        });
    });

    describe('AppSettings Behavior', () => {
        it('should have independent AppSettings instance per component', () => {
            const fixture1 = TestBed.createComponent(NotFoundComponent);
            const component1 = fixture1.componentInstance;

            const fixture2 = TestBed.createComponent(NotFoundComponent);
            const component2 = fixture2.componentInstance;

            expect(component1.appSettings).not.toBe(component2.appSettings);
        });

        it('should allow appSettings properties to be accessed', () => {
            component.appSettings.title = 'Page Not Found';
            
            expect(component.appSettings.title).toBe('Page Not Found');
        });

        it('should allow appSettings to be replaced entirely', () => {
            const newSettings = new AppSettings();
            newSettings.title = 'Custom 404';
            newSettings.supportLink = 'https://support.example.com';

            component.appSettings = newSettings;

            expect(component.appSettings.title).toBe('Custom 404');
            expect(component.appSettings.supportLink).toBe('https://support.example.com');
        });

        it('should maintain appSettings after goBack is called', () => {
            component.appSettings.title = 'Test';
            
            component.goBack();
            
            expect(component.appSettings.title).toBe('Test');
        });
    });

    describe('Method Accessibility', () => {
        it('should have goBack as a public method', () => {
            expect(typeof component.goBack).toBe('function');
        });

        it('should be callable from external context', () => {
            const goBackMethod = component.goBack.bind(component);
            
            expect(() => goBackMethod()).not.toThrow();
            expect(mockLocation.back).toHaveBeenCalled();
        });
    });

    describe('Component State', () => {
        it('should not modify appSettings when goBack is called', () => {
            const originalSettings = component.appSettings;
            
            component.goBack();
            
            expect(component.appSettings).toBe(originalSettings);
        });

        it('should remain functional after multiple change detections', () => {
            fixture.detectChanges();
            fixture.detectChanges();
            fixture.detectChanges();

            component.goBack();

            expect(mockLocation.back).toHaveBeenCalledTimes(1);
        });

        it('should maintain state consistency', () => {
            const initialSettings = component.appSettings;
            
            component.goBack();
            fixture.detectChanges();
            component.goBack();
            fixture.detectChanges();

            expect(component.appSettings).toBe(initialSettings);
            expect(mockLocation.back).toHaveBeenCalledTimes(2);
        });
    });

    describe('Edge Cases', () => {
        it('should handle goBack when Location service is mocked', () => {
            expect(() => component.goBack()).not.toThrow();
        });

        it('should work when appSettings is replaced and goBack is called', () => {
            component.appSettings = new AppSettings();
            component.appSettings.title = 'New Settings';

            component.goBack();

            expect(mockLocation.back).toHaveBeenCalled();
            expect(component.appSettings.title).toBe('New Settings');
        });

        it('should handle null assignment to appSettings', () => {
            component.appSettings = null as any;
            
            expect(component.appSettings).toBeNull();
            
            // goBack should still work
            expect(() => component.goBack()).not.toThrow();
        });

        it('should handle undefined assignment to appSettings', () => {
            component.appSettings = undefined as any;
            
            expect(component.appSettings).toBeUndefined();
            
            // goBack should still work
            expect(() => component.goBack()).not.toThrow();
        });
    });

    describe('Integration Scenarios', () => {
        it('should support typical 404 page workflow', () => {
            // User lands on 404 page
            fixture.detectChanges();
            expect(component).toBeTruthy();

            // User clicks back button
            component.goBack();
            expect(mockLocation.back).toHaveBeenCalled();
        });

        it('should handle multiple users clicking back', () => {
            const instances = [
                TestBed.createComponent(NotFoundComponent).componentInstance,
                TestBed.createComponent(NotFoundComponent).componentInstance,
                TestBed.createComponent(NotFoundComponent).componentInstance
            ];

            instances.forEach(instance => {
                instance.goBack();
            });

            // Each instance should have called back independently
            expect(mockLocation.back).toHaveBeenCalledTimes(3);
        });

        it('should maintain component integrity through typical user interactions', () => {
            fixture.detectChanges();
            
            // Simulate user viewing the page
            expect(component.appSettings).toBeDefined();
            
            // Simulate user clicking back
            component.goBack();
            expect(mockLocation.back).toHaveBeenCalled();
            
            // Component should still be stable
            expect(component).toBeTruthy();
            expect(component.appSettings).toBeDefined();
        });
    });
});
