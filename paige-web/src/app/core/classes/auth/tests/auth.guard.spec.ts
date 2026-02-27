import { TestBed } from '@angular/core/testing';
import { Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthGuard } from '~/core/classes/auth/auth.guard';
import { AppSettingsService } from '~/core/services/appsettings.service';
import { AppSettings } from '~/core/models/appsettings';

describe('AuthGuard', () => {
    let guard: AuthGuard;
    let mockRouter: jest.Mocked<Router>;
    let mockAppSettingsService: jest.Mocked<AppSettingsService>;

    beforeEach(() => {
        mockRouter = {
            navigate: jest.fn().mockResolvedValue(true)
        } as any;

        mockAppSettingsService = {
            getSettings: jest.fn()
        } as any;

        TestBed.configureTestingModule({
            providers: [
                AuthGuard,
                { provide: Router, useValue: mockRouter },
                { provide: AppSettingsService, useValue: mockAppSettingsService }
            ]
        });

        guard = TestBed.inject(AuthGuard);
        sessionStorage.clear();
    });

    afterEach(() => {
        jest.restoreAllMocks();
        sessionStorage.clear();
    });

    const createMockRoute = (routeConfig: any = {}): ActivatedRouteSnapshot => {
        return { routeConfig } as ActivatedRouteSnapshot;
    };

    const createMockState = (url: string = '/test-url'): RouterStateSnapshot => {
        return { url } as RouterStateSnapshot;
    };

    describe('Service Registration', () => {
        it('should be created', () => {
            expect(guard).toBeTruthy();
        });

        it('should be provided in root', () => {
            const metadata = (AuthGuard as any).ɵprov;
            expect(metadata.providedIn).toBe('root');
        });
    });

    describe('canActivate - Open Access Mode', () => {
        it('should allow access when openAccess is true', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = true;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            const result = await guard.canActivate(createMockRoute(), createMockState());

            expect(result).toBeUndefined();
            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should store redirect URL when openAccess is true and no user', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = true;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/protected-page'));

            expect(sessionStorage.getItem('_redirect')).toBe('/protected-page');
        });
    });

    describe('canActivate - User Authentication', () => {
        it('should store redirect URL when user is not authenticated', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/dashboard'));

            expect(sessionStorage.getItem('_redirect')).toBe('/dashboard');
        });

        it('should not overwrite existing redirect URL', async () => {
            sessionStorage.setItem('_redirect', '/original-url');
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/new-url'));

            expect(sessionStorage.getItem('_redirect')).toBe('/original-url');
        });

        it('should not store redirect URL when user is authenticated', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState());

            expect(sessionStorage.getItem('_redirect')).toBeNull();
        });
    });

    describe('canActivate - Role-Based Access', () => {
        it('should allow access when route has no roles defined', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({}), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should allow access when route has empty roles array', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: [] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should allow access when user has required role', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['admin'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should allow access when user has one of multiple required roles', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['editor'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin', 'editor', 'moderator'] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should deny access when user does not have required role', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/access'], { state: { type: 'page' } });
        });

        it('should deny access when user has no roles', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: [] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/access'], { state: { type: 'page' } });
        });

        it('should handle user with multiple roles', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user', 'editor', 'moderator'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin', 'editor'] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should handle role string matching with includes', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            // User has 'admin' role, route requires 'super-admin'
            // 'super-admin'.includes('admin') returns true, so access granted
            appSettings.user = { roles: ['admin'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['super-admin'] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });
    });

    describe('canActivate - Route Config Edge Cases', () => {
        it('should handle null routeConfig', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(null), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should handle undefined routeConfig', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(undefined), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });
    });

    describe('storeRedirectUrl', () => {
        it('should store URL in sessionStorage', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/protected-route'));

            expect(sessionStorage.getItem('_redirect')).toBe('/protected-route');
        });

        it('should handle URLs with query parameters', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/page?param=value&other=123'));

            expect(sessionStorage.getItem('_redirect')).toBe('/page?param=value&other=123');
        });

        it('should handle URLs with fragments', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState('/page#section'));

            expect(sessionStorage.getItem('_redirect')).toBe('/page#section');
        });
    });

    describe('hasAccess - Role Matching Logic', () => {
        it('should match exact role strings', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['admin'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });

        it('should handle case-sensitive role matching', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['Admin'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/access'], { state: { type: 'page' } });
        });
    });

    describe('Integration Scenarios', () => {
        it('should handle complete authentication flow', async () => {
            const appSettingsNoUser = new AppSettings();
            appSettingsNoUser.openAccess = false;
            appSettingsNoUser.user = null;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettingsNoUser);

            await guard.canActivate(createMockRoute(), createMockState('/dashboard'));

            expect(sessionStorage.getItem('_redirect')).toBe('/dashboard');
            expect(mockRouter.navigate).toHaveBeenCalledWith(['/access'], { state: { type: 'page' } });

            // Clear the mock for second call
            mockRouter.navigate.mockClear();

            const appSettingsWithUser = new AppSettings();
            appSettingsWithUser.openAccess = false;
            appSettingsWithUser.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettingsWithUser);

            await guard.canActivate(createMockRoute(), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
            expect(sessionStorage.getItem('_redirect')).toBe('/dashboard');
        });

        it('should handle admin-only route access', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(mockRouter.navigate).toHaveBeenCalledWith(['/access'], { state: { type: 'page' } });
        });

        it('should handle public route access', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute({ roles: [] }), createMockState());

            expect(mockRouter.navigate).not.toHaveBeenCalled();
        });
    });

    describe('Service Integration', () => {
        it('should call appSettingsService.getSettings', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = true;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            await guard.canActivate(createMockRoute(), createMockState());

            expect(mockAppSettingsService.getSettings).toHaveBeenCalledTimes(1);
        });

        it('should await appSettingsService response', async () => {
            let settingsResolved = false;
            const appSettings = new AppSettings();
            appSettings.openAccess = true;
            mockAppSettingsService.getSettings.mockImplementation(async () => {
                await new Promise(resolve => setTimeout(resolve, 10));
                settingsResolved = true;
                return appSettings;
            });

            await guard.canActivate(createMockRoute(), createMockState());

            expect(settingsResolved).toBe(true);
        });
    });

    describe('Return Values', () => {
        it('should return undefined when access is granted', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = true;
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            const result = await guard.canActivate(createMockRoute(), createMockState());

            expect(result).toBeUndefined();
        });

        it('should return undefined when access is denied', async () => {
            const appSettings = new AppSettings();
            appSettings.openAccess = false;
            appSettings.user = { roles: ['user'] };
            mockAppSettingsService.getSettings.mockResolvedValue(appSettings);

            const result = await guard.canActivate(createMockRoute({ roles: ['admin'] }), createMockState());

            expect(result).toBeUndefined();
        });
    });
});
