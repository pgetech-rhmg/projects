import { Route } from '@angular/router';
import { MsalGuard } from '@azure/msal-angular';

export const coreRoutes: Route[] = [
    {
        path: 'auth',
        loadComponent: () =>
            import('~/core/pages/auth/auth.component')
                .then((m: typeof import('~/core/pages/auth/auth.component')) => m.AuthComponent),
        canActivate: [MsalGuard]
    },
    {
        path: 'notfound',
        loadComponent: () =>
            import('~/core/pages/notfound/notfound.component')
                .then((m: typeof import('~/core/pages/notfound/notfound.component')) => m.NotFoundComponent),
    },
    {
        path: 'access',
        loadComponent: () =>
            import('~/core/pages/access/access.component')
                .then((m: typeof import('~/core/pages/access/access.component')) => m.AccessComponent),
    },
    {
        path: 'error',
        loadComponent: () =>
            import('~/core/pages/error/error.component')
                .then((m: typeof import('~/core/pages/error/error.component')) => m.ErrorComponent),
    },
];
