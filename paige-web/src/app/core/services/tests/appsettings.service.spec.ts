import { TestBed } from '@angular/core/testing';
import { HttpBackend } from '@angular/common/http';
import { of, throwError } from 'rxjs';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { Variables } from '~/core/classes/user/variables';
import { AppSettings } from '~/core/models/appsettings';

describe('AppSettingsService', () => {
    let service: AppSettingsService;
    let mockHttpBackend: any;

    const mockAppSettings: AppSettings = {
        title: 'PAIGE',
        version: '1.0.0',
        showNav: true,
        showFooter: true,
        openAccess: false,
        roles: ['admin', 'user'],
        user: null
    } as AppSettings;

    beforeEach(() => {
        // Mock HttpBackend
        mockHttpBackend = {};

        TestBed.configureTestingModule({
            providers: [
                AppSettingsService,
                { provide: HttpBackend, useValue: mockHttpBackend }
            ]
        });

        service = TestBed.inject(AppSettingsService);

        // Mock Variables
        jest.spyOn(Variables, 'get').mockReturnValue(null);
        jest.spyOn(Variables, 'set').mockImplementation(() => {});
        jest.spyOn(Variables, 'clear').mockImplementation(() => {});
    });

    afterEach(() => {
        jest.clearAllMocks();
        jest.restoreAllMocks();
    });

    describe('Service Creation', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should create HttpClient with HttpBackend', () => {
            expect(service['http']).toBeDefined();
        });
    });

    describe('init', () => {
        it('should load settings from assets/appsettings.json', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));

            const result = await service.init();

            expect(service['http'].get).toHaveBeenCalledWith('assets/appsettings.json');
            expect(result).toBe(true);
        });

        it('should save settings after loading', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));
            const saveSettingsSpy = jest.spyOn(service, 'saveSettings');

            await service.init();

            expect(saveSettingsSpy).toHaveBeenCalledWith(mockAppSettings);
        });

        it('should resolve with true on successful load', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));

            const result = await service.init();

            expect(result).toBe(true);
        });

        it('should reject with error when HTTP request fails', async () => {
            const errorResponse = new Error('Failed to load settings');
            jest.spyOn(service['http'], 'get').mockReturnValue(throwError(() => errorResponse));

            await expect(service.init()).rejects.toThrow('Failed to load settings');
        });

        it('should reject with 404 error when file not found', async () => {
            const error404 = new Error('404 Not Found');
            jest.spyOn(service['http'], 'get').mockReturnValue(throwError(() => error404));

            await expect(service.init()).rejects.toThrow('404 Not Found');
        });

        it('should handle network errors', async () => {
            const networkError = new Error('Network connection failed');
            jest.spyOn(service['http'], 'get').mockReturnValue(throwError(() => networkError));

            await expect(service.init()).rejects.toThrow('Network connection failed');
        });

        it('should handle malformed JSON', async () => {
            const malformedData = { invalid: 'structure' };
            jest.spyOn(service['http'], 'get').mockReturnValue(of(malformedData));

            const result = await service.init();

            expect(result).toBe(true);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', malformedData);
        });
    });

    describe('getSettings', () => {
        it('should return settings from Variables when cached', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppSettings);

            const result = await service.getSettings();

            expect(result).toEqual(mockAppSettings);
            expect(Variables.get).toHaveBeenCalledWith('App.Settings');
        });

        it('should initialize settings when not cached', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(null) // First call returns null
                .mockReturnValueOnce(mockAppSettings); // Second call returns settings
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));

            const result = await service.getSettings();

            expect(service['http'].get).toHaveBeenCalledWith('assets/appsettings.json');
            expect(result).toEqual(mockAppSettings);
        });

        it('should initialize settings when initialize parameter is true', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(mockAppSettings) // First call returns cached settings
                .mockReturnValueOnce(mockAppSettings); // Second call returns updated settings
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));
            const initSpy = jest.spyOn(service, 'init');

            const result = await service.getSettings(true);

            expect(initSpy).toHaveBeenCalled();
            expect(result).toEqual(mockAppSettings);
        });

        it('should not initialize when settings exist and initialize is false', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppSettings);
            const initSpy = jest.spyOn(service, 'init');

            await service.getSettings(false);

            expect(initSpy).not.toHaveBeenCalled();
        });

        it('should handle empty settings object', async () => {
            const emptySettings = {} as AppSettings;
            jest.spyOn(Variables, 'get').mockReturnValue(emptySettings);

            const result = await service.getSettings();

            expect(result).toEqual(emptySettings);
        });

        it('should reload settings when cache is cleared', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(null)
                .mockReturnValueOnce(mockAppSettings);
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));

            const result = await service.getSettings();

            expect(service['http'].get).toHaveBeenCalled();
            expect(result).toEqual(mockAppSettings);
        });

        it('should handle multiple consecutive calls with cache', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppSettings);

            const result1 = await service.getSettings();
            const result2 = await service.getSettings();

            expect(result1).toEqual(mockAppSettings);
            expect(result2).toEqual(mockAppSettings);
            expect(Variables.get).toHaveBeenCalledTimes(2);
        });
    });

    describe('saveSettings', () => {
        it('should save settings to Variables', async () => {
            await service.saveSettings(mockAppSettings);

            expect(Variables.set).toHaveBeenCalledWith('App.Settings', mockAppSettings);
        });

        it('should initialize empty roles array when roles is undefined', async () => {
            const settingsWithoutRoles = { ...mockAppSettings, roles: undefined } as any;

            await service.saveSettings(settingsWithoutRoles);

            expect(settingsWithoutRoles.roles).toEqual([]);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', settingsWithoutRoles);
        });

        it('should initialize empty roles array when roles is null', async () => {
            const settingsWithNullRoles = { ...mockAppSettings, roles: null as any };

            await service.saveSettings(settingsWithNullRoles);

            expect(settingsWithNullRoles.roles).toEqual([]);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', settingsWithNullRoles);
        });

        it('should not modify roles when already exists', async () => {
            const settingsWithRoles = { ...mockAppSettings, roles: ['admin', 'user'] };

            await service.saveSettings(settingsWithRoles);

            expect(settingsWithRoles.roles).toEqual(['admin', 'user']);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', settingsWithRoles);
        });

        it('should handle settings with empty roles array', async () => {
            const settingsWithEmptyRoles = { ...mockAppSettings, roles: [] };

            await service.saveSettings(settingsWithEmptyRoles);

            expect(settingsWithEmptyRoles.roles).toEqual([]);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', settingsWithEmptyRoles);
        });

        it('should resolve promise after saving', async () => {
            const result = await service.saveSettings(mockAppSettings);

            expect(result).toBeUndefined();
        });

        it('should save settings with user data', async () => {
            const settingsWithUser = {
                ...mockAppSettings,
                user: { id: 1, name: 'John Doe', email: 'john@example.com' }
            };

            await service.saveSettings(settingsWithUser);

            expect(Variables.set).toHaveBeenCalledWith('App.Settings', settingsWithUser);
        });

        it('should handle multiple properties in settings', async () => {
            const complexSettings = {
                ...mockAppSettings,
                apiUrl: 'https://api.example.com',
                timeout: 5000,
                features: { darkMode: true, notifications: false }
            } as any;

            await service.saveSettings(complexSettings);

            expect(Variables.set).toHaveBeenCalledWith('App.Settings', complexSettings);
        });
    });

    describe('clearSettings', () => {
        it('should clear settings from Variables', () => {
            service.clearSettings();

            expect(Variables.clear).toHaveBeenCalledWith('App.Settings');
        });

        it('should allow getting settings after clearing', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(mockAppSettings) // Before clear
                .mockReturnValueOnce(null) // After clear
                .mockReturnValueOnce(mockAppSettings); // After reload
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));

            // Get settings (cached)
            await service.getSettings();
            
            // Clear settings
            service.clearSettings();
            
            // Get settings again (should reload)
            await service.getSettings();

            expect(Variables.clear).toHaveBeenCalledWith('App.Settings');
            expect(service['http'].get).toHaveBeenCalled();
        });

        it('should be callable multiple times', () => {
            service.clearSettings();
            service.clearSettings();
            service.clearSettings();

            expect(Variables.clear).toHaveBeenCalledTimes(3);
            expect(Variables.clear).toHaveBeenCalledWith('App.Settings');
        });
    });

    describe('Integration Tests', () => {
        it('should complete full lifecycle: init -> get -> save -> clear', async () => {
            // Init
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));
            await service.init();

            // Get
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppSettings);
            const settings = await service.getSettings();
            expect(settings).toEqual(mockAppSettings);

            // Save
            const updatedSettings = { ...mockAppSettings, version: '2.0.0' };
            await service.saveSettings(updatedSettings);
            expect(Variables.set).toHaveBeenCalledWith('App.Settings', updatedSettings);

            // Clear
            service.clearSettings();
            expect(Variables.clear).toHaveBeenCalledWith('App.Settings');
        });

        it('should handle error recovery: failed init -> successful retry', async () => {
            // First attempt fails
            jest.spyOn(service['http'], 'get').mockReturnValueOnce(throwError(() => new Error('Network error')));
            await expect(service.init()).rejects.toThrow('Network error');

            // Second attempt succeeds
            jest.spyOn(service['http'], 'get').mockReturnValueOnce(of(mockAppSettings));
            const result = await service.init();
            expect(result).toBe(true);
        });

        it('should maintain settings integrity across operations', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));
            
            // Initialize
            await service.init();
            
            // Verify saved correctly
            const saveCall = (Variables.set as jest.Mock).mock.calls[0];
            expect(saveCall[1]).toEqual(mockAppSettings);
            
            // Verify roles were preserved
            expect(saveCall[1].roles).toEqual(['admin', 'user']);
        });

        it('should handle rapid consecutive operations', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppSettings));
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppSettings);

            // Multiple rapid operations
            const promises = [
                service.getSettings(),
                service.saveSettings(mockAppSettings),
                service.getSettings(),
                service.saveSettings(mockAppSettings)
            ];

            await Promise.all(promises);

            // All operations should complete successfully
            expect(Variables.get).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalled();
        });
    });
});
