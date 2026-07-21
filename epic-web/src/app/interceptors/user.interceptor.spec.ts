import { fakeAsync, flushMicrotasks, TestBed } from '@angular/core/testing';
import {
  HttpHandlerFn,
  HttpInterceptorFn,
  HttpRequest,
  HttpResponse,
} from '@angular/common/http';
import { MsalService } from '@azure/msal-angular';
import { of, throwError } from 'rxjs';

import { userInterceptor } from './user.interceptor';
import { environment } from '../../environments/environment';

describe('userInterceptor', () => {
  const apiUrl = environment.apiUrl;
  let originalProduction: boolean;

  let getActiveAccount: jasmine.Spy;
  let getAllAccounts: jasmine.Spy;
  let acquireTokenSilent: jasmine.Spy;

  beforeEach(() => {
    originalProduction = environment.production;

    getActiveAccount = jasmine.createSpy('getActiveAccount').and.returnValue(null);
    getAllAccounts = jasmine.createSpy('getAllAccounts').and.returnValue([]);
    acquireTokenSilent = jasmine
      .createSpy('acquireTokenSilent')
      .and.returnValue(Promise.resolve({ idToken: 'id-token' }));

    const msalStub = {
      instance: { getActiveAccount, getAllAccounts, acquireTokenSilent },
    };

    TestBed.configureTestingModule({
      providers: [{ provide: MsalService, useValue: msalStub }],
    });
  });

  afterEach(() => {
    environment.production = originalProduction;
  });

  /** Run the functional interceptor inside an injection context and expose the
   *  request that reaches the (stubbed) next handler via a live getter — read
   *  `capture.forwarded` *after* flushing microtasks for the async token path. */
  function run(req: HttpRequest<unknown>): { readonly forwarded: HttpRequest<unknown> | undefined } {
    let forwarded: HttpRequest<unknown> | undefined;
    const next: HttpHandlerFn = (r) => {
      forwarded = r;
      return of(new HttpResponse({ status: 200 }));
    };
    TestBed.runInInjectionContext(() => {
      (userInterceptor as HttpInterceptorFn)(req, next).subscribe();
    });
    return {
      get forwarded() {
        return forwarded;
      },
    };
  }

  it('passes the request through untouched in non-production', () => {
    environment.production = false;
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);

    expect(capture.forwarded).toBe(req);
    expect(acquireTokenSilent).not.toHaveBeenCalled();
  });

  it('passes non-apiUrl requests through untouched in production', () => {
    environment.production = true;
    const req = new HttpRequest('GET', 'https://graph.microsoft.com/v1.0/me');

    const capture = run(req);

    expect(capture.forwarded).toBe(req);
    expect(acquireTokenSilent).not.toHaveBeenCalled();
  });

  it('forwards unauthenticated when there is no account', () => {
    environment.production = true;
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);

    expect(capture.forwarded).toBe(req);
    expect(acquireTokenSilent).not.toHaveBeenCalled();
  });

  it('attaches the bearer token when an active account is present', fakeAsync(() => {
    environment.production = true;
    getActiveAccount.and.returnValue({ homeAccountId: 'a' });
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);
    flushMicrotasks();

    expect(acquireTokenSilent).toHaveBeenCalled();
    expect(capture.forwarded?.headers.get('Authorization')).toBe('Bearer id-token');
  }));

  it('falls back to getAllAccounts when there is no active account', fakeAsync(() => {
    environment.production = true;
    getAllAccounts.and.returnValue([{ homeAccountId: 'b' }]);
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);
    flushMicrotasks();

    const account = acquireTokenSilent.calls.mostRecent().args[0].account;
    expect(account).toEqual({ homeAccountId: 'b' });
    expect(capture.forwarded?.headers.get('Authorization')).toBe('Bearer id-token');
  }));

  it('forwards without a header when the token result has no idToken', fakeAsync(() => {
    environment.production = true;
    getActiveAccount.and.returnValue({ homeAccountId: 'a' });
    acquireTokenSilent.and.returnValue(Promise.resolve({ idToken: '' }));
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);
    flushMicrotasks();

    expect(capture.forwarded).toBe(req);
    expect(capture.forwarded?.headers.has('Authorization')).toBe(false);
  }));

  it('forwards unauthenticated when silent acquisition fails', fakeAsync(() => {
    environment.production = true;
    getActiveAccount.and.returnValue({ homeAccountId: 'a' });
    acquireTokenSilent.and.returnValue(throwError(() => new Error('interaction required')));
    const req = new HttpRequest('GET', `${apiUrl}/api/apps`);

    const capture = run(req);
    flushMicrotasks();

    expect(capture.forwarded).toBe(req);
    expect(capture.forwarded?.headers.has('Authorization')).toBe(false);
  }));
});
