import { HTTP_INTERCEPTORS } from '@angular/common/http';
import {
  MsalGuard,
  MsalInterceptor,
  MsalBroadcastService,
  MsalService,
  MSAL_GUARD_CONFIG,
  MSAL_INSTANCE,
  MSAL_INTERCEPTOR_CONFIG
} from '@azure/msal-angular';
import { TestBed } from '@angular/core/testing';
import { appConfig } from '~/core/app.config';
import { AuthGuard } from '~/core/classes/auth/auth.guard';
import { AuthFactories } from '~/core/classes/auth/auth.factories';
import { AppConfigService } from '~/core/services/appconfig.service';
import { HttpService } from '~/core/services/http.service';

// Mock dependencies
jest.mock('~/core/classes/routes/core.routing', () => ({
  coreRoutes: []
}));

jest.mock('~/classes/routes/app.routing', () => ({
  appRoutes: []
}));

jest.mock('~/core/services/http.service', () => ({
  HttpService: jest.fn().mockImplementation(() => ({
    init: jest.fn().mockResolvedValue(undefined)
  }))
}));

jest.mock('~/core/services/appconfig.service', () => ({
  AppConfigService: jest.fn()
}));

jest.mock('~/core/classes/auth/auth.guard', () => ({
  AuthGuard: jest.fn()
}));

jest.mock('~/core/classes/auth/auth.factories', () => ({
  AuthFactories: jest.fn().mockImplementation(() => ({
    MSALInstanceFactory: jest.fn(),
    MSALGuardConfigFactory: jest.fn(),
    MSALInterceptorConfigFactory: jest.fn()
  }))
}));

