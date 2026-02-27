import { TestBed } from '@angular/core/testing';
import { AuthFactories } from '~/core/classes/auth/auth.factories';
import { AppConfigService } from '~/core/services/appconfig.service';
import { PublicClientApplication, BrowserCacheLocation, InteractionType } from '@azure/msal-browser';
import { MsalGuardConfiguration, MsalInterceptorConfiguration } from '@azure/msal-angular';

jest.mock('@azure/msal-browser', () => ({
    PublicClientApplication: jest.fn().mockImplementation(() => ({
        initialize: jest.fn(),
        acquireTokenSilent: jest.fn(),
        acquireTokenPopup: jest.fn(),
        acquireTokenRedirect: jest.fn(),
        getActiveAccount: jest.fn(),
        getAllAccounts: jest.fn(),
        handleRedirectPromise: jest.fn(),
        loginPopup: jest.fn(),
        loginRedirect: jest.fn(),
        logout: jest.fn(),
        logoutPopup: jest.fn(),
        logoutRedirect: jest.fn(),
        setActiveAccount: jest.fn(),
        addEventCallback: jest.fn(),
        removeEventCallback: jest.fn(),
        enableAccountStorageEvents: jest.fn(),
        disableAccountStorageEvents: jest.fn(),
        getTokenCache: jest.fn(),
        getLogger: jest.fn(),
        setLogger: jest.fn(),
        initializeWrapperLibrary: jest.fn(),
        setNavigationClient: jest.fn(),
        getConfiguration: jest.fn()
    })),
    InteractionType: {
        Redirect: 'redirect',
        Popup: 'popup'
    },
    BrowserCacheLocation: {
        SessionStorage: 'sessionStorage',
        LocalStorage: 'localStorage'
    }
}));

