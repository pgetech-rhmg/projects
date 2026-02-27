import { coreRoutes } from '~/core/classes/routes/core.routing';
import { MsalGuard } from '@azure/msal-angular';
import { AuthGuard } from '~/core/classes/auth/auth.guard';

describe('coreRoutes', () => {
    it('should be defined', () => {
        expect(coreRoutes).toBeDefined();
    });

    it('should be an array', () => {
        expect(Array.isArray(coreRoutes)).toBe(true);
    });

    it('should have 4 routes', () => {
        expect(coreRoutes.length).toBe(4);
    });

    describe('auth route', () => {
        const authRoute = coreRoutes[0];

        it('should have path "auth"', () => {
            expect(authRoute.path).toBe('auth');
        });

        it('should have loadComponent function', () => {
            expect(authRoute.loadComponent).toBeDefined();
            expect(typeof authRoute.loadComponent).toBe('function');
        });

        it('should have MsalGuard in canActivate', () => {
            expect(authRoute.canActivate).toBeDefined();
            expect(authRoute.canActivate).toContain(MsalGuard);
            expect(authRoute.canActivate?.length).toBe(1);
        });

        it('should not have AuthGuard in canActivate', () => {
            expect(authRoute.canActivate).not.toContain(AuthGuard);
        });

        it('should lazy load AuthComponent', async () => {
            const module = await authRoute.loadComponent!();
            expect(module).toBeDefined();
        });

        it('should not have title', () => {
            expect(authRoute.title).toBeUndefined();
        });

        it('should not have data', () => {
            expect(authRoute.data).toBeUndefined();
        });

        it('should not have redirectTo', () => {
            expect(authRoute.redirectTo).toBeUndefined();
        });
    });

    describe('notfound route', () => {
        const notfoundRoute = coreRoutes[1];

        it('should have path "notfound"', () => {
            expect(notfoundRoute.path).toBe('notfound');
        });

        it('should have loadComponent function', () => {
            expect(notfoundRoute.loadComponent).toBeDefined();
            expect(typeof notfoundRoute.loadComponent).toBe('function');
        });

        it('should not have any guards', () => {
            expect(notfoundRoute.canActivate).toBeUndefined();
        });

        it('should lazy load NotFoundComponent', async () => {
            const module = await notfoundRoute.loadComponent!();
            expect(module).toBeDefined();
        });

        it('should not have title', () => {
            expect(notfoundRoute.title).toBeUndefined();
        });

        it('should not have data', () => {
            expect(notfoundRoute.data).toBeUndefined();
        });

        it('should not have redirectTo', () => {
            expect(notfoundRoute.redirectTo).toBeUndefined();
        });
    });

    describe('access route', () => {
        const accessRoute = coreRoutes[2];

        it('should have path "access"', () => {
            expect(accessRoute.path).toBe('access');
        });

        it('should have loadComponent function', () => {
            expect(accessRoute.loadComponent).toBeDefined();
            expect(typeof accessRoute.loadComponent).toBe('function');
        });

        it('should not have any guards', () => {
            expect(accessRoute.canActivate).toBeUndefined();
        });

        it('should lazy load AccessComponent', async () => {
            const module = await accessRoute.loadComponent!();
            expect(module).toBeDefined();
        });

        it('should not have title', () => {
            expect(accessRoute.title).toBeUndefined();
        });

        it('should not have data', () => {
            expect(accessRoute.data).toBeUndefined();
        });

        it('should not have redirectTo', () => {
            expect(accessRoute.redirectTo).toBeUndefined();
        });
    });

    describe('error route', () => {
        const errorRoute = coreRoutes[3];

        it('should have path "error"', () => {
            expect(errorRoute.path).toBe('error');
        });

        it('should have loadComponent function', () => {
            expect(errorRoute.loadComponent).toBeDefined();
            expect(typeof errorRoute.loadComponent).toBe('function');
        });

        it('should not have any guards', () => {
            expect(errorRoute.canActivate).toBeUndefined();
        });

        it('should lazy load ErrorComponent', async () => {
            const module = await errorRoute.loadComponent!();
            expect(module).toBeDefined();
        });

        it('should not have title', () => {
            expect(errorRoute.title).toBeUndefined();
        });

        it('should not have data', () => {
            expect(errorRoute.data).toBeUndefined();
        });

        it('should not have redirectTo', () => {
            expect(errorRoute.redirectTo).toBeUndefined();
        });
    });

    describe('route guard configuration', () => {
        it('should have exactly 1 route with MsalGuard', () => {
            const msalGuardedRoutes = coreRoutes.filter((route: any) => 
                route.canActivate?.includes(MsalGuard)
            );
            
            expect(msalGuardedRoutes.length).toBe(1);
            expect(msalGuardedRoutes[0].path).toBe('auth');
        });

        it('should not have any routes with AuthGuard', () => {
            const authGuardedRoutes = coreRoutes.filter((route: any) => 
                route.canActivate?.includes(AuthGuard)
            );
            
            expect(authGuardedRoutes.length).toBe(0);
        });

        it('should have 3 routes without any guards', () => {
            const unguardedRoutes = coreRoutes.filter((route: any) => 
                !route.canActivate || route.canActivate.length === 0
            );
            
            expect(unguardedRoutes.length).toBe(3);
        });

        it('should have notfound route without guards', () => {
            const notfoundRoute = coreRoutes.find((route: any) => route.path === 'notfound');
            
            expect(notfoundRoute?.canActivate).toBeUndefined();
        });

        it('should have access route without guards', () => {
            const accessRoute = coreRoutes.find((route: any) => route.path === 'access');
            
            expect(accessRoute?.canActivate).toBeUndefined();
        });

        it('should have error route without guards', () => {
            const errorRoute = coreRoutes.find((route: any) => route.path === 'error');
            
            expect(errorRoute?.canActivate).toBeUndefined();
        });
    });

    describe('lazy loading', () => {
        it('should have all 4 routes with lazy loading', () => {
            const lazyRoutes = coreRoutes.filter((route: any) => route.loadComponent);
            
            expect(lazyRoutes.length).toBe(4);
        });

        it('should return promises from all loadComponent functions', () => {
            coreRoutes.forEach((route: any) => {
                const result = route.loadComponent();
                expect(result).toBeInstanceOf(Promise);
            });
        });

        it('should successfully load all components', async () => {
            const loadPromises = coreRoutes.map((route: any) => route.loadComponent());
            const components = await Promise.all(loadPromises);
            
            components.forEach((component: any) => {
                expect(component).toBeDefined();
            });
        });
    });

    describe('route paths', () => {
        it('should have unique paths for all routes', () => {
            const paths = coreRoutes.map((route: any) => route.path);
            const uniquePaths = new Set(paths);
            
            expect(paths.length).toBe(uniquePaths.size);
        });

        it('should not have any undefined paths', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.path).toBeDefined();
                expect(typeof route.path).toBe('string');
            });
        });

        it('should have correct path order', () => {
            expect(coreRoutes[0].path).toBe('auth');
            expect(coreRoutes[1].path).toBe('notfound');
            expect(coreRoutes[2].path).toBe('access');
            expect(coreRoutes[3].path).toBe('error');
        });

        it('should not have empty paths', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.path.length).toBeGreaterThan(0);
            });
        });

        it('should not have wildcard paths', () => {
            const wildcardRoutes = coreRoutes.filter((route: any) => route.path === '**');
            
            expect(wildcardRoutes.length).toBe(0);
        });
    });

    describe('route configuration completeness', () => {
        it('should not have any redirect routes', () => {
            const redirectRoutes = coreRoutes.filter((route: any) => route.redirectTo);
            
            expect(redirectRoutes.length).toBe(0);
        });

        it('should not have any routes with titles', () => {
            const routesWithTitles = coreRoutes.filter((route: any) => route.title);
            
            expect(routesWithTitles.length).toBe(0);
        });

        it('should not have any routes with data', () => {
            const routesWithData = coreRoutes.filter((route: any) => route.data);
            
            expect(routesWithData.length).toBe(0);
        });

        it('should not have any routes with pathMatch', () => {
            const routesWithPathMatch = coreRoutes.filter((route: any) => route.pathMatch);
            
            expect(routesWithPathMatch.length).toBe(0);
        });

        it('should only have component routes', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.loadComponent).toBeDefined();
                expect(route.redirectTo).toBeUndefined();
            });
        });
    });

    describe('public vs protected routes', () => {
        it('should have auth route as the only protected route', () => {
            const protectedRoutes = coreRoutes.filter((route: any) => route.canActivate);
            
            expect(protectedRoutes.length).toBe(1);
            expect(protectedRoutes[0].path).toBe('auth');
        });

        it('should have error pages as public routes', () => {
            const errorPages = ['notfound', 'access', 'error'];
            
            errorPages.forEach((path: string) => {
                const route = coreRoutes.find((r: any) => r.path === path);
                expect(route?.canActivate).toBeUndefined();
            });
        });
    });

    describe('route structure validation', () => {
        it('should have valid route objects', () => {
            coreRoutes.forEach((route: any) => {
                expect(route).toBeDefined();
                expect(typeof route).toBe('object');
                expect(route.path).toBeDefined();
            });
        });

        it('should have loadComponent for all routes', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.loadComponent).toBeDefined();
                expect(typeof route.loadComponent).toBe('function');
            });
        });

        it('should not have children routes', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.children).toBeUndefined();
            });
        });

        it('should not have outlets', () => {
            coreRoutes.forEach((route: any) => {
                expect(route.outlet).toBeUndefined();
            });
        });
    });

    describe('authentication flow routes', () => {
        it('should have auth route with MsalGuard', () => {
            const authRoute = coreRoutes.find((route: any) => route.path === 'auth');
            
            expect(authRoute).toBeDefined();
            expect(authRoute?.canActivate).toContain(MsalGuard);
        });

        it('should have notfound route publicly accessible', () => {
            const notfoundRoute = coreRoutes.find((route: any) => route.path === 'notfound');
            
            expect(notfoundRoute).toBeDefined();
            expect(notfoundRoute?.canActivate).toBeUndefined();
        });

        it('should have access denial route publicly accessible', () => {
            const accessRoute = coreRoutes.find((route: any) => route.path === 'access');
            
            expect(accessRoute).toBeDefined();
            expect(accessRoute?.canActivate).toBeUndefined();
        });

        it('should have error route publicly accessible', () => {
            const errorRoute = coreRoutes.find((route: any) => route.path === 'error');
            
            expect(errorRoute).toBeDefined();
            expect(errorRoute?.canActivate).toBeUndefined();
        });
    });
});
