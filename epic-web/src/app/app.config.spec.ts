import { PublicClientApplication } from '@azure/msal-browser';

import { appConfig, msalInitializerFactory, msalInstanceFactory } from './app.config';

describe('app.config', () => {
  it('exposes a providers array', () => {
    expect(Array.isArray(appConfig.providers)).toBe(true);
    expect(appConfig.providers.length).toBeGreaterThan(0);
  });

  it('msalInstanceFactory builds a PublicClientApplication', () => {
    const instance = msalInstanceFactory();
    expect(instance).toBeInstanceOf(PublicClientApplication);
  });

  it('msalInitializerFactory returns a thunk that initializes MSAL', () => {
    const initialize = jasmine.createSpy('initialize').and.returnValue(Promise.resolve());
    const msalService = { instance: { initialize } } as unknown as Parameters<
      typeof msalInitializerFactory
    >[0];

    const initializer = msalInitializerFactory(msalService);
    expect(typeof initializer).toBe('function');

    initializer();
    expect(initialize).toHaveBeenCalled();
  });
});
