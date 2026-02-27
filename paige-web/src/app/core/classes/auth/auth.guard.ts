import { Injectable } from '@angular/core';
import { Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';

import { AppSettingsService } from '~/core/services/appsettings.service';

@Injectable({
    providedIn: 'root'
})
export class AuthGuard {
    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly router: Router,
        private readonly appSettingsService: AppSettingsService,
    ) { }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public async canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Promise<void> {
        const appSettings = await this.appSettingsService.getSettings();
        if (!appSettings.user) {
            this.storeRedirectUrl(state.url);
        }
        if (appSettings.openAccess) {
            return;
        }
        // FIX: Check if user exists before accessing roles
        if (!appSettings.user) {
            this.router.navigate(['/access'], { state: { type: 'page' } });
            return;
        }
        const access = this.hasAccess(route.routeConfig, appSettings.user.roles);
        if (!access) {
            this.router.navigate(['/access'], { state: { type: 'page' } });
        }
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private storeRedirectUrl(url: string): void {
        if (!sessionStorage.getItem('_redirect')) {
            sessionStorage.setItem('_redirect', url);
        }
    }

    private hasAccess(config: any, userRoles: any[]): boolean {
        const routeRoles = config?.roles ?? [];
        if (routeRoles.length === 0) return true;

        return routeRoles.some((role: any) =>
            userRoles.some((user: any) => role.includes(user))
        );
    }
}