describe('AuthFactories', () => {
    let service: AuthFactories;
    let mockAppConfigService: jest.Mocked<AppConfigService>;

    beforeEach(() => {
        mockAppConfigService = {
            getConfigKey: jest.fn(),
            init: jest.fn()
        } as any;

        mockAppConfigService.getConfigKey.mockImplementation((key: string) => {
            if (key === 'clientId') return 'test-client-id';
            if (key === 'tenantId') return 'test-tenant-id';
            return 'default-value';
        });

        mockAppConfigService.init.mockResolvedValue(false);

        TestBed.configureTestingModule({
            providers: [AuthFactories]
        });

        service = TestBed.inject(AuthFactories);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Service Registration', () => {
        it('should be created', () => {
            expect(service).toBeTruthy();
        });

        it('should be provided in root', () => {
            expect(service).toBeInstanceOf(AuthFactories);
        });
    });

    describe('initializerFactory', () => {
        it('should return a function', () => {
            const result = service.initializerFactory(mockAppConfigService);
            expect(typeof result).toBe('function');
        });

        it('should call config.init when factory is called', () => {
            service.initializerFactory(mockAppConfigService);
            expect(mockAppConfigService.init).toHaveBeenCalledTimes(1);
        });

        it('should return a function that returns the promise from config.init', async () => {
            const initFn = service.initializerFactory(mockAppConfigService);
            const promise = initFn();
            expect(promise).toBeInstanceOf(Promise);
            await expect(promise).resolves.toBeFalsy();
        });

        it('should return the same promise on multiple invocations of returned function', () => {
            const initFn = service.initializerFactory(mockAppConfigService);
            const promise1 = initFn();
            const promise2 = initFn();
            expect(promise1).toBe(promise2);
        });

        it('should handle config.init rejection', async () => {
            const testError = new Error('Init failed');
            mockAppConfigService.init.mockRejectedValue(testError);
            const initFn = service.initializerFactory(mockAppConfigService);
            await expect(initFn()).rejects.toThrow('Init failed');
        });

        it('should create new promise for each factory call', () => {
            const initFn1 = service.initializerFactory(mockAppConfigService);
            mockAppConfigService.init.mockClear();
            mockAppConfigService.init.mockResolvedValue(false);
            const initFn2 = service.initializerFactory(mockAppConfigService);
            
            expect(initFn1).not.toBe(initFn2);
            expect(mockAppConfigService.init).toHaveBeenCalledTimes(1);
        });
    });

    describe('MSALInstanceFactory', () => {
        it('should return a PublicClientApplication instance', () => {
            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
            expect(PublicClientApplication).toHaveBeenCalled();
        });

        it('should call getConfigKey for clientId', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('clientId');
        });

        it('should call getConfigKey for tenantId', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('tenantId');
        });

        it('should configure auth with correct clientId', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.clientId).toBe('test-client-id');
        });

        it('should configure auth with correct authority', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.authority).toBe('https://login.microsoftonline.com/test-tenant-id');
        });

        it('should configure redirectUri as root', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.redirectUri).toBe('/');
        });

        it('should configure postLogoutRedirectUri as root', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.postLogoutRedirectUri).toBe('/');
        });

        it('should set navigateToLoginRequestUrl to true', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.navigateToLoginRequestUrl).toBe(true);
        });

        it('should configure cache with SessionStorage', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.cache.cacheLocation).toBe(BrowserCacheLocation.SessionStorage);
        });

        it('should configure temporaryCacheLocation with SessionStorage', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.cache.temporaryCacheLocation).toBe(BrowserCacheLocation.SessionStorage);
        });

        it('should set storeAuthStateInCookie to false', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.cache.storeAuthStateInCookie).toBe(false);
        });

        it('should set secureCookies to true', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.cache.secureCookies).toBe(true);
        });

        it('should set loggerOptions to undefined', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.system.loggerOptions).toBeUndefined();
        });

        it('should handle different clientId values', () => {
            mockAppConfigService.getConfigKey.mockImplementation((key: string) => {
                if (key === 'clientId') return 'custom-client-id';
                if (key === 'tenantId') return 'test-tenant-id';
                return 'default';
            });

            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.clientId).toBe('custom-client-id');
        });

        it('should handle different tenantId values', () => {
            mockAppConfigService.getConfigKey.mockImplementation((key: string) => {
                if (key === 'clientId') return 'test-client-id';
                if (key === 'tenantId') return 'custom-tenant-id';
                return 'default';
            });

            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.authority).toBe('https://login.microsoftonline.com/custom-tenant-id');
        });

        it('should create new instance on each call', () => {
            const instance1 = service.MSALInstanceFactory(mockAppConfigService);
            const instance2 = service.MSALInstanceFactory(mockAppConfigService);
            expect(PublicClientApplication).toHaveBeenCalledTimes(2);
        });
    });

    describe('MSALGuardConfigFactory', () => {
        it('should return MsalGuardConfiguration object', () => {
            const result = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result).toBeDefined();
            expect(typeof result).toBe('object');
        });

        it('should set interactionType to Redirect', () => {
            const result = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result.interactionType).toBe(InteractionType.Redirect);
        });

        it('should have empty authRequest object', () => {
            const result = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result.authRequest).toEqual({});
        });

        it('should set loginFailedRoute to root', () => {
            const result = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result.loginFailedRoute).toBe('/');
        });

        it('should return consistent configuration on multiple calls', () => {
            const result1 = service.MSALGuardConfigFactory(mockAppConfigService);
            const result2 = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result1).toEqual(result2);
        });

        it('should have all required properties', () => {
            const result = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result).toHaveProperty('interactionType');
            expect(result).toHaveProperty('authRequest');
            expect(result).toHaveProperty('loginFailedRoute');
        });
    });

    describe('MSALInterceptorConfigFactory', () => {
        it('should return MsalInterceptorConfiguration object', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result).toBeDefined();
            expect(typeof result).toBe('object');
        });

        it('should set interactionType to Redirect', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result.interactionType).toBe(InteractionType.Redirect);
        });

        it('should have protectedResourceMap', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result.protectedResourceMap).toBeInstanceOf(Map);
        });

        it('should configure Graph API endpoint in protectedResourceMap', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result.protectedResourceMap.has('https://graph.microsoft.com/v1.0/me')).toBe(true);
        });

        it('should map Graph API to user.read scope', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            const scopes = result.protectedResourceMap.get('https://graph.microsoft.com/v1.0/me');
            expect(scopes).toEqual(['user.read']);
        });

        it('should have exactly one entry in protectedResourceMap', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result.protectedResourceMap.size).toBe(1);
        });

        it('should return new Map instance on each call', () => {
            const result1 = service.MSALInterceptorConfigFactory(mockAppConfigService);
            const result2 = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result1.protectedResourceMap).not.toBe(result2.protectedResourceMap);
        });

        it('should have all required properties', () => {
            const result = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result).toHaveProperty('interactionType');
            expect(result).toHaveProperty('protectedResourceMap');
        });
    });

    describe('Integration Scenarios', () => {
        it('should create all factory methods successfully', () => {
            expect(() => {
                service.initializerFactory(mockAppConfigService);
                service.MSALInstanceFactory(mockAppConfigService);
                service.MSALGuardConfigFactory(mockAppConfigService);
                service.MSALInterceptorConfigFactory(mockAppConfigService);
            }).not.toThrow();
        });

        it('should handle full MSAL configuration flow', async () => {
            const initFn = service.initializerFactory(mockAppConfigService);
            await initFn();

            const msalInstance = service.MSALInstanceFactory(mockAppConfigService);
            expect(msalInstance).toBeDefined();

            const guardConfig = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(guardConfig).toBeDefined();

            const interceptorConfig = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(interceptorConfig).toBeDefined();

            expect(mockAppConfigService.init).toHaveBeenCalled();
            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('clientId');
            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('tenantId');
        });

        it('should use same config service across all factories', () => {
            service.initializerFactory(mockAppConfigService);
            service.MSALInstanceFactory(mockAppConfigService);
            service.MSALGuardConfigFactory(mockAppConfigService);
            service.MSALInterceptorConfigFactory(mockAppConfigService);

            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('clientId');
            expect(mockAppConfigService.getConfigKey).toHaveBeenCalledWith('tenantId');
        });
    });

    describe('Edge Cases', () => {
        it('should handle null config values', () => {
            mockAppConfigService.getConfigKey.mockReturnValue(null as any);
            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
        });

        it('should handle undefined config values', () => {
            mockAppConfigService.getConfigKey.mockReturnValue(undefined as any);
            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
        });

        it('should handle empty string config values', () => {
            mockAppConfigService.getConfigKey.mockReturnValue('');
            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.clientId).toBe('');
            expect(config.auth.authority).toBe('https://login.microsoftonline.com/');
        });

        it('should handle special characters in config values', () => {
            mockAppConfigService.getConfigKey.mockImplementation((key: string) => {
                if (key === 'clientId') return 'client!@#$%^&*()';
                if (key === 'tenantId') return 'tenant-123-xyz';
                return '';
            });

            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            expect(config.auth.clientId).toBe('client!@#$%^&*()');
            expect(config.auth.authority).toBe('https://login.microsoftonline.com/tenant-123-xyz');
        });
    });

    describe('Method Parameters', () => {
        it('should accept AppConfigService in initializerFactory', () => {
            expect(() => service.initializerFactory(mockAppConfigService)).not.toThrow();
        });

        it('should accept AppConfigService in MSALInstanceFactory', () => {
            expect(() => service.MSALInstanceFactory(mockAppConfigService)).not.toThrow();
        });

        it('should accept AppConfigService in MSALGuardConfigFactory', () => {
            expect(() => service.MSALGuardConfigFactory(mockAppConfigService)).not.toThrow();
        });

        it('should accept AppConfigService in MSALInterceptorConfigFactory', () => {
            expect(() => service.MSALInterceptorConfigFactory(mockAppConfigService)).not.toThrow();
        });
    });

    describe('Return Types', () => {
        it('should return function from initializerFactory', () => {
            const result = service.initializerFactory(mockAppConfigService);
            expect(typeof result).toBe('function');
        });

        it('should return IPublicClientApplication from MSALInstanceFactory', () => {
            const result = service.MSALInstanceFactory(mockAppConfigService);
            expect(result).toBeDefined();
        });

        it('should return MsalGuardConfiguration from MSALGuardConfigFactory', () => {
            const result: MsalGuardConfiguration = service.MSALGuardConfigFactory(mockAppConfigService);
            expect(result.interactionType).toBeDefined();
        });

        it('should return MsalInterceptorConfiguration from MSALInterceptorConfigFactory', () => {
            const result: MsalInterceptorConfiguration = service.MSALInterceptorConfigFactory(mockAppConfigService);
            expect(result.protectedResourceMap).toBeDefined();
        });
    });

    describe('Configuration Validation', () => {
        it('should create complete MSAL configuration object', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            
            expect(config).toHaveProperty('auth');
            expect(config).toHaveProperty('cache');
            expect(config).toHaveProperty('system');
        });

        it('should include all auth configuration properties', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            
            expect(config.auth).toHaveProperty('clientId');
            expect(config.auth).toHaveProperty('authority');
            expect(config.auth).toHaveProperty('redirectUri');
            expect(config.auth).toHaveProperty('postLogoutRedirectUri');
            expect(config.auth).toHaveProperty('navigateToLoginRequestUrl');
        });

        it('should include all cache configuration properties', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            
            expect(config.cache).toHaveProperty('cacheLocation');
            expect(config.cache).toHaveProperty('temporaryCacheLocation');
            expect(config.cache).toHaveProperty('storeAuthStateInCookie');
            expect(config.cache).toHaveProperty('secureCookies');
        });

        it('should include system configuration', () => {
            service.MSALInstanceFactory(mockAppConfigService);
            const config = (PublicClientApplication as unknown as jest.Mock).mock.calls[0][0];
            
            expect(config.system).toHaveProperty('loggerOptions');
        });
    });
});
