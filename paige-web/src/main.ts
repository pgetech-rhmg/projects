import { enableProdMode } from '@angular/core';
import { bootstrapApplication } from '@angular/platform-browser';

import { environment } from './environments/environment';
import { AppComponent } from '~/core/app.component';
import { appConfig } from '~/core/app.config';

if (environment.production) {
  enableProdMode();
}

try {
  bootstrapApplication(AppComponent, appConfig);
} catch (err) {
  console.error(err)
}
