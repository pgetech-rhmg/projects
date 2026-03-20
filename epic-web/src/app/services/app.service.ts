import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { AppDetail, ManagedApp } from '../models/app.model';

@Injectable({ providedIn: 'root' })
export class AppService {
  private readonly http = inject(HttpClient);

  // Swap these URLs for real API endpoints when ready.
  private readonly appsUrl = 'data/apps.json';
  private readonly appDetailUrl = (name: string) => `data/apps/${name}.json`;

  getApps(): Observable<ManagedApp[]> {
    return this.http.get<ManagedApp[]>(this.appsUrl);
  }

  getApp(name: string): Observable<AppDetail> {
    return this.http.get<AppDetail>(this.appDetailUrl(name));
  }
}
