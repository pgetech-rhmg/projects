import { Injectable } from "@angular/core";
import { MsalGuardConfiguration, MsalInterceptorConfiguration } from "@azure/msal-angular";
import { BrowserCacheLocation, InteractionType, IPublicClientApplication, PublicClientApplication } from "@azure/msal-browser";

import { AppConfigService } from "~/core/services/appconfig.service";

@Injectable({
    providedIn: 'root'
})
export class AuthFactories {
    public initializerFactory(config: AppConfigService) {
        let promise = config.init();

        return () => promise;
    }

    public MSALInstanceFactory(config: AppConfigService): IPublicClientApplication {
        return new PublicClientApplication({
            auth: {
                clientId: config.getConfigKey("clientId"),
                authority: "https://login.microsoftonline.com/" + config.getConfigKey("tenantId"),
                redirectUri: '/',
                postLogoutRedirectUri: '/',
                navigateToLoginRequestUrl: true
            },
            cache: {
                cacheLocation: BrowserCacheLocation.SessionStorage,
                temporaryCacheLocation: BrowserCacheLocation.SessionStorage,
                storeAuthStateInCookie: false,
                secureCookies: true
            },
            system: {
                loggerOptions: undefined
            }
        })
    }

    public MSALGuardConfigFactory(config: AppConfigService): MsalGuardConfiguration {
        return {
            interactionType: InteractionType.Redirect,
            authRequest: {
            },
            loginFailedRoute: '/'
        }
    }

    public MSALInterceptorConfigFactory(config: AppConfigService): MsalInterceptorConfiguration {
        const protectedResourceMap = new Map<string, Array<string>>();
        protectedResourceMap.set('https://graph.microsoft.com/v1.0/me', ['user.read']);

        return {
            interactionType: InteractionType.Redirect,
            protectedResourceMap: protectedResourceMap
        }
    }
}