import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';
import { of } from 'rxjs';

import { AppDetail, AppLookup, ManagedApp, RepoCheckResult, RunStatus } from '../models/app.model';

@Injectable({ providedIn: 'root' })
export class AppService {
  private readonly http = inject(HttpClient);

  // Swap these URLs for real API endpoints when ready.
  private readonly appsUrl          = 'data/apps.json';
  private readonly masterAppsUrl    = 'data/master-apps.json';
  private readonly githubReposUrl   = 'data/github-repos.json';
  private readonly appDetailUrl     = (name: string) => `data/apps/${name}.json`;

  getApps(): Observable<ManagedApp[]> {
    return this.http.get<ManagedApp[]>(this.appsUrl);
  }

  getApp(name: string): Observable<AppDetail> {
    return this.http.get<AppDetail>(this.appDetailUrl(name));
  }

  /** Validate a repo for onboarding — three-step check:
   *  1. Does the repo exist / is it accessible on GitHub?
   *     Real API equivalent: GET /api/github/repos/<repo>
   *  2. Is it already registered in EPIC?
   *     Real API equivalent: GET /api/apps/check?repo=<repo>
   *  3. Is it already in the current user's list?
   *     Real API equivalent: GET /api/users/me/apps/<repo> */
  checkRepo(repo: string): Observable<RepoCheckResult> {
    const normalized = repo.trim().toLowerCase();

    return this.http.get<{ repo: string }[]>(this.githubReposUrl).pipe(
      switchMap(githubRepos => {
        const existsOnGitHub = githubRepos.some(r => r.repo.toLowerCase() === normalized);
        if (!existsOnGitHub) {
          return of({ status: 'not-found' as const });
        }
        return this.http.get<AppLookup[]>(this.masterAppsUrl).pipe(
          switchMap(masterApps => {
            const masterApp = masterApps.find(a => a.github.repo.toLowerCase() === normalized);
            if (!masterApp) {
              return of({ status: 'available' as const });
            }
            return this.http.get<ManagedApp[]>(this.appsUrl).pipe(
              map(myApps => {
                const alreadyMine = myApps.some(a => a.name === masterApp.name);
                return alreadyMine
                  ? { status: 'already-mine' as const, masterApp }
                  : { status: 'in-epic-not-mine' as const, masterApp };
              })
            );
          })
        );
      })
    );
  }

  /** Add an existing EPIC app to the current user's list.
   *  Real API equivalent: POST /api/users/me/apps { name } */
  addToMyApps(masterApp: AppLookup): Observable<ManagedApp> {
    return of({
      name: masterApp.name,
      technology: masterApp.technology,
      cloud: masterApp.cloud,
      environment: masterApp.environment,
      lastPipelineRun: '—',
      runStatus: 'Success' as RunStatus,
      triggeredBy: '—'
    });
  }
}
