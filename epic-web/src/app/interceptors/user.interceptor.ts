import { inject } from '@angular/core';
import { HttpInterceptorFn } from '@angular/common/http';
import { MsalService } from '@azure/msal-angular';
import { catchError, from, switchMap } from 'rxjs';
import { environment } from '../../environments/environment';

/**
 * Attaches an Entra ID (MSAL) bearer token to epic-api requests so the API can
 * authenticate the caller. epic-api validates the ID token (audience = the app
 * registration's client ID) and derives the user's corpId from it — replacing
 * the old trust-the-X-Epic-User-header model.
 *
 * We read the ID token (`result.idToken`) rather than an access token: an ID
 * token always carries `aud = clientId`, so no "expose an API" app-registration
 * change and no custom API scope are needed. We request the `User.Read` scope —
 * the same scope loadUserPhoto() already uses successfully in this app — purely
 * because acquireTokenSilent needs *a* scope; the returned ID token is what we
 * send.
 *
 * Only requests to the configured apiUrl get the token. In non-production dev
 * (no MSAL), we skip the token — epic-api's Development environment bypasses
 * auth entirely (see DevCurrentUser).
 *
 * IMPORTANT: this interceptor never triggers interactive login. On any silent
 * failure it proceeds unauthenticated (epic-api returns 401); interactive login
 * is owned solely by the app's inProgress$ handler, so the interceptor can never
 * cause a redirect loop.
 */
export const userInterceptor: HttpInterceptorFn = (req, next) => {
  if (!environment.production || !req.url.startsWith(environment.apiUrl)) {
    return next(req);
  }

  const msalService = inject(MsalService);
  const account =
    msalService.instance.getActiveAccount() ?? msalService.instance.getAllAccounts()[0];

  if (!account) {
    return next(req);
  }

  return from(
    msalService.instance.acquireTokenSilent({ scopes: ['User.Read'], account }),
  ).pipe(
    switchMap((result) =>
      result.idToken
        ? next(req.clone({ setHeaders: { Authorization: `Bearer ${result.idToken}` } }))
        : next(req),
    ),
    // Silent acquisition failed — send the request unauthenticated. Do NOT call
    // loginRedirect/acquireTokenRedirect here; the app's inProgress$ handler owns
    // interactive login, so this never loops.
    catchError(() => next(req)),
  );
};
