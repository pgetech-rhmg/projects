import { inject } from '@angular/core';
import { HttpInterceptorFn } from '@angular/common/http';
import { MsalService } from '@azure/msal-angular';
import { environment } from '../../environments/environment';

export const userInterceptor: HttpInterceptorFn = (req, next) => {
  let userId: string;

  if (environment.production) {
    const msalService = inject(MsalService);
    const account = msalService.instance.getActiveAccount();
    userId = account?.name ?? 'Unknown';
  } else {
    userId = 'Morgan, Robb';
  }

  const cloned = req.clone({
    setHeaders: { 'X-Epic-User': userId },
  });

  return next(cloned);
};
