import { Route } from '@angular/router';
import { AuthGuard } from '~/core/classes/auth/auth.guard';

export const appRoutes: Route[] = [
    {
        path: 'home',
        redirectTo: '',
        pathMatch: 'full'
    },
    {
        path: '',
        title: 'PAIGE',
        loadComponent: () =>
            import('~/pages/home/home.component')
                .then((m: typeof import('~/pages/home/home.component')) => m.HomeComponent),
        canActivate: [AuthGuard],
        data: { icon: 'chat', isNav: true }
    },
    {
        path: 'cfn',
        title: 'CFN Files',
        loadComponent: () =>
            import('~/pages/cfn/cfn.component')
                .then((m: typeof import('~/pages/cfn/cfn.component')) => m.CfnComponent),
        canActivate: [AuthGuard],
        data: { icon: 'database', isNav: false }
    },
    {
        path: 'terraform',
        title: 'Terraform Files',
        loadComponent: () =>
            import('~/pages/terraform/terraform.component')
                .then((m: typeof import('~/pages/terraform/terraform.component')) => m.TerraformComponent),
        canActivate: [AuthGuard],
        data: { icon: 'database', isNav: false }
    },
    {
        path: 'repo',
        title: 'Repo Analysis',
        loadComponent: () =>
            import('~/pages/repo/repo.component')
                .then((m: typeof import('~/pages/repo/repo.component')) => m.RepoComponent),
        canActivate: [AuthGuard],
        data: { icon: 'scan', isNav: true }
    },
    {
        path: 'repo-results',
        title: 'Repo Summary',
        loadComponent: () =>
            import('~/pages/repo/repo-results/repo-results.component')
                .then((m: typeof import('~/pages/repo/repo-results/repo-results.component')) => m.RepoResultsComponent),
        canActivate: [AuthGuard],
        data: { icon: 'scan', isNav: false }
    },
    {
        path: '**',
        redirectTo: 'notfound',
        pathMatch: 'full'
    },
];
