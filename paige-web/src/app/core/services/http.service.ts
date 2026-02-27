import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Observable, lastValueFrom, timeout } from 'rxjs';

import { AppConfigService } from '~/core/services/appconfig.service';
import { AppConfig } from '~/core/models/appconfig';

const TIMEOUT: number = 300000;

@Injectable({
    providedIn: 'root'
})
export class HttpService {
    private config: AppConfig = new AppConfig();
    private readonly apiHeader: HttpHeaders = new HttpHeaders({ "accept": "text/plain", "Content-Type": "application/json" });

    constructor(
        private readonly http: HttpClient,
        private readonly appconfigService: AppConfigService
    ) {
    }

    public async init(): Promise<void> {
        await this.appconfigService.getConfig().then((config: AppConfig) => {
            this.config = config;
            sessionStorage.setItem("_config", JSON.stringify(config));
        });
    }

    public Get<T>(endpoint: string, headers: HttpHeaders = this.apiHeader, callTimeout: number = TIMEOUT): Observable<T> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.get<T>(`${this.config.apiUrl}${endpoint}`, { withCredentials: true }).pipe(timeout(callTimeout));
    }

    public Post<T>(endpoint: string, body?: any, headers: HttpHeaders = this.apiHeader, callTimeout: number = TIMEOUT): Observable<T> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.post<T>(`${this.config.apiUrl}${endpoint}`, body, { headers: headers, withCredentials: true }).pipe(timeout(callTimeout));
    }

    public Put<T>(endpoint: string, body?: any, headers: HttpHeaders = this.apiHeader, callTimeout: number = TIMEOUT): Observable<T> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.put<T>(`${this.config.apiUrl}${endpoint}`, body, { withCredentials: true }).pipe(timeout(callTimeout));
    }

    public Delete<T>(endpoint: string, headers: HttpHeaders = this.apiHeader, callTimeout: number = TIMEOUT): Observable<T> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.delete<T>(`${this.config.apiUrl}${endpoint}`, { headers: headers, withCredentials: true }).pipe(timeout(callTimeout));
    }

    public GetDownload(endpoint: string, callTimeout: number = TIMEOUT): Observable<HttpResponse<Blob>> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.get(`${this.config.apiUrl}${endpoint}`, { withCredentials: true, observe: 'response', responseType: "blob", headers: { Accept: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' } }).pipe(timeout(callTimeout));
    }

    public GetDownloadFile(endpoint: string, body?: any, callTimeout: number = TIMEOUT): Observable<HttpResponse<Blob>> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.post(`${this.config.apiUrl}${endpoint}`, body, { withCredentials: true, observe: 'response', responseType: "blob", headers: { Accept: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' } }).pipe(timeout(callTimeout));
    }

    public GetPdf<T>(endpoint: string, callTimeout: number = TIMEOUT): Observable<T> {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return this.http.get<T>(`${this.config.apiUrl}${endpoint}`, { withCredentials: true, responseType: "blob" as "json" }).pipe(timeout(callTimeout));
    }

    public SSE(endpoint: string): EventSource {
        this.config = JSON.parse(sessionStorage.getItem("_config")!);

        return new EventSource(`${this.config.apiUrl}${endpoint}`);
    }

    public async GetAsset(file: string) {
        let results: any = null;

        try {
            let stream$ = this.http.get(`assets/${file}`);

            results = await lastValueFrom(stream$);
        } catch (error: any) {
            throw error;
        }

        return results;
    }

    public GetExternal<T>(url: string, callTimeout: number = TIMEOUT): Observable<T> {
        return this.http.get<T>(url).pipe(timeout(callTimeout));
    }
}
