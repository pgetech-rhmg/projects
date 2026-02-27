import { TestBed } from '@angular/core/testing';
import { HttpBackend } from '@angular/common/http';
import { of, throwError } from 'rxjs';
import { AppConfigService } from '~/core/services/appconfig.service';
import { Variables } from '~/core/classes/user/variables';
import { AppConfig } from '~/core/models/appconfig';

describe('AppConfigService', () => {
    let service: AppConfigService;
    let mockHttpBackend: any;

    const mockAppConfig: AppConfig = {
        environment: 'test',
        tenantId: 'tenant-123-456',
        clientId: 'client-abc-def',
        baseUrl: 'https://app.example.com',
        apiUrl: 'https://api.example.com'
    };

    beforeEach(() => {
        // Mock HttpBackend
        mockHttpBackend = {};

        TestBed.configureTestingModule({
            providers: [
                AppConfigService,
                { provide: HttpBackend, useValue: mockHttpBackend }
            ]
        });

        service = TestBed.inject(AppConfigService);

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
        it('should load config from assets/config.json', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));

            const result = await service.init();

            expect(service['http'].get).toHaveBeenCalledWith('assets/config.json');
            expect(result).toBe(true);
        });

        it('should save config after loading', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));
            const saveConfigSpy = jest.spyOn(service, 'saveConfig');

            await service.init();

            expect(saveConfigSpy).toHaveBeenCalledWith(mockAppConfig);
        });

        it('should resolve with true on successful load', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));

            const result = await service.init();

            expect(result).toBe(true);
        });

        it('should reject with error when HTTP request fails', async () => {
            const errorResponse = new Error('Failed to load config');
            jest.spyOn(service['http'], 'get').mockReturnValue(throwError(() => errorResponse));

            await expect(service.init()).rejects.toThrow('Failed to load config');
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
            expect(Variables.set).toHaveBeenCalledWith('App.Config', malformedData);
        });

        it('should handle empty config object', async () => {
            const emptyConfig = {};
            jest.spyOn(service['http'], 'get').mockReturnValue(of(emptyConfig));

            const result = await service.init();

            expect(result).toBe(true);
            expect(Variables.set).toHaveBeenCalledWith('App.Config', emptyConfig);
        });
    });

    describe('getConfig', () => {
        it('should return config from Variables when cached', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = await service.getConfig();

            expect(result).toEqual(mockAppConfig);
            expect(Variables.get).toHaveBeenCalledWith('App.Config');
        });

        it('should initialize config when not cached', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(null) // First call returns null
                .mockReturnValueOnce(mockAppConfig); // Second call returns config
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));

            const result = await service.getConfig();

            expect(service['http'].get).toHaveBeenCalledWith('assets/config.json');
            expect(result).toEqual(mockAppConfig);
        });

        it('should call init when config is not in storage', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(null)
                .mockReturnValueOnce(mockAppConfig);
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));
            const initSpy = jest.spyOn(service, 'init');

            await service.getConfig();

            expect(initSpy).toHaveBeenCalled();
        });

        it('should not call init when config exists in storage', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);
            const initSpy = jest.spyOn(service, 'init');

            await service.getConfig();

            expect(initSpy).not.toHaveBeenCalled();
        });

        it('should handle empty config object', async () => {
            const emptyConfig = {} as AppConfig;
            jest.spyOn(Variables, 'get').mockReturnValue(emptyConfig);

            const result = await service.getConfig();

            expect(result).toEqual(emptyConfig);
        });

        it('should handle multiple consecutive calls with cache', async () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result1 = await service.getConfig();
            const result2 = await service.getConfig();

            expect(result1).toEqual(mockAppConfig);
            expect(result2).toEqual(mockAppConfig);
            expect(Variables.get).toHaveBeenCalledTimes(2);
        });

        it('should reload config after cache is cleared', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(null)
                .mockReturnValueOnce(mockAppConfig);
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));

            const result = await service.getConfig();

            expect(service['http'].get).toHaveBeenCalled();
            expect(result).toEqual(mockAppConfig);
        });
    });

    describe('getConfigKey', () => {
        it('should return value for existing key', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('apiUrl');

            expect(result).toBe('https://api.example.com');
        });

        it('should return value for tenantId', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('tenantId');

            expect(result).toBe('tenant-123-456');
        });

        it('should return value for clientId', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('clientId');

            expect(result).toBe('client-abc-def');
        });

        it('should return value for baseUrl', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('baseUrl');

            expect(result).toBe('https://app.example.com');
        });

        it('should return null when config is not in storage', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(null);

            const result = service.getConfigKey('apiUrl');

            expect(result).toBeNull();
        });

        it('should return undefined for non-existent key', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('nonExistentKey');

            expect(result).toBeUndefined();
        });

        it('should return value for environment key', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('environment');

            expect(result).toBe('test');
        });

        it('should handle empty string key', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            const result = service.getConfigKey('');

            expect(result).toBeUndefined();
        });

        it('should call Variables.get with correct key', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            service.getConfigKey('apiUrl');

            expect(Variables.get).toHaveBeenCalledWith('App.Config');
        });
    });

    describe('saveConfig', () => {
        it('should save config to Variables', async () => {
            await service.saveConfig(mockAppConfig);

            expect(Variables.set).toHaveBeenCalledWith('App.Config', mockAppConfig);
        });

        it('should resolve promise after saving', async () => {
            const result = await service.saveConfig(mockAppConfig);

            expect(result).toBeUndefined();
        });

        it('should save config with all properties', async () => {
            const customConfig: AppConfig = {
                environment: 'production',
                tenantId: 'prod-tenant-789',
                clientId: 'prod-client-xyz',
                baseUrl: 'https://prod.example.com',
                apiUrl: 'https://api.prod.example.com'
            };

            await service.saveConfig(customConfig);

            expect(Variables.set).toHaveBeenCalledWith('App.Config', customConfig);
        });

        it('should save empty config object', async () => {
            const emptyConfig = new AppConfig();

            await service.saveConfig(emptyConfig);

            expect(Variables.set).toHaveBeenCalledWith('App.Config', emptyConfig);
            expect(emptyConfig.environment).toBe('');
            expect(emptyConfig.tenantId).toBe('');
            expect(emptyConfig.clientId).toBe('');
            expect(emptyConfig.baseUrl).toBe('');
            expect(emptyConfig.apiUrl).toBe('');
        });

        it('should save config with partial values', async () => {
            const partialConfig: AppConfig = {
                environment: 'staging',
                tenantId: '',
                clientId: 'staging-client',
                baseUrl: '',
                apiUrl: 'https://api.staging.example.com'
            };

            await service.saveConfig(partialConfig);

            expect(Variables.set).toHaveBeenCalledWith('App.Config', partialConfig);
        });

        it('should be callable multiple times', async () => {
            await service.saveConfig(mockAppConfig);
            await service.saveConfig(mockAppConfig);
            await service.saveConfig(mockAppConfig);

            expect(Variables.set).toHaveBeenCalledTimes(3);
        });
    });

    describe('clearConfig', () => {
        it('should clear config from Variables', () => {
            service.clearConfig();

            expect(Variables.clear).toHaveBeenCalledWith('App.Config');
        });

        it('should allow getting config after clearing', async () => {
            jest.spyOn(Variables, 'get')
                .mockReturnValueOnce(mockAppConfig) // Before clear
                .mockReturnValueOnce(null) // After clear
                .mockReturnValueOnce(mockAppConfig); // After reload
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));

            // Get config (cached)
            await service.getConfig();
            
            // Clear config
            service.clearConfig();
            
            // Get config again (should reload)
            await service.getConfig();

            expect(Variables.clear).toHaveBeenCalledWith('App.Config');
            expect(service['http'].get).toHaveBeenCalled();
        });

        it('should be callable multiple times', () => {
            service.clearConfig();
            service.clearConfig();
            service.clearConfig();

            expect(Variables.clear).toHaveBeenCalledTimes(3);
            expect(Variables.clear).toHaveBeenCalledWith('App.Config');
        });

        it('should affect getConfigKey after clearing', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);
            
            // Get key before clear
            let result = service.getConfigKey('apiUrl');
            expect(result).toBe('https://api.example.com');

            // Clear and mock null return
            jest.spyOn(Variables, 'get').mockReturnValue(null);
            service.clearConfig();

            // Get key after clear
            result = service.getConfigKey('apiUrl');
            expect(result).toBeNull();
        });
    });

    describe('Integration Tests', () => {
        it('should complete full lifecycle: init -> get -> save -> clear', async () => {
            // Init
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));
            await service.init();

            // Get
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);
            const config = await service.getConfig();
            expect(config).toEqual(mockAppConfig);

            // Get key
            const apiUrl = service.getConfigKey('apiUrl');
            expect(apiUrl).toBe('https://api.example.com');

            // Save
            const updatedConfig: AppConfig = { 
                ...mockAppConfig, 
                environment: 'production' 
            };
            await service.saveConfig(updatedConfig);
            expect(Variables.set).toHaveBeenCalledWith('App.Config', updatedConfig);

            // Clear
            service.clearConfig();
            expect(Variables.clear).toHaveBeenCalledWith('App.Config');
        });

        it('should handle error recovery: failed init -> successful retry', async () => {
            // First attempt fails
            jest.spyOn(service['http'], 'get').mockReturnValueOnce(throwError(() => new Error('Network error')));
            await expect(service.init()).rejects.toThrow('Network error');

            // Second attempt succeeds
            jest.spyOn(service['http'], 'get').mockReturnValueOnce(of(mockAppConfig));
            const result = await service.init();
            expect(result).toBe(true);
        });

        it('should maintain config integrity across operations', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));
            
            // Initialize
            await service.init();
            
            // Verify saved correctly
            const saveCall = (Variables.set as jest.Mock).mock.calls[0];
            expect(saveCall[1]).toEqual(mockAppConfig);
            
            // Verify properties were preserved
            expect(saveCall[1].apiUrl).toBe('https://api.example.com');
            expect(saveCall[1].environment).toBe('test');
            expect(saveCall[1].tenantId).toBe('tenant-123-456');
            expect(saveCall[1].clientId).toBe('client-abc-def');
            expect(saveCall[1].baseUrl).toBe('https://app.example.com');
        });

        it('should handle rapid consecutive operations', async () => {
            jest.spyOn(service['http'], 'get').mockReturnValue(of(mockAppConfig));
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            // Multiple rapid operations
            const promises = [
                service.getConfig(),
                service.saveConfig(mockAppConfig),
                service.getConfig(),
                service.saveConfig(mockAppConfig)
            ];

            await Promise.all(promises);

            // All operations should complete successfully
            expect(Variables.get).toHaveBeenCalled();
            expect(Variables.set).toHaveBeenCalled();
        });

        it('should handle getConfigKey with all config properties', () => {
            jest.spyOn(Variables, 'get').mockReturnValue(mockAppConfig);

            expect(service.getConfigKey('environment')).toBe('test');
            expect(service.getConfigKey('tenantId')).toBe('tenant-123-456');
            expect(service.getConfigKey('clientId')).toBe('client-abc-def');
            expect(service.getConfigKey('baseUrl')).toBe('https://app.example.com');
            expect(service.getConfigKey('apiUrl')).toBe('https://api.example.com');
        });

        it('should handle empty string values in config', () => {
            const configWithEmptyStrings: AppConfig = {
                environment: '',
                tenantId: '',
                clientId: '',
                baseUrl: '',
                apiUrl: ''
            };
            
            jest.spyOn(Variables, 'get').mockReturnValue(configWithEmptyStrings);

            expect(service.getConfigKey('environment')).toBe('');
            expect(service.getConfigKey('tenantId')).toBe('');
            expect(service.getConfigKey('clientId')).toBe('');
            expect(service.getConfigKey('baseUrl')).toBe('');
            expect(service.getConfigKey('apiUrl')).toBe('');
        });
    });
});