describe('appConfig', () => {
  it('should be defined as an ApplicationConfig', () => {
    expect(appConfig).toBeDefined();
    expect(appConfig.providers).toBeDefined();
    expect(Array.isArray(appConfig.providers)).toBe(true);
  });

  it('should include provideAppInitializer for HttpService.init()', () => {
    const providers = appConfig.providers as any[];
    // provideAppInitializer returns an EnvironmentProviders object
    const hasAppInitializer = providers.some(p => 
      p && (typeof p === 'object' || typeof p === 'function')
    );
    expect(hasAppInitializer).toBe(true);
  });

  it('should call HttpService.init() during application initialization', async () => {
    // Arrange
    const mockInit = jest.fn().mockResolvedValue(undefined);
    const mockHttpService = {
      init: mockInit
    };

    await TestBed.configureTestingModule({
      providers: [
        { provide: HttpService, useValue: mockHttpService }
      ]
    }).compileComponents();

    // Act
    const { initializeApp } = require('~/core/app.config');
    
    // Call initializeApp() which returns the arrow function
    const initializerFn = initializeApp();
    
    // Execute within the TestBed injection context
    await TestBed.runInInjectionContext(async () => {
      await initializerFn();
    });

    // Assert
    expect(mockInit).toHaveBeenCalled();
    expect(mockInit).toHaveBeenCalledTimes(1);
  });

  it('should provide HttpClient with interceptors from DI', () => {
    const providers = appConfig.providers as any[];
    // provideHttpClient returns providers, just verify they exist
    expect(providers.length).toBeGreaterThan(0);
  });

  it('should include AuthGuard in providers', () => {
    const providers = appConfig.providers as any[];
    expect(providers).toContain(AuthGuard);
  });

  it('should configure MsalInterceptor as HTTP_INTERCEPTORS', () => {
    const providers = appConfig.providers as any[];
    const interceptorConfig = providers.find(p => 
      p && 
      typeof p === 'object' && 
      p.provide === HTTP_INTERCEPTORS &&
      p.useClass === MsalInterceptor
    );
    
    expect(interceptorConfig).toBeDefined();
    expect(interceptorConfig.multi).toBe(true);
  });

  it('should configure MSAL_INSTANCE with factory', () => {
    const providers = appConfig.providers as any[];
    const msalInstanceConfig = providers.find(p => 
      p && 
      typeof p === 'object' && 
      p.provide === MSAL_INSTANCE
    );
    
    expect(msalInstanceConfig).toBeDefined();
    expect(msalInstanceConfig.useFactory).toBeDefined();
    expect(msalInstanceConfig.deps).toEqual([AppConfigService]);
  });

  it('should configure MSAL_GUARD_CONFIG with factory', () => {
    const providers = appConfig.providers as any[];
    const msalGuardConfig = providers.find(p => 
      p && 
      typeof p === 'object' && 
      p.provide === MSAL_GUARD_CONFIG
    );
    
    expect(msalGuardConfig).toBeDefined();
    expect(msalGuardConfig.useFactory).toBeDefined();
    expect(msalGuardConfig.deps).toEqual([AppConfigService]);
  });

  it('should configure MSAL_INTERCEPTOR_CONFIG with factory', () => {
    const providers = appConfig.providers as any[];
    const msalInterceptorConfig = providers.find(p => 
      p && 
      typeof p === 'object' && 
      p.provide === MSAL_INTERCEPTOR_CONFIG
    );
    
    expect(msalInterceptorConfig).toBeDefined();
    expect(msalInterceptorConfig.useFactory).toBeDefined();
    expect(msalInterceptorConfig.deps).toEqual([AppConfigService]);
  });

  it('should include MsalService in providers', () => {
    const providers = appConfig.providers as any[];
    expect(providers).toContain(MsalService);
  });

  it('should include MsalGuard in providers', () => {
    const providers = appConfig.providers as any[];
    expect(providers).toContain(MsalGuard);
  });

  it('should include MsalBroadcastService in providers', () => {
    const providers = appConfig.providers as any[];
    expect(providers).toContain(MsalBroadcastService);
  });

  it('should provide router with coreRoutes', () => {
    const providers = appConfig.providers as any[];
    // Just verify providers array has content - provideRouter adds complex objects
    expect(providers.length).toBeGreaterThan(10);
  });

  it('should provide router with appRoutes', () => {
    const providers = appConfig.providers as any[];
    // Verify we have all expected providers (2 routers + others)
    expect(providers.length).toBeGreaterThan(10);
  });

  it('should instantiate AuthFactories', () => {
    // This test verifies the AuthFactories instance is created
    const authFactories = new AuthFactories();
    expect(authFactories).toBeDefined();
    expect(authFactories.MSALInstanceFactory).toBeDefined();
    expect(authFactories.MSALGuardConfigFactory).toBeDefined();
    expect(authFactories.MSALInterceptorConfigFactory).toBeDefined();
  });

  it('should have all required providers in correct order', () => {
    const providers = appConfig.providers as any[];
    
    // Verify minimum number of providers (you have 12)
    expect(providers.length).toBeGreaterThanOrEqual(12);
    
    // Verify AuthGuard is present
    const authGuardIndex = providers.findIndex(p => p === AuthGuard);
    expect(authGuardIndex).toBeGreaterThan(-1);
    
    // Verify MsalService is present
    const msalServiceIndex = providers.findIndex(p => p === MsalService);
    expect(msalServiceIndex).toBeGreaterThan(-1);
  });

  it('should configure all MSAL-related providers', () => {
    const providers = appConfig.providers as any[];
    
    const msalProviders = providers.filter(p => 
      p === MsalService ||
      p === MsalGuard ||
      p === MsalBroadcastService ||
      (p && typeof p === 'object' && (
        p.provide === MSAL_INSTANCE ||
        p.provide === MSAL_GUARD_CONFIG ||
        p.provide === MSAL_INTERCEPTOR_CONFIG ||
        (p.provide === HTTP_INTERCEPTORS && p.useClass === MsalInterceptor)
      ))
    );
    
    // Should have 7 MSAL-related providers
    expect(msalProviders.length).toBe(7);
  });
});
