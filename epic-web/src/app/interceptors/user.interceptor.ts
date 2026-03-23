import { HttpInterceptorFn } from '@angular/common/http';

export const userInterceptor: HttpInterceptorFn = (req, next) => {
  // TODO: Replace with real identity from MSAL when auth is wired up
  const userId = 'rhmg';

  const cloned = req.clone({
    setHeaders: { 'X-Epic-User': userId }
  });

  return next(cloned);
};
