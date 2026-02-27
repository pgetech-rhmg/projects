import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { EventEmitter, NO_ERRORS_SCHEMA } from '@angular/core';

import { FooterComponent } from './footer.component';

// Mock the imports
jest.mock('~/core/app.component', () => ({
    AppComponent: jest.fn().mockImplementation(() => ({
        modal: undefined
    }))
}));

jest.mock('~/core/classes/user/variables', () => ({
    Variables: {
        get: jest.fn(),
        set: jest.fn()
    },
    VariableType: {
        Local: 'local',
        Session: 'session'
    }
}));

jest.mock('~/core/components/release-notes/release-notes.component', () => ({
    ReleaseNotesComponent: jest.fn().mockImplementation(() => ({}))
}));

// Import the mocked classes
import { AppComponent } from '~/core/app.component';
import { Variables, VariableType } from '~/core/classes/user/variables';
import { ReleaseNotesComponent } from '~/core/components/release-notes/release-notes.component';

describe('FooterComponent', () => {
    let component: FooterComponent;
    let fixture: ComponentFixture<FooterComponent>;
    let mockApp: any;

    beforeEach(async () => {
        // Create mock AppComponent
        mockApp = {
            modal: undefined
        };

        await TestBed.configureTestingModule({
            imports: [FooterComponent],
            providers: [
                { provide: AppComponent, useValue: mockApp }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        // Reset all mocks before each test
        jest.clearAllMocks();
        (Variables.get as jest.Mock).mockReturnValue(null);
        (Variables.set as jest.Mock).mockImplementation(() => {});
    });

    describe('Constructor', () => {
        it('should create component', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
        });

        it('should initialize version as "0.0.0"', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.version).toBe("0.0.0");
        });

        it('should initialize expand as false', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.expand).toBe(false);
        });

        it('should initialize date as Date object', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.date).toBeInstanceOf(Date);
        });

        it('should initialize appIcon as "web_asset"', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.appIcon).toBe("web_asset");
        });

        it('should initialize appTitle as "Application Mode"', () => {
            // Act
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.appTitle).toBe("Application Mode");
        });
    });

    describe('ngOnChanges', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
        });

        it('should call isNewRelease when version changes on first change', () => {
            // Arrange
            const changes = {
                version: {
                    currentValue: '1.2.3',
                    firstChange: true
                }
            };
            jest.spyOn(component, 'isNewRelease').mockImplementation();

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(component.isNewRelease).toHaveBeenCalledWith('1.2.3');
        });

        it('should not call isNewRelease when version changes but not first change', () => {
            // Arrange
            const changes = {
                version: {
                    currentValue: '1.2.3',
                    firstChange: false
                }
            };
            jest.spyOn(component, 'isNewRelease').mockImplementation();

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(component.isNewRelease).not.toHaveBeenCalled();
        });

        it('should not call isNewRelease when version is missing currentValue', () => {
            // Arrange
            const changes = {
                version: {
                    currentValue: null,
                    firstChange: true
                }
            };
            jest.spyOn(component, 'isNewRelease').mockImplementation();

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(component.isNewRelease).not.toHaveBeenCalled();
        });

        it('should set CSS property when expand changes to true', () => {
            // Arrange
            const changes = {
                expand: {
                    currentValue: true
                }
            };
            component.expand = true;
            const setPropertySpy = jest.spyOn(document.documentElement.style, 'setProperty');

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(setPropertySpy).toHaveBeenCalledWith('--left-padding', '250px');
        });

        it('should set CSS property when expand changes to false', () => {
            // Arrange
            const changes = {
                expand: {
                    currentValue: false
                }
            };
            component.expand = false;
            const setPropertySpy = jest.spyOn(document.documentElement.style, 'setProperty');

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(setPropertySpy).toHaveBeenCalledWith('--left-padding', '50px');
        });

        it('should not set CSS property when expand is not in changes', () => {
            // Arrange
            const changes = {
                version: {
                    currentValue: '1.2.3',
                    firstChange: true
                }
            };
            jest.spyOn(component, 'isNewRelease').mockImplementation();
            const setPropertySpy = jest.spyOn(document.documentElement.style, 'setProperty');

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(setPropertySpy).not.toHaveBeenCalled();
        });

        it('should handle both version and expand changes together', () => {
            // Arrange
            const changes = {
                version: {
                    currentValue: '1.2.3',
                    firstChange: true
                },
                expand: {
                    currentValue: true
                }
            };
            component.expand = true;
            jest.spyOn(component, 'isNewRelease').mockImplementation();
            const setPropertySpy = jest.spyOn(document.documentElement.style, 'setProperty');

            // Act
            component.ngOnChanges(changes);

            // Assert
            expect(component.isNewRelease).toHaveBeenCalledWith('1.2.3');
            expect(setPropertySpy).toHaveBeenCalledWith('--left-padding', '250px');
        });
    });

    describe('showReleaseNotes', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
        });

        it('should set modal on app with ReleaseNotesComponent', () => {
            // Act
            component.showReleaseNotes();

            // Assert
            expect(mockApp.modal).toBeDefined();
            expect(mockApp.modal.type).toBe(ReleaseNotesComponent);
            expect(mockApp.modal.inputs).toEqual({});
            expect(mockApp.modal.outputs).toBeDefined();
        });

        it('should configure closeEvent to clear modal', () => {
            // Act
            component.showReleaseNotes();

            // Assert
            expect(mockApp.modal.outputs.closeEvent).toBeDefined();
            
            // Execute the closeEvent
            mockApp.modal.outputs.closeEvent();
            
            expect(mockApp.modal).toBeUndefined();
        });
    });

    describe('isNewRelease', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
            jest.useFakeTimers({ doNotFake: ['Date'] });
        });

        afterEach(() => {
            jest.useRealTimers();
        });

        it('should show release notes when no previous version exists', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue(null);
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.3');

            // Assert - should set up interval
            expect(Variables.get).toHaveBeenCalledWith("App.Version", VariableType.Local);
            
            // Fast-forward time to trigger interval
            tick(1000);

            expect(component.showReleaseNotes).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '1.2.3', VariableType.Local);
        }));

        it('should show release notes when major version changes', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('2.0.0');

            // Assert
            tick(1000);

            expect(component.showReleaseNotes).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '2.0.0', VariableType.Local);
        }));

        it('should show release notes when minor version changes', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.3.0');

            // Assert
            tick(1000);

            expect(component.showReleaseNotes).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '1.3.0', VariableType.Local);
        }));

        it('should not show release notes when only patch version changes', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.4');

            // Assert
            expect(component.showReleaseNotes).not.toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '1.2.4', VariableType.Local);
        });

        it('should not show release notes when version is the same', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.3');

            // Assert
            expect(component.showReleaseNotes).not.toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '1.2.3', VariableType.Local);
        });

        it('should wait for modal to be cleared before showing release notes', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue(null);
            mockApp.modal = { type: 'SomeOtherModal' }; // Modal is already open
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.3');

            // Assert - first tick should not show notes because modal exists
            tick(1000);
            expect(component.showReleaseNotes).not.toHaveBeenCalled();

            // Clear the modal
            mockApp.modal = undefined;

            // Second tick should show notes
            tick(1000);
            expect(component.showReleaseNotes).toHaveBeenCalled();
        }));

        it('should handle version strings with less than 2 parts', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('2');

            // Assert - should not show window because version parts < 2
            expect(component.showReleaseNotes).not.toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '2', VariableType.Local);
        });

        it('should handle new version with less than 2 parts but old version valid', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('2');

            // Assert - should not show window because new version parts < 2
            expect(component.showReleaseNotes).not.toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '2', VariableType.Local);
        });

        it('should always set the new version in Variables', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.4');

            // Assert
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '1.2.4', VariableType.Local);
        });

        it('should clear interval after showing release notes', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue(null);
            mockApp.modal = undefined;
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();
            const clearIntervalSpy = jest.spyOn(global, 'clearInterval');

            // Act
            component.isNewRelease('1.2.3');

            // Assert
            tick(1000);
            
            expect(component.showReleaseNotes).toHaveBeenCalledTimes(1);
            expect(clearIntervalSpy).toHaveBeenCalled();

            // Verify interval doesn't fire again
            tick(1000);
            expect(component.showReleaseNotes).toHaveBeenCalledTimes(1);
        }));
    });

    describe('Output Events', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
        });

        it('should have setLayoutCssClass output', () => {
            // Assert
            expect(component.setLayoutCssClass).toBeDefined();
            expect(component.setLayoutCssClass).toBeInstanceOf(EventEmitter);
        });

        it('should emit setLayoutCssClass event', (done) => {
            // Arrange
            const testData = { someLayout: 'data' };

            component.setLayoutCssClass.subscribe((data: any) => {
                // Assert
                expect(data).toEqual(testData);
                done();
            });

            // Act
            component.setLayoutCssClass.emit(testData);
        });
    });

    describe('Input Properties', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
        });

        it('should accept version input', () => {
            // Act
            component.version = '2.3.4';

            // Assert
            expect(component.version).toBe('2.3.4');
        });

        it('should accept expand input', () => {
            // Act
            component.expand = true;

            // Assert
            expect(component.expand).toBe(true);
        });
    });

    describe('Edge Cases', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(FooterComponent);
            component = fixture.componentInstance;
        });

        it('should handle empty version string', fakeAsync(() => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue(null);
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('');

            // Assert
            tick(1000);
            
            // Should still show release notes for first time
            expect(component.showReleaseNotes).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalledWith("App.Version", '', VariableType.Local);
        }));

        it('should handle version with many parts', () => {
            // Arrange
            (Variables.get as jest.Mock).mockReturnValue('1.2.3.4.5');
            jest.spyOn(component, 'showReleaseNotes').mockImplementation();

            // Act
            component.isNewRelease('1.2.3.4.6');

            // Assert
            // Should not show because only major.minor are compared and they match
            expect(component.showReleaseNotes).not.toHaveBeenCalled();
        });

        it('should handle ngOnChanges with empty changes object', () => {
            // Arrange
            const changes = {};
            jest.spyOn(component, 'isNewRelease').mockImplementation();
            const setPropertySpy = jest.spyOn(document.documentElement.style, 'setProperty');

            // Act & Assert
            expect(() => component.ngOnChanges(changes)).not.toThrow();
            expect(component.isNewRelease).not.toHaveBeenCalled();
            expect(setPropertySpy).not.toHaveBeenCalled();
        });
    });
});
