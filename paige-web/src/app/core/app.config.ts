import { ApplicationConfig, inject, provideAppInitializer  } from "@angular/core";
import { provideRouter } from "@angular/router";

import { HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';

import { MsalGuard, MsalInterceptor, MsalBroadcastService, MsalService, MSAL_GUARD_CONFIG, MSAL_INSTANCE, MSAL_INTERCEPTOR_CONFIG } from '@azure/msal-angular';

import { coreRoutes } from '~/core/classes/routes/core.routing';
import { appRoutes } from '~/classes/routes/app.routing';

import { AppConfigService } from '~/core/services/appconfig.service';
import { HttpService } from '~/core/services/http.service';
import { AuthFactories } from '~/core/classes/auth/auth.factories';
import { AuthGuard } from './classes/auth/auth.guard';

const authFactories = new AuthFactories();

export function initializeApp() {
    return () => inject(HttpService).init();
}

export const appConfig: ApplicationConfig = {
    providers: [
        provideAppInitializer(initializeApp()),
        provideHttpClient(withInterceptorsFromDi()),
        AuthGuard,
        {
            provide: HTTP_INTERCEPTORS,
            useClass: MsalInterceptor,
            multi: true
        },
        {
            provide: MSAL_INSTANCE,
            useFactory: authFactories.MSALInstanceFactory,
            deps: [AppConfigService]
        },
        {
            provide: MSAL_GUARD_CONFIG,
            useFactory: authFactories.MSALGuardConfigFactory,
            deps: [AppConfigService]
        },
        {
            provide: MSAL_INTERCEPTOR_CONFIG,
            useFactory: authFactories.MSALInterceptorConfigFactory,
            deps: [AppConfigService]
        },

        MsalService,
        MsalGuard,
        MsalBroadcastService,

        provideRouter(coreRoutes),
        provideRouter(appRoutes),
    ]
};