import {
  APP_INITIALIZER,
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZoneChangeDetection,
} from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import { MSAL_INSTANCE, MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { BrowserCacheLocation, PublicClientApplication } from '@azure/msal-browser';

import { environment } from '../environments/environment';
import { routes } from './app.routes';
import { userInterceptor } from './interceptors/user.interceptor';

export function msalInstanceFactory() {
  return new PublicClientApplication({
    auth: {
      clientId: environment.msalClientId,
      authority: `https://login.microsoftonline.com/${environment.msalTenantId}`,
      redirectUri: environment.redirectUri,
    },
    cache: {
      cacheLocation: BrowserCacheLocation.SessionStorage,
    },
  });
}

export function msalInitializerFactory(msalService: MsalService) {
  return () => msalService.instance.initialize();
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([userInterceptor])),
    { provide: MSAL_INSTANCE, useFactory: msalInstanceFactory },
    MsalService,
    MsalBroadcastService,
    {
      provide: APP_INITIALIZER,
      useFactory: msalInitializerFactory,
      deps: [MsalService],
      multi: true,
    },
  ],
};
