import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { EventEmitter, NO_ERRORS_SCHEMA } from '@angular/core';

import { HeaderComponent } from './header.component';

// Mock the imports
jest.mock('~/core/services/graph.service', () => ({
    GraphService: jest.fn().mockImplementation(() => ({
        getUserPhoto: jest.fn()
    }))
}));

jest.mock('~/core/services/appconfig.service', () => ({
    AppConfigService: jest.fn().mockImplementation(() => ({
        getConfig: jest.fn()
    }))
}));

jest.mock('~/core/services/appsettings.service', () => ({
    AppSettingsService: jest.fn().mockImplementation(() => ({
        getSettings: jest.fn(),
        saveSettings: jest.fn()
    }))
}));

jest.mock('~/core/models/appconfig', () => ({
    AppConfig: jest.fn().mockImplementation(() => ({}))
}));

jest.mock('~/core/models/appsettings', () => ({
    AppSettings: jest.fn().mockImplementation(() => ({
        user: null
    }))
}));

// Import the mocked classes
import { GraphService } from '~/core/services/graph.service';
import { AppConfigService } from '~/core/services/appconfig.service';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { AppConfig } from '~/core/models/appconfig';
import { AppSettings } from '~/core/models/appsettings';

describe('HeaderComponent', () => {
    let component: HeaderComponent;
    let fixture: ComponentFixture<HeaderComponent>;
    let mockRouter: any;
    let mockGraphService: any;
    let mockAppConfigService: any;
    let mockAppSettingsService: any;

    beforeEach(async () => {
        // Create mock router
        mockRouter = {
            navigateByUrl: jest.fn().mockResolvedValue(true),
            url: '/header'
        };

        // Create mock GraphService
        mockGraphService = {
            getUserPhoto: jest.fn()
        };

        // Create mock AppConfigService
        mockAppConfigService = {
            getConfig: jest.fn()
        };

        // Create mock AppSettingsService
        mockAppSettingsService = {
            getSettings: jest.fn(),
            saveSettings: jest.fn()
        };

        await TestBed.configureTestingModule({
            imports: [HeaderComponent],
            providers: [
                { provide: Router, useValue: mockRouter },
                { provide: GraphService, useValue: mockGraphService },
                { provide: AppConfigService, useValue: mockAppConfigService },
                { provide: AppSettingsService, useValue: mockAppSettingsService }
            ],
            schemas: [NO_ERRORS_SCHEMA]
        }).compileComponents();

        // Reset all mocks before each test
        jest.clearAllMocks();
    });

    describe('Constructor', () => {
        it('should create component', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component).toBeTruthy();
        });

        it('should initialize title as "Joint Pole Records Tracker"', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.title).toBe("Joint Pole Records Tracker");
        });

        it('should initialize env as empty string', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.env).toBe("");
        });

        it('should initialize itemsClass as empty string', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.itemsClass).toBe("");
        });

        it('should initialize initials as empty string', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.initials).toBe("");
        });

        it('should initialize showPhoto as false', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.showPhoto).toBe(false);
        });

        it('should initialize appSettings', () => {
            // Act
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;

            // Assert
            expect(component.appSettings).toBeDefined();
        });
    });

    describe('ngOnInit', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should call getConfig and set env to uppercase', async () => {
            // Arrange
            const mockConfig = { environment: 'development' };
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue({ user: { photo: 'photo-data' } });
            jest.spyOn(component as any, 'getUserInfo').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(mockAppConfigService.getConfig).toHaveBeenCalled();
            expect(component.env).toBe('DEVELOPMENT');
            expect((component as any).getUserInfo).toHaveBeenCalled();
        });

        it('should handle config without environment', async () => {
            // Arrange
            const mockConfig = {};
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue({ user: { photo: 'photo-data' } });
            jest.spyOn(component as any, 'getUserInfo').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(mockAppConfigService.getConfig).toHaveBeenCalled();
            expect(component.env).toBe("");
        });

        it('should convert environment to uppercase', async () => {
            // Arrange
            const mockConfig = { environment: 'production' };
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue({ user: { photo: 'photo-data' } });
            jest.spyOn(component as any, 'getUserInfo').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(component.env).toBe('PRODUCTION');
        });

        it('should handle mixed case environment', async () => {
            // Arrange
            const mockConfig = { environment: 'StAgInG' };
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue({ user: { photo: 'photo-data' } });
            jest.spyOn(component as any, 'getUserInfo').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(component.env).toBe('STAGING');
        });
    });

    describe('navigateTo', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should navigate to provided URL', () => {
            // Arrange
            const testUrl = '/test-route';

            // Act
            component.navigateTo(testUrl);

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith(testUrl);
        });

        it('should navigate to home', () => {
            // Act
            component.navigateTo('/home');

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith('/home');
        });

        it('should navigate to settings', () => {
            // Act
            component.navigateTo('/settings');

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith('/settings');
        });
    });

    describe('getUserInfo (private method)', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should get user photo from graph service when photo is empty', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    photo: ''
                }
            };
            const mockPhoto = 'base64-photo-data';
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);
            mockGraphService.getUserPhoto.mockResolvedValue(mockPhoto);

            // Act
            await (component as any).getUserInfo();

            // Assert
            expect(mockAppSettingsService.getSettings).toHaveBeenCalled();
            expect(mockGraphService.getUserPhoto).toHaveBeenCalled();
            expect(component.appSettings.user.photo).toBe(mockPhoto);
            expect(component.showPhoto).toBe(true);
            expect(mockAppSettingsService.saveSettings).toHaveBeenCalledWith(mockSettings);
        });

        it('should set showPhoto to false when graph service returns empty photo', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    photo: ''
                }
            };
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);
            mockGraphService.getUserPhoto.mockResolvedValue('');

            // Act
            await (component as any).getUserInfo();

            // Assert
            expect(mockGraphService.getUserPhoto).toHaveBeenCalled();
            expect(component.appSettings.user.photo).toBe('');
            expect(component.showPhoto).toBe(false);
            expect(mockAppSettingsService.saveSettings).toHaveBeenCalledWith(mockSettings);
        });

        it('should set showPhoto to true when user already has photo', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    photo: 'existing-photo-data'
                }
            };
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);

            // Act
            await (component as any).getUserInfo();

            // Assert
            expect(mockAppSettingsService.getSettings).toHaveBeenCalled();
            expect(mockGraphService.getUserPhoto).not.toHaveBeenCalled();
            expect(component.showPhoto).toBe(true);
            expect(mockAppSettingsService.saveSettings).not.toHaveBeenCalled();
        });

        it('should update appSettings with fetched photo', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    photo: '',
                    name: 'Test User'
                }
            };
            const mockPhoto = 'new-photo-data';
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);
            mockGraphService.getUserPhoto.mockResolvedValue(mockPhoto);

            // Act
            await (component as any).getUserInfo();

            // Assert
            expect(component.appSettings.user.photo).toBe(mockPhoto);
            expect(component.appSettings.user.name).toBe('Test User');
        });
    });

    describe('Output Events', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should have setLayoutCssClass output', () => {
            // Assert
            expect(component.setLayoutCssClass).toBeDefined();
            expect(component.setLayoutCssClass).toBeInstanceOf(EventEmitter);
        });

        it('should emit setLayoutCssClass event', (done) => {
            // Arrange
            const testData = { layout: 'expanded' };

            component.setLayoutCssClass.subscribe((data: any) => {
                // Assert
                expect(data).toEqual(testData);
                done();
            });

            // Act
            component.setLayoutCssClass.emit(testData);
        });

        it('should have reloadPage output', () => {
            // Assert
            expect(component.reloadPage).toBeDefined();
            expect(component.reloadPage).toBeInstanceOf(EventEmitter);
        });

        it('should emit reloadPage event', (done) => {
            // Arrange
            component.reloadPage.subscribe(() => {
                // Assert
                done();
            });

            // Act
            component.reloadPage.emit();
        });
    });

    describe('Input Properties', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should accept title input', () => {
            // Act
            component.title = 'Custom Title';

            // Assert
            expect(component.title).toBe('Custom Title');
        });

        it('should use default title when not provided', () => {
            // Assert
            expect(component.title).toBe('Joint Pole Records Tracker');
        });
    });

    describe('Edge Cases', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should handle empty string environment', async () => {
            // Arrange
            const mockConfig = { environment: '' };
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue({ user: { photo: 'photo' } });
            jest.spyOn(component as any, 'getUserInfo').mockResolvedValue(undefined);

            // Act
            component.ngOnInit();
            await fixture.whenStable();

            // Assert
            expect(component.env).toBe('');
        });

        it('should handle navigateTo with empty string', () => {
            // Act
            component.navigateTo('');

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith('');
        });

        it('should handle navigateTo with special characters', () => {
            // Arrange
            const specialUrl = '/path?query=value&other=123#anchor';

            // Act
            component.navigateTo(specialUrl);

            // Assert
            expect(mockRouter.navigateByUrl).toHaveBeenCalledWith(specialUrl);
        });

        it('should not throw when getUserPhoto rejects', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    photo: ''
                }
            };
            const mockError = new Error('Photo fetch failed');
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);
            mockGraphService.getUserPhoto.mockRejectedValue(mockError);

            // Act & Assert - should not throw because .then() is used
            await expect((component as any).getUserInfo()).resolves.toBeUndefined();
        });

        it('should handle user with no photo property gracefully', async () => {
            // Arrange
            const mockSettings = {
                user: {
                    name: 'Test User'
                    // No photo property
                }
            };
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);

            // Act
            await (component as any).getUserInfo();

            // Assert - should handle gracefully, photo will be undefined
            expect(mockAppSettingsService.getSettings).toHaveBeenCalled();
        });
    });

    describe('Integration Tests', () => {
        beforeEach(() => {
            fixture = TestBed.createComponent(HeaderComponent);
            component = fixture.componentInstance;
        });

        it('should complete full initialization flow successfully', async () => {
            // Arrange
            const mockConfig = { environment: 'production' };
            const mockSettings = {
                user: {
                    photo: '',
                    name: 'Test User'
                }
            };
            const mockPhoto = 'photo-data';
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);
            mockGraphService.getUserPhoto.mockResolvedValue(mockPhoto);

            // Act
            component.ngOnInit();
            await fixture.whenStable();
            
            // Wait for .then() promise chain to complete
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.env).toBe('PRODUCTION');
            expect(component.showPhoto).toBe(true);
            expect(component.appSettings.user.photo).toBe(mockPhoto);
            expect(mockAppSettingsService.saveSettings).toHaveBeenCalled();
        });

        it('should handle initialization with existing photo', async () => {
            // Arrange
            const mockConfig = { environment: 'staging' };
            const mockSettings = {
                user: {
                    photo: 'existing-photo',
                    name: 'Test User'
                }
            };
            mockAppConfigService.getConfig.mockResolvedValue(mockConfig);
            mockAppSettingsService.getSettings.mockResolvedValue(mockSettings);

            // Act
            component.ngOnInit();
            await fixture.whenStable();
            
            // Wait for .then() promise chain to complete
            await new Promise(resolve => setTimeout(resolve, 0));

            // Assert
            expect(component.env).toBe('STAGING');
            expect(component.showPhoto).toBe(true);
            expect(mockGraphService.getUserPhoto).not.toHaveBeenCalled();
            expect(mockAppSettingsService.saveSettings).not.toHaveBeenCalled();
        });
    });
});
