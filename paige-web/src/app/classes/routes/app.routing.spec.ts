import { appRoutes } from '~/classes/routes/app.routing';
import { AuthGuard } from '~/core/classes/auth/auth.guard';

describe('appRoutes', () => {
    it('should be defined', () => {
        expect(appRoutes).toBeDefined();
    });

    it('should be an array', () => {
        expect(Array.isArray(appRoutes)).toBe(true);
    });

    it('should have 7 routes', () => {
        expect(appRoutes.length).toBe(7);
    });

    describe('home redirect route', () => {
        it('should redirect /home to empty path', () => {
            const homeRoute = appRoutes[0];
            
            expect(homeRoute.path).toBe('home');
            expect(homeRoute.redirectTo).toBe('');
            expect(homeRoute.pathMatch).toBe('full');
        });

        it('should not have loadComponent', () => {
            const homeRoute = appRoutes[0];
            
            expect(homeRoute.loadComponent).toBeUndefined();
        });

        it('should not have canActivate', () => {
            const homeRoute = appRoutes[0];
            
            expect(homeRoute.canActivate).toBeUndefined();
        });
    });

    describe('root route (PAIGE)', () => {
        const rootRoute = appRoutes[1];

        it('should have empty path', () => {
            expect(rootRoute.path).toBe('');
        });

        it('should have title "PAIGE"', () => {
            expect(rootRoute.title).toBe('PAIGE');
        });

        it('should have loadComponent function', () => {
            expect(rootRoute.loadComponent).toBeDefined();
            expect(typeof rootRoute.loadComponent).toBe('function');
        });

        it('should have AuthGuard in canActivate', () => {
            expect(rootRoute.canActivate).toBeDefined();
            expect(rootRoute.canActivate).toContain(AuthGuard);
            expect(rootRoute.canActivate?.length).toBe(1);
        });

        it('should have data with icon and isNav', () => {
            expect(rootRoute.data).toBeDefined();
            expect(rootRoute.data?.['icon']).toBe('chat');
            expect(rootRoute.data?.['isNav']).toBe(true);
        });

        it('should lazy load HomeComponent', async () => {
            const module = await rootRoute.loadComponent!();
            expect(module).toBeDefined();
        });
    });

    describe('cfn route', () => {
        const cfnRoute = appRoutes[2];

        it('should have path "cfn"', () => {
            expect(cfnRoute.path).toBe('cfn');
        });

        it('should have title "CFN Files"', () => {
            expect(cfnRoute.title).toBe('CFN Files');
        });

        it('should have loadComponent function', () => {
            expect(cfnRoute.loadComponent).toBeDefined();
            expect(typeof cfnRoute.loadComponent).toBe('function');
        });

        it('should have AuthGuard in canActivate', () => {
            expect(cfnRoute.canActivate).toBeDefined();
            expect(cfnRoute.canActivate).toContain(AuthGuard);
        });

        it('should have data with icon and isNav', () => {
            expect(cfnRoute.data).toBeDefined();
            expect(cfnRoute.data?.['icon']).toBe('database');
            expect(cfnRoute.data?.['isNav']).toBe(false);
        });

        it('should lazy load CfnComponent', async () => {
            const module = await cfnRoute.loadComponent!();
            expect(module).toBeDefined();
        });
    });

    describe('terraform route', () => {
        const terraformRoute = appRoutes[3];

        it('should have path "terraform"', () => {
            expect(terraformRoute.path).toBe('terraform');
        });

        it('should have title "Terraform Files"', () => {
            expect(terraformRoute.title).toBe('Terraform Files');
        });

        it('should have loadComponent function', () => {
            expect(terraformRoute.loadComponent).toBeDefined();
            expect(typeof terraformRoute.loadComponent).toBe('function');
        });

        it('should have AuthGuard in canActivate', () => {
            expect(terraformRoute.canActivate).toBeDefined();
            expect(terraformRoute.canActivate).toContain(AuthGuard);
        });

        it('should have data with icon and isNav', () => {
            expect(terraformRoute.data).toBeDefined();
            expect(terraformRoute.data?.['icon']).toBe('database');
            expect(terraformRoute.data?.['isNav']).toBe(false);
        });

        it('should lazy load TerraformComponent', async () => {
            const module = await terraformRoute.loadComponent!();
            expect(module).toBeDefined();
        });
    });

    describe('repo route', () => {
        const repoRoute = appRoutes[4];

        it('should have path "repo"', () => {
            expect(repoRoute.path).toBe('repo');
        });

        it('should have title "Repo Analysis"', () => {
            expect(repoRoute.title).toBe('Repo Analysis');
        });

        it('should have loadComponent function', () => {
            expect(repoRoute.loadComponent).toBeDefined();
            expect(typeof repoRoute.loadComponent).toBe('function');
        });

        it('should have AuthGuard in canActivate', () => {
            expect(repoRoute.canActivate).toBeDefined();
            expect(repoRoute.canActivate).toContain(AuthGuard);
        });

        it('should have data with icon and isNav', () => {
            expect(repoRoute.data).toBeDefined();
            expect(repoRoute.data?.['icon']).toBe('scan');
            expect(repoRoute.data?.['isNav']).toBe(true);
        });

        it('should lazy load RepoComponent', async () => {
            const module = await repoRoute.loadComponent!();
            expect(module).toBeDefined();
        });
    });

    describe('repo-results route', () => {
        const repoResultsRoute = appRoutes[5];

        it('should have path "repo-results"', () => {
            expect(repoResultsRoute.path).toBe('repo-results');
        });

        it('should have title "Repo Summary"', () => {
            expect(repoResultsRoute.title).toBe('Repo Summary');
        });

        it('should have loadComponent function', () => {
            expect(repoResultsRoute.loadComponent).toBeDefined();
            expect(typeof repoResultsRoute.loadComponent).toBe('function');
        });

        it('should have AuthGuard in canActivate', () => {
            expect(repoResultsRoute.canActivate).toBeDefined();
            expect(repoResultsRoute.canActivate).toContain(AuthGuard);
        });

        it('should have data with icon and isNav', () => {
            expect(repoResultsRoute.data).toBeDefined();
            expect(repoResultsRoute.data?.['icon']).toBe('scan');
            expect(repoResultsRoute.data?.['isNav']).toBe(false);
        });

        it('should lazy load RepoResultsComponent', async () => {
            const module = await repoResultsRoute.loadComponent!();
            expect(module).toBeDefined();
        });
    });

    describe('wildcard route', () => {
        const wildcardRoute = appRoutes[6];

        it('should have wildcard path "**"', () => {
            expect(wildcardRoute.path).toBe('**');
        });

        it('should redirect to "notfound"', () => {
            expect(wildcardRoute.redirectTo).toBe('notfound');
        });

        it('should have pathMatch "full"', () => {
            expect(wildcardRoute.pathMatch).toBe('full');
        });

        it('should not have loadComponent', () => {
            expect(wildcardRoute.loadComponent).toBeUndefined();
        });

        it('should not have canActivate', () => {
            expect(wildcardRoute.canActivate).toBeUndefined();
        });

        it('should be the last route in the array', () => {
            expect(appRoutes[appRoutes.length - 1]).toBe(wildcardRoute);
        });
    });

    describe('route guard configuration', () => {
        it('should have AuthGuard on all component routes', () => {
            const componentRoutes = appRoutes.filter((route: any) => route.loadComponent);
            
            componentRoutes.forEach((route: any) => {
                expect(route.canActivate).toBeDefined();
                expect(route.canActivate).toContain(AuthGuard);
            });
        });

        it('should not have AuthGuard on redirect routes', () => {
            const redirectRoutes = appRoutes.filter((route: any) => route.redirectTo);
            
            redirectRoutes.forEach((route: any) => {
                expect(route.canActivate).toBeUndefined();
            });
        });
    });

    describe('navigation configuration', () => {
        it('should have exactly 2 routes marked for navigation', () => {
            const navRoutes = appRoutes.filter((route: any) => route.data?.isNav === true);
            
            expect(navRoutes.length).toBe(2);
        });

        it('should have root route as navigation', () => {
            const rootRoute = appRoutes[1];
            
            expect(rootRoute.data?.['isNav']).toBe(true);
        });

        it('should have repo route as navigation', () => {
            const repoRoute = appRoutes[4];
            
            expect(repoRoute.data?.['isNav']).toBe(true);
        });

        it('should not have cfn route in navigation', () => {
            const cfnRoute = appRoutes[2];
            
            expect(cfnRoute.data?.['isNav']).toBe(false);
        });

        it('should not have terraform route in navigation', () => {
            const terraformRoute = appRoutes[3];
            
            expect(terraformRoute.data?.['isNav']).toBe(false);
        });

        it('should not have repo-results route in navigation', () => {
            const repoResultsRoute = appRoutes[5];
            
            expect(repoResultsRoute.data?.['isNav']).toBe(false);
        });
    });

    describe('icon configuration', () => {
        it('should have "chat" icon for root route', () => {
            expect(appRoutes[1].data?.['icon']).toBe('chat');
        });

        it('should have "database" icon for cfn route', () => {
            expect(appRoutes[2].data?.['icon']).toBe('database');
        });

        it('should have "database" icon for terraform route', () => {
            expect(appRoutes[3].data?.['icon']).toBe('database');
        });

        it('should have "scan" icon for repo route', () => {
            expect(appRoutes[4].data?.['icon']).toBe('scan');
        });

        it('should have "scan" icon for repo-results route', () => {
            expect(appRoutes[5].data?.['icon']).toBe('scan');
        });
    });

    describe('lazy loading', () => {
        it('should have 5 routes with lazy loading', () => {
            const lazyRoutes = appRoutes.filter((route: any) => route.loadComponent);
            
            expect(lazyRoutes.length).toBe(5);
        });

        it('should return promises from loadComponent functions', () => {
            const lazyRoutes = appRoutes.filter((route: any) => route.loadComponent);
            
            lazyRoutes.forEach((route: any) => {
                const result = route.loadComponent();
                expect(result).toBeInstanceOf(Promise);
            });
        });
    });

    describe('route paths', () => {
        it('should have unique paths for all routes', () => {
            const paths = appRoutes.map((route: any) => route.path);
            const uniquePaths = new Set(paths);
            
            expect(paths.length).toBe(uniquePaths.size);
        });

        it('should not have any undefined paths', () => {
            appRoutes.forEach((route: any) => {
                expect(route.path).toBeDefined();
            });
        });

        it('should have correct path order', () => {
            expect(appRoutes[0].path).toBe('home');
            expect(appRoutes[1].path).toBe('');
            expect(appRoutes[2].path).toBe('cfn');
            expect(appRoutes[3].path).toBe('terraform');
            expect(appRoutes[4].path).toBe('repo');
            expect(appRoutes[5].path).toBe('repo-results');
            expect(appRoutes[6].path).toBe('**');
        });
    });

    describe('route titles', () => {
        it('should have titles for all component routes', () => {
            const componentRoutes = appRoutes.filter((route: any) => route.loadComponent);
            
            componentRoutes.forEach((route: any) => {
                expect(route.title).toBeDefined();
                expect(typeof route.title).toBe('string');
                expect(route.title.length).toBeGreaterThan(0);
            });
        });

        it('should not have titles for redirect routes', () => {
            const redirectRoutes = appRoutes.filter((route: any) => route.redirectTo);
            
            redirectRoutes.forEach((route: any) => {
                expect(route.title).toBeUndefined();
            });
        });
    });

    describe('pathMatch configuration', () => {
        it('should have pathMatch "full" for all redirect routes', () => {
            const redirectRoutes = appRoutes.filter((route: any) => route.redirectTo);
            
            redirectRoutes.forEach((route: any) => {
                expect(route.pathMatch).toBe('full');
            });
        });

        it('should not have pathMatch for component routes', () => {
            const componentRoutes = appRoutes.filter((route: any) => route.loadComponent);
            
            componentRoutes.forEach((route: any) => {
                expect(route.pathMatch).toBeUndefined();
            });
        });
    });
});
