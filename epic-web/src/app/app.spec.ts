import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { MSAL_INSTANCE, MsalBroadcastService, MsalService } from '@azure/msal-angular';
import { Subject } from 'rxjs';

import { App } from './app';

class StubMsalService {
  instance = {
    getActiveAccount: () => null,
    getAllAccounts: () => [],
    setActiveAccount: () => {},
    initialize: () => Promise.resolve(),
  };
  handleRedirectObservable() {
    return { subscribe: () => ({ unsubscribe: () => {} }) };
  }
  acquireTokenSilent() {
    return { subscribe: () => ({ unsubscribe: () => {} }) };
  }
  loginRedirect() {
    return Promise.resolve();
  }
}

class StubMsalBroadcastService {
  inProgress$ = new Subject<unknown>();
}

describe('App', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: MSAL_INSTANCE, useValue: {} },
        { provide: MsalService, useClass: StubMsalService },
        { provide: MsalBroadcastService, useClass: StubMsalBroadcastService },
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should render title', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('h1')?.textContent).toContain('EPIC');
  });
});
